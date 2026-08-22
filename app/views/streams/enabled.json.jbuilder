json.array! @streams do |stream|
  json.extract! stream, :id, :name, :premium, :description, :genre
end
