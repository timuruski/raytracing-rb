require_relative "ray"
require_relative "vec3"

class Camera
  attr_accessor :aspect_ratio, :focal_length, :viewport_height, :viewport_width
  attr_accessor :origin, :horizontal, :vertical, :lower_left_corner

  def initialize(look_from, look_at, vup, vfov, aspect_ratio, aperture, focus_dist)
    theta = vfov * Math::PI / 180.0
    h = Math.tan(theta / 2)

    self.aspect_ratio = aspect_ratio
    self.viewport_height = 2.0 * h
    self.viewport_width = aspect_ratio * viewport_height

    @w = Vec3.unit(look_from - look_at)
    @u = Vec3.unit(Vec3.cross(vup, @w))
    @v = Vec3.cross(@w, @u)

    self.origin = look_from
    self.horizontal = focus_dist * viewport_width * @u
    self.vertical = focus_dist * viewport_height * @v
    self.lower_left_corner = origin - (horizontal / 2) - (vertical / 2) - (focus_dist * @w)

    @lens_radius = aperture / 2
  end

  def get_ray(s, t)
    rd = @lens_radius * Vec3.random_in_unit_disk
    offset = @u * rd.x + @v * rd.y

    Ray.new(origin + offset, lower_left_corner + (s * horizontal) + (t * vertical) - origin - offset)
  end
end
