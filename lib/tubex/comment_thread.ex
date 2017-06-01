defmodule Tubex.CommentThread do
  require Logger

  def all_related_to_channel(channel_id, opts \\ []) do
    defaults = [key: Tubex.api_key, allThreadsRelatedToChannelId: channel_id, maxResults: 50, part: "replies,snippet"]
    opts = Keyword.merge(defaults, opts)

    case Tubex.API.get(Tubex.endpoint <> "/commentThreads", opts) do
      {:ok, response} ->
        tokens = %{"nextPageToken" => response["nextPageToken"], "prevPageToken" => response["prevPageToken"]}
        page_info = Map.merge(response["pageInfo"], tokens)
        {:ok, response["items"], page_info}
      err -> err
    end
  end

  def by_video(video_id, opts \\ []) do
    defaults = [key: Tubex.api_key, videoId: video_id, maxResults: 50, part: "replies,snippet"]
    opts = Keyword.merge(defaults, opts)

    case Tubex.API.get(Tubex.endpoint <> "/commentThreads", opts) do
      {:ok, response} ->
        tokens = %{"nextPageToken" => response["nextPageToken"], "prevPageToken" => response["prevPageToken"]}
        page_info = Map.merge(response["pageInfo"], tokens)
        {:ok, response["items"], page_info}
      err -> err
    end
  end
end