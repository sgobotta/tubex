defmodule Tubex.MockAPI do
  alias Tubex.VideoFixtures

  def get(url, query \\ []) do
    service = List.last(Path.split(url))

    case service do
      "search" ->
        {:ok, max_results} = Keyword.fetch(query, :maxResults)
        response = VideoFixtures.videos_fixture()
        items = Enum.take(response["items"], max_results)
        page_info = Map.merge(response["pageInfo"], %{"resultsPerPage" => max_results})
        {:ok, Map.merge(response, %{"items" => items, "pageInfo" => page_info})}
    end
  end
end
