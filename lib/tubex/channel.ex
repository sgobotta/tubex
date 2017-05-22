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

  def search_by(query, opts) do
    defaults = [key: Tubex.api_key, part: "id,snippet", maxResults: 50, type: "channels", q: query]
    opts = Keyword.merge(defaults, opts)

    case Tubex.API.get(Tubex.endpoint <> "/search", opts) do
      {:ok, response} ->
        tokens = %{"nextPageToken" => response["nextPageToken"], "prevPageToken" => response["prevPageToken"]}
        page_info = Map.merge(response["pageInfo"], tokens)
        IO.inspect response
        # {:ok, Enum.map(response["items"], &parse!/1), page_info}
        {:ok, response["items"], page_info}
      err -> err
    end
  end

  defp request(opts) do
    case Tubex.API.get(Tubex.endpoint <> "/channels", opts) do
      {:ok, res} ->
        {:ok, res["items"], res["pageInfo"]} #|> Enum.map(&parse!/1), res["pageInfo"]}
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
        branding_settings: parse_branding_settings(payload["brandingSettings"]),
        content_details: parse_content_details(payload["contentDetails"]),
        statistics: parse_statistics(payload["statistics"]),
        snippet: parse_snippet(payload["snippet"]),
        topic_details: parse_topic_details(payload["topicDetails"]),
        status: parse_status(payload["status"])
      }
    }
  end

  defp parse_branding_settings(settings) do
    %{
      channel: %{
        description: get_in(settings, ~w(channel description)),
        title: get_in(settings, ~w(channel, title)),
        featured_channels_title: get_in(settings, ~w(channel, featuredChannelsTitle)),
        featured_channels_urls: get_in(settings, ~w(channel featuredChannelsUrls)),
        unsubscribed_trailer: get_in(settings, ~w(channel unsubscribedTrailer)),
        profile_color: get_in(settings, ~w(channel profileColor)),
        keywords: get_in(settings, ~w(channel keywords)),
        country: get_in(settings, ~w(channel country))
      }
    }
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
    %{
      channel_id: snippet["channelId"],
      published_at: snippet["publishedAt"],
      description: snippet["description"],
      title: snippet["title"],
      custom_url: snippet["customUrl"],
      country: snippet["country"]
    }
  end

  defp parse_statistics(statistics) do
    %{
      view_count: statistics["viewCount"],
      comment_count: statistics["commentCount"],
      subscriber_count: statistics["subscriberCount"],
      hidden_subscriber_count: statistics["hiddenSubscriberCount"],
      video_count: statistics["videoCount"]
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
    # The 1 + is because the query itself always costs 1 point for channels.
    Enum.reduce(parts, 0, &(1 + &2 + Keyword.get(part_costs(:list), &1, 0)))
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
