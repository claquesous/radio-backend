json.array! @credits do |credit|
  json.extract! credit, :role, :detail, :source
  json.person credit.person, :id, :name, :mb_artist_id
end
