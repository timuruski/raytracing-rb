require_relative "hittable_list"
require_relative "ray"
require_relative "sphere"
require_relative "vec3"

INFINITY = Float::INFINITY
PI = Math::PI

def degrees_to_radians(degrees)
  degrees * Math::PI / 180.0
end
