# Builds small, readable embeddings for specs: SpecVectors.vec(1280, 0 => 1.0, 1 => 0.5)
# is a unit vector pointing mostly along axis 0, tilted toward axis 1.
module SpecVectors
  def self.vec(dims, components)
    v = Array.new(dims, 0.0)
    components.each { |axis, value| v[axis] = value.to_f }
    norm = Math.sqrt(v.sum { |x| x * x })
    v.map { |x| x / norm }
  end

  # Creator vectors are sparse, indexed by people.id.
  def self.sparse(components, dimensions: 1_000_000)
    norm = Math.sqrt(components.values.sum { |x| x * x })
    Neighbor::SparseVector.new(components.transform_values { |x| x / norm }, dimensions)
  end
end
