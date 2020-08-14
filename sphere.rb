require_relative "hittable"
require_relative "vec3"

class Sphere
  include Hittable
  attr_reader :center, :radius, :material

  def initialize(center, radius, material)
    @center = center
    @radius = radius
    @material = material
  end

  def hit(r, t_min, t_max, rec)
    oc = r.origin - center
    a = r.direction.length_squared
    half_b = Vec3.dot(oc, r.direction)
    c = oc.length_squared - radius * radius
    discriminant = half_b * half_b - a * c

    if discriminant > 0
      root = Math.sqrt(discriminant)
      temp = (-half_b - root) / a
      if temp < t_max && temp > t_min
        rec.t = temp
        rec.p = r.at(rec.t)
        outward_normal = (rec.p - center) / radius
        rec.set_face_normal(r, outward_normal)
        rec.material = material

        return true
      end

      temp = (-half_b + root) / a
      if temp < t_max && temp > t_min
        rec.t = temp
        rec.p = r.at(rec.t)
        outward_normal = (rec.p - center) / radius
        rec.set_face_normal(r, outward_normal)
        rec.material = material

        return true
      end
    end

    false
  end
end
