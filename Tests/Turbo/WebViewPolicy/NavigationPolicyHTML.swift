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
