defmodule Dian.AI.DailySteamSummarySchedulerTest do
  use ExUnit.Case, async: true

  alias Dian.AI.DailySteamSummaryScheduler

  describe "next_run_at/1" do
    test "schedules the same day when before 10:00 UTC+8" do
      assert DailySteamSummaryScheduler.next_run_at(~U[2026-05-10 01:30:00Z]) ==
               ~U[2026-05-10 02:00:00Z]
    end

    test "schedules the next day when at or after 10:00 UTC+8" do
      assert DailySteamSummaryScheduler.next_run_at(~U[2026-05-10 02:00:00Z]) ==
               ~U[2026-05-11 02:00:00Z]

      assert DailySteamSummaryScheduler.next_run_at(~U[2026-05-10 04:30:00Z]) ==
               ~U[2026-05-11 02:00:00Z]
    end
  end
end
