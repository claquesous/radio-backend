class Play < ActiveRecord::Base
  belongs_to :song
  default_scope {order(id: :desc).limit(25)}
end
