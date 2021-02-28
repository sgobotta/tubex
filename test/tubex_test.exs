defmodule TubexTest do
  use ExUnit.Case

  doctest Tubex

  alias Tubex.Video

  describe "API - Search by query" do
    test "GET - A list of videos is returned on search_by_query" do
      search_query = "mandatory param"
      opts = [maxResults: 40]
      {:ok, response, page_info} = Video.search_by_query(search_query, opts)

      assert Keyword.fetch!(opts, :maxResults) == length(response)
      assert Keyword.fetch!(opts, :maxResults) == page_info["resultsPerPage"]
    end
  end
end
