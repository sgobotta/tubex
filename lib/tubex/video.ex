defmodule Tubex.Video do

  defstruct title: nil, etag: nil, video_id: nil, channel_id: nil, channel_title: nil, description: nil, published_at: nil, thumbnails: [], playlist_id: nil

  @doc """
  fetch contents details
  """
  def detail(video_ids, opts \\ [])
  def detail(video_ids, opts) when is_list(video_ids) do
    defaults = [key: Tubex.api_key, id: Enum.join(video_ids, ","), part: "statistics"]
    opts2 = Keyword.merge(defaults, opts)

    case Tubex.API.get(Tubex.endpoint <> "/videos", opts2) do
      {:ok, response} -> response
      err -> err
    end
  end
  def detail(video_id, opts) do
    defaults = [key: Tubex.api_key, id: video_id, part: "contentDetails"]
    opts = Keyword.merge(defaults, opts)

    case Tubex.API.get(Tubex.endpoint <> "/videos", opts) do
      {:ok, response} ->
        response
      err -> err
    end
  end

  def metadata(video_id, opts \\ []) do
    defaults = [key: Tubex.api_key, id: video_id, part: "snippet,statistics,topicDetails"]
    opts = Keyword.merge(defaults, opts)

    case Tubex.API.get(Tubex.endpoint <> "/videos", opts) do
      {:ok, response} ->
        response
      err -> err
    end
  end

  def find_by(:channel_id, channel_id, opts \\ []) do
    defaults = [key: Tubex.api_key, part: "id,snippet", maxResults: 50, type: "videos", channelId: channel_id]
    opts = Keyword.merge(defaults, opts)

    case Tubex.API.get(Tubex.endpoint <> "/search", opts) do
      {:ok, response} ->
        tokens = %{"nextPageToken" => response["nextPageToken"], "prevPageToken" => response["prevPageToken"]}
        page_info = Map.merge(response["pageInfo"], tokens)
        # {:ok, Enum.map(response["items"], &parse!/1), page_info}
        {:ok, response["items"], page_info}
      err -> err
    end
  end

  @doc """
  Search from youtube via query.
  """
  def search_by_query(query, opts \\ []) do
    defaults = [key: Tubex.api_key, part: "snippet", maxResults: 50, type: "video", q: query]
    opts = Keyword.merge(defaults, opts)

    case Tubex.api_client().get(Tubex.endpoint <> "/search", opts) do
      {:ok, response} ->
        tokens = %{"nextPageToken" => response["nextPageToken"], "prevPageToken" => response["prevPageToken"]}
        page_info = Map.merge(response["pageInfo"], tokens)
        {:ok, Enum.map(response["items"], &parse!/1), page_info}
      err -> err
    end
  end

  def related_with_video(video_id, opts \\ []) do
    defaults = [key: Tubex.api_key, part: "snippet", maxResults: 50, type: "video", relatedToVideoId: video_id]
    opts = Keyword.merge(defaults, opts)
    case Tubex.API.get(Tubex.endpoint <> "/search", opts) do
      {:ok, response} ->
        {:ok, Enum.map(response["items"], &parse!/1), response["pageInfo"]}
      err -> err
    end
  end

  defp parse!(body) do
    case parse(body) do
      {:ok, video} -> video
      {:error, body} -> raise "Parse error occured! #{body}"
    end
  end

  defp parse(%{"snippet" => snippet, "id" => %{"videoId" => video_id}}) do
    {:ok,
      %Tubex.Video{
        etag: snippet["etag"],
        title: snippet["title"],
        thumbnails: snippet["thumbnails"],
        published_at: snippet["publishedAt"],
        channel_title: snippet["channelTitle"],
        channel_id: snippet["channelId"],
        description: snippet["description"],
        video_id: video_id
      }
    }
  end

  defp parse(%{"snippet" => snippet, "id" => %{"playlistId" => playlist_id}}) do
    {:ok,
      %Tubex.Video{
        etag: snippet["etag"],
        title: snippet["title"],
        thumbnails: snippet["thumbnails"],
        published_at: snippet["publishedAt"],
        channel_title: snippet["channelTitle"],
        channel_id: snippet["channelId"],
        description: snippet["description"],
        playlist_id: playlist_id
      }
    }
  end

  defp parse(body) do
    {:error, body}
  end
end
