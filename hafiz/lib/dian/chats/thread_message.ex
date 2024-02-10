defmodule Dian.Chats.ThreadMessage do
  use Ecto.Schema

  alias Dian.Chats.{Thread, Message}

  @primary_key false
  schema "threads_messages" do
    belongs_to :thread, Thread, primary_key: true
    belongs_to :message, Message, primary_key: true

    timestamps(type: :utc_datetime, updated_at: false)
  end
end
