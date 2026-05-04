defmodule DianBot.Client.WebSocketTest do
  use ExUnit.Case, async: true

  alias DianBot.Client.WebSocket

  test "successful response sends ok result and removes pending request" do
    ref = make_ref()
    request_id = "request-1"
    state = %{pending: %{request_id => {self(), ref}}}

    assert {:ok, %{pending: %{}}} =
             WebSocket.handle_frame(
               {:text,
                Jason.encode!(%{
                  "echo" => request_id,
                  "status" => "ok",
                  "retcode" => 0,
                  "data" => %{"groups" => []}
                })},
               state
             )

    assert_receive {:response, ^ref, {:ok, %{"groups" => []}}}
  end

  test "error response drops data and echo before replying" do
    ref = make_ref()
    request_id = "request-1"
    state = %{pending: %{request_id => {self(), ref}}}

    assert {:ok, %{pending: %{}}} =
             WebSocket.handle_frame(
               {:text,
                Jason.encode!(%{
                  "echo" => request_id,
                  "status" => "failed",
                  "retcode" => 1400,
                  "wording" => "bad request",
                  "data" => %{"ignored" => true}
                })},
               state
             )

    assert_receive {:response, ^ref,
                    {:error,
                     %{"retcode" => 1400, "status" => "failed", "wording" => "bad request"}}}
  end

  test "matching cancellation removes pending request" do
    ref = make_ref()
    request_id = "request-1"
    state = %{pending: %{request_id => {self(), ref}}}

    assert {:ok, %{pending: %{}}} =
             WebSocket.handle_cast({:cancel_request, request_id, ref}, state)
  end

  test "cancellation with different ref keeps pending request" do
    ref = make_ref()
    other_ref = make_ref()
    request_id = "request-1"
    state = %{pending: %{request_id => {self(), ref}}}

    assert {:ok, ^state} =
             WebSocket.handle_cast({:cancel_request, request_id, other_ref}, state)
  end

  test "late response for cancelled request is ignored" do
    ref = make_ref()
    state = %{pending: %{}}

    assert {:ok, %{pending: %{}}} =
             WebSocket.handle_frame(
               {:text,
                Jason.encode!(%{
                  "echo" => "cancelled-request",
                  "status" => "ok",
                  "retcode" => 0,
                  "data" => %{"groups" => []}
                })},
               state
             )

    refute_receive {:response, ^ref, _result}
  end
end
