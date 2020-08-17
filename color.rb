require_relative "vec3"

Color = Class.new(Vec3) do
  def self.format(color, samples = 1)
    # Divide the color by the number of samples and gamma-correct for gamma=2.0.
    scale = 1.0 / samples
    r = Math.sqrt(scale * color.x)
    g = Math.sqrt(scale * color.y)
    b = Math.sqrt(scale * color.z)

    r = (256 * r.clamp(0.0, 0.999)).to_i
    g = (256 * g.clamp(0.0, 0.999)).to_i
    b = (256 * b.clamp(0.0, 0.999)).to_i

    "#{r} #{g} #{b}"
  end
end
