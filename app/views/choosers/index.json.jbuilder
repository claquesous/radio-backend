if @pagination.present?
  json.choosers @choosers, partial: "choosers/chooser", as: :chooser
  json.total @pagination[:total_count]
  json.total_pages @pagination[:total_pages]
  json.offset @pagination[:offset]
  json.limit @pagination[:limit]
else
  json.array! @choosers, partial: "choosers/chooser", as: :chooser
end
