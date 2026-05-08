defmodule Dian.SteamWatcher.Notifier do
  @moduledoc false

  def child_spec(opts), do: Dian.SteamWatcher.StatusNotifier.child_spec(opts)
  defdelegate start_link(opts \\ []), to: Dian.SteamWatcher.StatusNotifier
  defdelegate notify(event), to: Dian.SteamWatcher.StatusNotifier
  defdelegate build_status_card_svg(event), to: Dian.SteamWatcher.StatusNotifier
  defdelegate build_status_card_svg(player, locale), to: Dian.SteamWatcher.StatusNotifier
end
