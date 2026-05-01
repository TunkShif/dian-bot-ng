defmodule DianWeb.UserSessionHTML do
  use DianWeb, :html

  embed_templates "user_session_html/*"

  defp local_mail_adapter? do
    Application.get_env(:dian, Dian.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
