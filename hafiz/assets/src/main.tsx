import React from "react"
import ReactDOM from "react-dom/client"
import { App } from "./app"
import "@fontsource/silkscreen"
import "@fontsource-variable/figtree"
import "~/libs/i18n"
import "./index.css"

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
