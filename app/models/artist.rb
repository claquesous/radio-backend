class Artist < ActiveRecord::Base
  default_scope { order :sort }
end
