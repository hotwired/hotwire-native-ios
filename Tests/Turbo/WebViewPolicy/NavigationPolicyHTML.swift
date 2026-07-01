import Foundation

extension String {
    /// A simple clickable link.
    static var simpleLink = """
    <html>
      <body>
        <a id="link" href="https://example.com">Simple Link</a>
      </body>
    </html>
    """

    /// A link with a target attribute (target="_blank").
    static var targetBlank = """
    <html>
      <body>
        <a id="externalLink" href="https://example.com" target="_blank">Target Blank Link</a>
      </body>
    </html>
    """

    /// A link that is programmatically clicked via JavaScript.
    static var jsClick = """
    <html>
      <body>
        <a id="externalLink" href="https://example.com">JS Click Link</a>
        <script>
          document.getElementById('externalLink').click();
        </script>
      </body>
    </html>
    """

    /// A link to an `about:` URL, which should never be routed externally.
    static var aboutLink = """
    <html>
      <body>
        <a id="link" href="about:blank">About Link</a>
      </body>
    </html>
    """

    /// A link to a `data:` URL, which should never be routed externally.
    static var dataLink = """
    <html>
      <body>
        <a id="link" href="data:text/plain,hello">Data Link</a>
      </body>
    </html>
    """

    /// A form that submits to an external URL.
    static var externalForm = """
    <html>
      <body>
        <form id="form" action="https://example.com/submit" method="POST">
          <input type="hidden" name="x" value="1" />
        </form>
      </body>
    </html>
    """

    /// A JavaScript-initiated reload via a button click.
    static var reload = """
    <html>
        <body>
        <p>Click the button below to reload the page.</p>
            <button id="reloadButton" onclick="location.reload();">Reload Page</button>
        </body>
    </html> 
    """
}
