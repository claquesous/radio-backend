json.array!(@ratings) do |rating|
  json.extract! rating, :id, :play, :up
end
