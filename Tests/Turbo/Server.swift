import Embassy
import Foundation

extension DefaultHTTPServer {
    static func turboServer(eventLoop: EventLoop, port: Int = 8080) -> DefaultHTTPServer {
        return DefaultHTTPServer(eventLoop: eventLoop, port: port) { environ, startResponse, sendBody in
            let path = environ["PATH_INFO"] as! String

            func respondWithFile(resourceName: String, resourceType: String) {
                let fileURL = Bundle.module.url(forResource: resourceName, withExtension: resourceType, subdirectory: "Server")!
                let data = try! Data(contentsOf: fileURL)
                let contentType = (resourceType == "js") ? "application/javascript" : "text/html"

                startResponse("200 OK", [("Content-Type", contentType)])
                sendBody(data)
                sendBody(Data())
            }

            switch path {
            case "/turbo-7.0.0-beta.1.js":
                respondWithFile(resourceName: "turbo-7.0.0-beta.1", resourceType: "js")
            case "/turbolinks-5.2.0.js":
                respondWithFile(resourceName: "turbolinks-5.2.0", resourceType: "js")
            case "/turbolinks-5.3.0-dev.js":
                respondWithFile(resourceName: "turbolinks-5.3.0-dev", resourceType: "js")
            case "/":
                respondWithFile(resourceName: "turbo", resourceType: "html")
            case "/turbolinks":
                respondWithFile(resourceName: "turbolinks", resourceType: "html")
            case "/turbolinks-5.3":
                respondWithFile(resourceName: "turbolinks-5.3", resourceType: "html")
            case "/missing-library":
                startResponse("200 OK", [("Content-Type", "text/html")])
                sendBody("<html></html>".data(using: .utf8)!)
                sendBody(Data())
            case "/bridge-components":
                startResponse("200 OK", [("Content-Type", "text/html")])
                sendBody(bridgeComponentsPage.data(using: .utf8)!)
                sendBody(Data())
            default:
                startResponse("404 Not Found", [("Content-Type", "text/plain")])
                sendBody(Data())
            }
        }
    }
}

/// A Turbo page carrying a faithful stand-in for `@hotwired/hotwire-native-bridge` 1.1.0:
/// the web bridge queues component sends until an adapter is installed, and only
/// `setAdapter` installs one. A bridge component connects on load, as a Stimulus
/// `BridgeComponent` does.
private let bridgeComponentsPage = """
<!DOCTYPE html>
<html lang="en" dir="ltr">
  <head>
    <meta charset="utf-8">
    <title>Bridge Components</title>
    <script src="/turbo-7.0.0-beta.1.js"></script>
    <script type="text/javascript">
      Turbo.start()

      class WebBridge {
        constructor() {
          this.adapter = null
          this.pendingMessages = []
          this.lastMessageId = 0
        }
        start() {
          document.dispatchEvent(new Event("web-bridge:ready"))
        }
        supportsComponent(component) {
          return this.adapter ? this.adapter.supportsComponent(component) : false
        }
        send({ component, event, data }) {
          if (!this.adapter) {
            this.pendingMessages.push({ component, event, data })
            return null
          }
          if (!this.supportsComponent(component)) return null
          const id = (++this.lastMessageId).toString()
          this.adapter.receive({ id, component, event, data: data || {} })
          return id
        }
        receive(message) {}
        setAdapter(adapter) {
          this.adapter = adapter
          document.documentElement.dataset.bridgePlatform = adapter.platform
          this.adapterDidUpdateSupportedComponents()
          const pending = this.pendingMessages
          this.pendingMessages = []
          pending.forEach(message => this.send(message))
        }
        adapterDidUpdateSupportedComponents() {
          if (this.adapter) {
            document.documentElement.dataset.bridgeComponents = this.adapter.supportedComponents.join(" ")
          }
        }
      }

      window.webBridge = new WebBridge()
      window.Strada = { web: window.webBridge }
      window.webBridge.start()
      window.webBridge.send({
        component: "two",
        event: "connect",
        data: { metadata: { url: window.location.href } }
      })
    </script>
  </head>
  <body>
    <h1>Bridge Components</h1>
  </body>
</html>
"""
