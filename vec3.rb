Vec3 = Struct.new(:x, :y, :z) do
  def initialize(x = 0.0, y = 0.0, z = 0.0)
    super(x.to_f, y.to_f, z.to_f)
  end

  def -@
    Vec3.new(-x, -y, -z)
  end

  def +(other)
    raise TypeError unless other.is_a? Vec3
    Vec3.new(x + other.x, y + other.y, z + other.z)
  end

  def -(other)
    raise TypeError unless other.is_a? Vec3
    Vec3.new(x - other.x, y - other.y, z - other.z)
  end

  def *(t)
    if t.is_a? Vec3
      Vec3.new(x * t.x, y * t.y, z * t.z)
    else
      Vec3.new(x * t, y * t, z * t)
    end
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

  def dot(other)
    raise TypeError unless other.is_a? Vec3
    (x * other.x) + (y * other.y) + (z * other.z)
  end

  def cross(other)
    raise TypeError unless other.is_a? Vec3
    Vec3.new(y * other.z - z * other.y,
             z * other.x - x * other.z,
             x * other.y - y * other.x)
  end

  def unit
    self / length
  end

  def to_s
    "#{x} #{y} #{z}"
  end
end

# Helpful aliases
Point3 = Class.new(Vec3)
Color = Class.new(Vec3) do
  def to_s
    r = (255.999 * x).to_i
    g = (255.999 * y).to_i
    b = (255.999 * z).to_i

    "#{r} #{g} #{b}"
  end
end

# Commutative multiply and divide for sclars and vectors.
module Vec3Math
  def *(other)
    other.is_a?(Vec3) ? other * self : super
  end

  def /(other)
    other.is_a?(Vec3) ? other / self : super
  end
end

class Integer
  prepend Vec3Math
end

class Float
  prepend Vec3Math
end

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

      assert_raises(TypeError) do
        a + 25.3
      end
    end

    def test_subtraction
      a = Vec3.new(1,2,3)
      a -= Vec3.new(2,4,6)

      assert_equal Vec3.new(-1,-2,-3), a
      assert_equal Vec3.new(0.5,0.5,0.5), Vec3.new(1,1,1) - Vec3.new(0.5,0.5,0.5)
      assert_equal Vec3.new(0.5,0.5,0.5), Vec3.new(1,1,1) - Vec3.new(0.5,0.5,0.5)

      assert_raises(TypeError) do
        a - 17.8
      end
    end

    def test_multiplication
      a = Vec3.new(1,2,3)
      a *= 2

      assert_equal Vec3.new(2,4,6), a
      assert_equal Vec3.new(4,8,12), a * 2

      assert_equal Vec3.new(4,8,12), 2 * a
      assert_equal Vec3.new(4,8,12), 2.0 * a
    end

    def test_vector_multiplication
      a = Vec3.new(1,2,3)
      b = Vec3.new(2,3,4)

      assert_equal Vec3.new(2,6,12), a * b
    end

    def test_division
      a = Vec3.new(2,4,6)
      a /= 2

      assert_equal Vec3.new(1,2,3), a

      assert_equal Vec3.new(1/2.0, 1/2.0, 1/2.0), Vec3.new(1,1,1) / 2.0
      assert_equal Vec3.new(1/2.0, 1/2.0, 1/2.0), 2.0 / Vec3.new(1,1,1)
      # assert_in_delta Vec3.new(1,2,3) / 10, Vec3.new(0.1, 0.2, 0.3), Vec3.new(0.1, 0.1, 0.1)
    end

    def test_length
      assert_equal Math.sqrt(3), Vec3.new(1,1,1).length
      assert_equal Math.sqrt(3), Vec3.new(-1,1,-1).length

      assert_equal Math.sqrt(14), Vec3.new(1,2,3).length
      assert_equal Math.sqrt(14), Vec3.new(1,-2,3).length
    end

    def test_dot
      a = Vec3.new(1,2,3)
      b = Vec3.new(2,3,4)

      assert_equal 20.0, a.dot(b)
      assert_equal 20.0, b.dot(a)

      assert_raises(TypeError) do
        a.dot(5.12)
      end
    end

    def test_cross
      a = Vec3.new(1,2,3)
      b = Vec3.new(2,3,4)

      assert_equal Vec3.new(-1,2,-1), a.cross(b)
      assert_equal Vec3.new(1,-2,1), b.cross(a)

      assert_raises(TypeError) do
        a.cross(1.333)
      end
    end

    def test_unit_vector
      a = Vec3.new(1,2,3)
      len = a.length

      assert_equal Vec3.new(1/len,2/len,3/len), a.unit
    end

    def test_to_s
      assert_equal "0.0 0.0 0.0", Vec3.new.to_s
      assert_equal "1.0 2.0 3.0", Vec3.new(1,2,3).to_s
    end
  end
end
