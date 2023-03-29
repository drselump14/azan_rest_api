defmodule AzanRestApi.AzanCalculator do
  @moduledoc """
  The AzanCalculator module is responsible for calculating the azan times
  for a given location and date.
  """

  @doc """
  Calculates the azan times for a given location and date.
  """
  def get_coordinate(latitude, longitude) do
    Azan.Coordinate.new(latitude: latitude, longitude: longitude)
  end

  def fetch_prayer_time(coordinate) do
    date = Timex.today(:local)
    params = Azan.CalculationMethod.muslim_world_league()

    prayer_time = coordinate |> Azan.PrayerTime.find(date, params)
    current_prayer = prayer_time |> Azan.PrayerTime.current_prayer(Timex.now())

    {prayer_time, next_prayer} =
      if current_prayer == :isha do
        tomorrow = Timex.shift(date, days: 1)
        {coordinate |> Azan.PrayerTime.find(tomorrow, params), :fajr}
      else
        {prayer_time, prayer_time |> Azan.PrayerTime.next_prayer(Timex.now())}
      end
    {:ok, {prayer_time, next_prayer}}
  end

  def fetch_next_day_prayer_time(prayer_time, next_prayer) do
    next_prayer_time =
      prayer_time
      |> Azan.PrayerTime.time_for_prayer(next_prayer)
    {:ok, next_prayer_time}
  end

  def call(latitude, longitude) do
    with {:ok, coordinate} <- get_coordinate(latitude, longitude),
      {:ok, {prayer_time, next_prayer}} <- fetch_prayer_time(coordinate),
      {:ok, next_prayer_time} = fetch_next_day_prayer_time(prayer_time, next_prayer) do
      local_next_prayer_time = next_prayer_time |> Timex.local() |> Timex.format!("{h24}:{m}")

      remaining_total = Timex.diff(next_prayer_time, Timex.now(), :minutes)
      remaining_hours = div(remaining_total, 60)
      remaining_minutes = rem(remaining_total, 60)

      local_prayer_time =
        prayer_time
        |> Map.from_struct()
        |> Map.new(fn {prayer_name, time} ->
          {
            prayer_name,
            time |> Timex.local() |> Timex.format!("{h24}:{m}")
          }
        end)

      %{
        "next_prayer" => next_prayer |> Atom.to_string() |> String.upcase(),
        "next_prayer_time" => local_next_prayer_time,
        "remaining_total" => remaining_total,
        "remaining_hours" => remaining_hours,
        "remaining_minutes" => remaining_minutes,
        "prayer_time" => local_prayer_time
      }
    end
  end
end
