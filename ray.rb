require_relative "vec3"

class Ray
  attr_reader :origin, :direction

  def initialize(origin = Point3.new, direction = Vec3.new)
    @origin = origin
    @direction = direction
  end

  def at(t)
    origin + t * direction
  end
end


if $0 == __FILE__
  require "minitest/autorun"

  class TestRay < Minitest::Test
    def test_at
      origin = Vec3.new(0,3,0)
      direction = Vec3.new(2,0,-2)

      ray = Ray.new(origin, direction)

      assert_equal Vec3.new(10.5,3.0,-10.5), ray.at(5.25)
      assert_equal Vec3.new(-20,3,20), ray.at(-10.0)
    end
  end
end
