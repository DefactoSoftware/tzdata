defmodule Tzdata.ReleaseReader do
  def rules,                  do: simple_lookup(:rules) |> hd |> elem(1)
  def zones,                  do: simple_lookup(:zones) |> hd |> elem(1)
  def links,                  do: simple_lookup(:links) |> hd |> elem(1)
  def zone_list,              do: simple_lookup(:zone_list) |> hd |> elem(1)
  def link_list,              do: simple_lookup(:link_list) |> hd |> elem(1)
  def zone_and_link_list,     do: simple_lookup(:zone_and_link_list) |> hd |> elem(1)
  def archive_content_length, do: simple_lookup(:archive_content_length) |> hd |> elem(1)
  def release_version,        do: simple_lookup(:release_version) |> hd |> elem(1)
  defp simple_lookup(key) do
    :ets.lookup(current_release_from_table|>table_name_for_release_name, key)
  end
  def zone(zone_name) do
    {:ok, zones[zone_name]}
  end
  def rules_for_name(rules_name) do
    {:ok, rules[rules_name]}
  end
  def periods_for_zone(zone) do
    if Enum.member?(zone_and_link_list, zone) do
      {:ok, do_periods_for_zone(zone)}
    else
      {:error, nil}
    end
  end
  defp do_periods_for_zone(zone) do
    periods = lookup_periods_for_zone(zone)
    if length(periods) > 0 do
      periods
    else # try links if no periods were found when looking at canonical names
      lookup_periods_for_zone(links[zone])
    end
  end
  defp lookup_periods_for_zone(zone) when is_binary(zone), do: simple_lookup(String.to_atom zone)
  defp lookup_periods_for_zone(_), do: []

  defp current_release_from_table do
    :ets.lookup(:tzdata_current_release, :release_version) |> hd |> elem(1)
  end

  defp table_name_for_release_name(release_name) do
    "tzdata_rel_#{release_name}" |> String.to_atom
  end
end