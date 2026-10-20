json.seeds @seeds, :id, :title
json.weights @weights
json.results @results, partial: "songs/similar_result", as: :result
