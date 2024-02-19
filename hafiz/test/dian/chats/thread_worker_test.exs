defmodule Dian.Chats.ThreadWorkerTest do
  use Dian.DataCase
  use Oban.Testing, repo: Dian.Repo

  import Dian.Fixtures

  alias Dian.Chats.ThreadWorker

  test "should create new thread when given valid event id" do
    Cachex.put(Dian.Cache, "event:123", fixture(:event, id: 123))
    assert :ok = perform_job(ThreadWorker, %{id: 123})
  end
end
