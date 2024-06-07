json.extract! @rating, :play_id, :up, :created_at
json.new_rating @new_rating
json.old_rating @old_rating
json.can_rate_again @can_rate_again
