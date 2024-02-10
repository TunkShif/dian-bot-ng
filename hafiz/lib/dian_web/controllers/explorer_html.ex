defmodule DianWeb.ExplorerHTML do
  import Phoenix.Component

  def index(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <title>Explorer Sandbox</title>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <style>
          body {
            margin: 0;
            width: 100%;
            height: 100vh;
          }
        </style>
      </head>
      <body>
        <div style="width: 100%; height: 100%;" id="embedded-sandbox"></div>
        <script
          src="https://embeddable-sandbox.cdn.apollographql.com/_latest/embeddable-sandbox.umd.production.min.js"
        >
        </script>
        <script>
          new window.EmbeddedSandbox({
            target: '#embedded-sandbox',
            initialEndpoint: 'http://localhost:4000/graphql',
          });
        </script>
      </body>
    </html>
    """
  end
end
