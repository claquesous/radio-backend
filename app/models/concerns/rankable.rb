module Rankable
  def rank(from = nil, to = nil)
    rank = Play.send("#{self.class.name.underscore}_ranks", from, to).keys.index(id)
    rank + 1 if rank
  end

  def stream_rank(stream, from = nil, to = nil)
    rank = stream.send("#{self.class.name.underscore}_ranks", from, to).keys.index(id)
    rank + 1 if rank
  end
end
