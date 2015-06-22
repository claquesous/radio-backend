json.array!(@listeners) do |listener|
  json.extract! listener, :id, :twitter_handle
end
