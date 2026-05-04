defmodule DianBot.OneBotTest do
  use ExUnit.Case, async: true

  alias DianBot.OneBot

  test "build_request/3 constructs the OneBot request payload" do
    assert OneBot.build_request("uuid-1", "get_group_info", %{group_id: 123}) == %{
             "echo" => "uuid-1",
             "action" => "get_group_info",
             "params" => %{group_id: 123}
           }
  end

  test "classify_payload/1 returns :event for post_type payloads" do
    assert OneBot.classify_payload(%{"post_type" => "message"}) == :event
  end

  test "classify_payload/1 returns :response for echo payloads" do
    assert OneBot.classify_payload(%{"echo" => "request-1", "status" => "ok"}) == :response
  end

  test "classify_payload/1 returns :ignored for unrecognised payloads" do
    assert OneBot.classify_payload(%{"unknown" => "value"}) == :ignored
  end

  test "classify_payload/1 returns :event when both post_type and echo present" do
    assert OneBot.classify_payload(%{"post_type" => "message", "echo" => "r1"}) == :event
  end

  test "response_result/1 returns {:ok, data} for successful response" do
    assert OneBot.response_result(%{
             "status" => "ok",
             "retcode" => 0,
             "echo" => "uuid-1",
             "data" => %{"groups" => []}
           }) == {:ok, %{"groups" => []}}
  end

  test "response_result/1 returns {:error, metadata} for failed response" do
    result =
      OneBot.response_result(%{
        "status" => "failed",
        "retcode" => 1400,
        "echo" => "uuid-1",
        "wording" => "bad request",
        "data" => %{}
      })

    assert {:error, error_map} = result
    refute Map.has_key?(error_map, "data")
    refute Map.has_key?(error_map, "echo")
    assert error_map["retcode"] == 1400
    assert error_map["wording"] == "bad request"
  end
end
