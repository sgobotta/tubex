defmodule Tubex.Channel do
  require Logger

  defstruct id: nil, etag: nil, branding_settings: nil, content_details: nil, snippet: nil, statistics: nil, status: nil, topic_details: nil

  def find_by(:id, channel_id, opts) do
    defaults = [key: Tubex.api_key, id: channel_id, part: "id"]
    opts2 = Keyword.merge(defaults, opts)
    request(opts2)
  end

  def find_by(:username, username, opts) do
    defaults = [key: Tubex.api_key, username: username, part: "id"]
    opts2 = Keyword.merge(defaults, opts)
    request(opts2)
  end

  def find_by(type, key, opts) do
    Logger.warn("Unknown find_by(#{inspect type}) with key #{inspect key} and options #{inspect opts}")
    {:error, "Unknown request"}
  end

  defp request(opts) do
    case Tubex.API.get(Tubex.endpoint <> "/channels", opts) do
      {:ok, res} ->
        {:ok, res["items"] |> Enum.map(&parse!/1), res["pageInfo"]}
      error -> error
    end
  end

  defp parse!(payload) do
    case parse(payload) do
      {:ok, channel} -> channel
      {:error, reason} -> raise "Channel parse error: #{inspect reason}"
    end
  end

  defp parse(payload) do
    {:ok,
      %Tubex.Channel{
        id: payload["id"],
        etag: payload["etag"],
        content_details: parse_content_details(payload["contentDetails"]),
        statistics: parse_statistics(payload["statistics"]),
        topic_details: parse_topic_details(payload["topicDetails"]),
        status: parse_status(payload["status"])
      }
    }
  end

  defp parse_audit_details(audit) do
    
  end

  defp parse_branding_settings(settings) do
    
  end

  defp parse_content_details(content_details) do
    %{
      related_playlists: %{
        uploads: get_in(content_details, ~w(relatedPlaylists uploads)),
        watch_history: get_in(content_details, ~w(relatedPlaylists watchHistory)),
        watch_later: get_in(content_details, ~w(relatedPlaylists watchLater))
      }
    }
  end

  defp parse_snippet(snippet) do
    
  end

  defp parse_statistics(statistics) do
    %{
      view_count: statistics["viewCount"] |> String.to_integer,
      comment_count: statistics["commentCount"] |> String.to_integer,
      subscriber_count: statistics["subscriberCount"] |> String.to_integer,
      hidden_subscriber_count: (statistics["hiddenSubscriberCount"] || "0") |> String.to_integer,
      video_count: statistics["videoCount"] |> String.to_integer
    }
  end

  defp parse_topic_details(topic_details) do
    %{
      ids: topic_details["topicIds"],
      categories: topic_details["topicCategories"]
    }
  end

  defp parse_status(status) do
    %{
      privacy_status: status["privacyStatus"],
      is_linked: status["isLinked"],
      long_uploads_status: status["longUploadsStatus"]
    }
  end
end

defimpl Tubex.Quota.Limits, for: Tubex.Channel do
  require Logger

  def cost_for(%Tubex.Channel{}, :list, parts) do
    Enum.reduce(parts, 0, &(&2 + Keyword.get(part_costs(:list), &1, 0)))
  end

  def cost_for(%Tubex.Channel{}, action, parts) do
    Logger.warn("[#{inspect __MODULE__}] Unknown limit action #{inspect action} with parts: #{inspect parts}")
  end

  defp part_costs(:list) do
    [
      audit_details: 4,
      branding_settings: 2,
      content_details: 2,
      id: 0,
      invideo_promotion: 2,
      localizations: 2,
      snippet: 2,
      statistics: 2,
      status: 2,
      topic_details: 2
    ]
  end

  defp part_costs(action) do
    Logger.warn("[#{inspect __MODULE__}] Unknown action #{inspect action} for part costs.")
  end
end
