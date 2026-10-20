json.song do
  json.extract! @song, :id, :title
end
json.weights @weights
json.results @results, partial: "songs/similar_result", as: :result
