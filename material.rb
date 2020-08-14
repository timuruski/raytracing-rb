require_relative "hittable"
require_relative "ray"
require_relative "vec3"

module Material
  def scatter(ray_in, rec, attenuation, scattered)
    # Ruby doesn't have pointers, so this returns new values
    # [scattered, new_attenuation, did_scatter]
    raise "implement scatter"
  end
end

class Lambertian
  include Material

  attr_reader :albedo
  def initialize(albedo)
    @albedo = albedo
  end

  def scatter(ray_in, rec, attenuation, scattered)
    scatter_dir = rec.normal + Vec3.random_unit_vector
    scattered = Ray.new(rec.p, scatter_dir)
    did_scatter = true

    [scattered, albedo, did_scatter]
  end
end

class Metal
  include Material

  attr_reader :albedo, :fuzz
  def initialize(albedo, fuzz = 1.0)
    @albedo = albedo
    @fuzz = fuzz
  end

  def scatter(ray_in, rec, attenuation, scattered)
    reflected = Vec3.reflect(Vec3.unit(ray_in.direction), rec.normal)
    scattered = Ray.new(rec.p, reflected + fuzz * Vec3.random_in_unit_sphere)
    did_scatter = Vec3.dot(scattered.direction(), rec.normal) > 0.0

    [scattered, albedo, did_scatter]
  end
end
