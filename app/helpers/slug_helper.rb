module SlugHelper
  def to_slug(value)
    value.downcase.gsub(/[^a-z0-9]+/, '-').chomp('-')
  end
end
