Vec3 = Struct.new(:x, :y, :z) do
  def initialize(x = 0.0, y = 0.0, z = 0.0)
    super(x.to_f, y.to_f, z.to_f)
  end

  def -@
    self.class.new(-x, -y, -z)
  end

  def +(other)
    self.class.new(x + other.x, y + other.y, z + other.z)
  end

  def *(t)
    self.class.new(x * t, y * t, z * t)
  end

  def /(t)
    self * (1 / t.to_f)
  end

  def length
    Math.sqrt(length_squared)
  end

  private def length_squared
    x**2 + y**2 + z**2
  end

  def to_s
    "#{x} #{y} #{z}"
  end
end

# Helpful aliases
Point3 = Vec3
Color = Vec3

if $0 == __FILE__
  require "minitest/autorun"

  class TestVec3 < Minitest::Test
    def test_initialize
      v = Vec3.new
      assert_equal 0.0, v.x
      assert_equal 0.0, v.y
      assert_equal 0.0, v.z

      v = Vec3.new(1,2,3)
      assert_equal 1, v.x
      assert_equal 2, v.y
      assert_equal 3, v.z
    end

    def test_comparison
      a = Vec3.new(1,2,3)
      b = Vec3.new(1,2,3)
      c = Vec3.new(3,2,1)

      assert a == b
      assert b == a
      assert b != c
      assert c != a
    end

    def test_negation
      a = Vec3.new(1,2,3)
      b = Vec3.new(-1,-2,-3)

      assert_equal(b, -a)
      assert_equal(a, -b)
      assert_equal(a, -(-a))
    end

    def test_addition
      a = Vec3.new(1,2,3)
      a += Vec3.new(1,2,3)

      assert_equal Vec3.new(2,4,6), a
      assert_equal Vec3.new(4,8,12), a + a
    end

    def test_multiplication
      a = Vec3.new(1,2,3)
      a *= 2

      assert_equal Vec3.new(2,4,6), a
      assert_equal Vec3.new(4,8,12), a * 2

      assert_raises(TypeError) do
        a * Vec3.new
      end
    end

    def test_division
      a = Vec3.new(2,4,6)
      a /= 2

      assert_equal Vec3.new(1,2,3), a
      assert_equal Vec3.new(1,2,3) / 2, Vec3.new(1 / 2.0, 2 / 2.0, 3 / 2.0)
      # assert_in_delta Vec3.new(1,2,3) / 10, Vec3.new(0.1, 0.2, 0.3), Vec3.new(0.1, 0.1, 0.1)
    end

    def test_length
      assert_equal Math.sqrt(3), Vec3.new(1,1,1).length
      assert_equal Math.sqrt(3), Vec3.new(-1,1,-1).length

      assert_equal Math.sqrt(14), Vec3.new(1,2,3).length
      assert_equal Math.sqrt(14), Vec3.new(1,-2,3).length
    end

    def test_to_s
      assert_equal "0.0 0.0 0.0", Vec3.new.to_s
      assert_equal "1.0 2.0 3.0", Vec3.new(1,2,3).to_s
    end
  end
end
