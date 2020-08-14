require_relative "ray"
require_relative "vec3"

class Camera
  attr_accessor :aspect_ratio, :focal_length, :viewport_height, :viewport_width
  attr_accessor :origin, :horizontal, :vertical, :lower_left_corner

  def initialize
    self.aspect_ratio = 16.0 / 9.0
    self.viewport_height = 2.0
    self.viewport_width = aspect_ratio * viewport_height
    self.focal_length = 1.0

    self.origin = Point3.new(0,0,0)
    self.horizontal = Vec3.new(viewport_width,0,0)
    self.vertical = Vec3.new(0,viewport_height,0)
    self.lower_left_corner = origin - (horizontal / 2) - (vertical / 2) - Vec3.new(0, 0, focal_length)
  end

  def get_ray(u, v)
    Ray.new(origin, lower_left_corner + (u * horizontal) + (v * vertical) - origin)
  end
end
