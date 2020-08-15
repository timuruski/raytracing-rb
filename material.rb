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

    [scattered, albedo, true]
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

class Dielectric
  include Material

  attr_reader :ref_idx
  def initialize(ref_idx)
    @ref_idx = ref_idx
  end

  def scatter(r_in, rec, attenuation, scattered)
    attenuation = Color.new(1.0, 1.0, 1.0)
    etai_over_etat = rec.front_face ? (1.0 / ref_idx) : ref_idx

    unit_direction = Vec3.unit(r_in.direction)

    cos_theta = [Vec3.dot(-unit_direction, rec.normal), 1.0].min
    sin_theta = Math.sqrt(1.0 - cos_theta * cos_theta)
    if(etai_over_etat * sin_theta > 1.0)
      reflected = Vec3.reflect(unit_direction, rec.normal)
      scattered = Ray.new(rec.p, reflected)
    elsif rand < schlick(cos_theta, etai_over_etat)
      reflected = Vec3.reflect(unit_direction, rec.normal)
      scattered = Ray.new(rec.p, reflected)
    else
      refracted = Vec3.refract(unit_direction, rec.normal, etai_over_etat)
      scattered = Ray.new(rec.p, refracted)
    end

    [scattered, attenuation, true]
  end

  def schlick(cosine, ref_idx)
    r0 = (1.0 - ref_idx) / (1.0 + ref_idx)
    r0 = r0 * r0
    r0 + (1.0 - r0) * (1.0 - cosine) ** 5.0
  end
end
