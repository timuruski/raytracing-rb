Vec3 = Struct.new(:x, :y, :z) do
  def initialize(x = 0.0, y = 0.0, z = 0.0)
    super(x.to_f, y.to_f, z.to_f)
  end

  def -@
    self.class.new(-x, -y, -z)
  end

  def +(other)
    raise TypeError unless other.is_a? Vec3
    self.class.new(x + other.x, y + other.y, z + other.z)
  end

  def -(other)
    raise TypeError unless other.is_a? Vec3
    self.class.new(x - other.x, y - other.y, z - other.z)
  end

  def *(t)
    if t.is_a? Vec3
      self.class.new(x * t.x, y * t.y, z * t.z)
    else
      self.class.new(x * t, y * t, z * t)
    end
  end

  def /(t)
    self * (1 / t.to_f)
  end

  def length
    Math.sqrt(length_squared)
  end

  def length_squared
    x**2 + y**2 + z**2
  end

  # NOTE No pointers in Ruby, so this might be a way to fake them, very badly.
  def replace(c)
    self.x = c.x
    self.y = c.y
    self.z = c.z

    self
  end

  def self.dot(u, v)
    raise TypeError unless u.is_a?(Vec3) && v.is_a?(Vec3)

    (u.x * v.x) + (u.y * v.y) + (u.z * v.z)
  end

  def self.cross(u, v)
    raise TypeError unless u.is_a?(Vec3) && v.is_a?(Vec3)

    new(u.y * v.z - u.z * v.y,
        u.z * v.x - u.x * v.z,
        u.x * v.y - u.y * v.x)
  end

  def self.unit(v)
    v / v.length
  end

  def self.random(min = nil, max = nil)
    if min && max
      self.new(rand(min..max), rand(min..max), rand(min..max))
    else
      self.new(rand, rand, rand)
    end
  end

  def self.random_unit_vector
    a = rand(0.0..(2 * Math::PI))
    z = rand(-1.0..1.0)
    r = Math.sqrt(1 - z * z)

    Vec3.new(r * Math.cos(a), r * Math.sin(a), z)
  end

  def self.random_in_hemisphere(normal)
    in_unit_sphere = random_in_unit_sphere
    dot(in_unit_sphere, normal) > 0.0 ? in_unit_sphere : -in_unit_sphere
  end

  def self.random_in_unit_sphere
    loop do
      p = Vec3.random(-1.0, 1.0)
      return p if p.length_squared < 1
    end
  end

  def self.random_in_unit_disk
    loop do
      p = Vec3.new(rand(-1.0..1.0), rand(-1.0..1.0), 0)
      return p if p.length_squared < 1
    end
  end

  def self.reflect(v, n)
    v - 2 * dot(v, n) * n
  end

  def self.refract(uv, n, etai_over_etat)
    cos_theta = dot(-uv, n)
    r_out_perp = etai_over_etat * (uv + cos_theta * n)
    r_out_parallel = -Math.sqrt((1.0 - r_out_perp.length_squared()).abs) * n
    r_out_perp + r_out_parallel
  end

  def to_s
    "#{x} #{y} #{z}"
  end
end

# Helpful aliases
Point3 = Class.new(Vec3)

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

      assert_equal 20.0, Vec3.dot(a, b)
      assert_equal 20.0, Vec3.dot(b, a)

      assert_raises(TypeError) do
        Vec3.dot(a, 5.12)
      end

      assert_raises(TypeError) do
        Vec3.dot(5.12, b)
      end
    end

    def test_cross
      a = Vec3.new(1,2,3)
      b = Vec3.new(2,3,4)

      assert_equal Vec3.new(-1,2,-1), Vec3.cross(a, b)
      assert_equal Vec3.new(1,-2,1), Vec3.cross(b, a)

      assert_raises(TypeError) do
        Vec3.cross(a, 1.333)
      end

      assert_raises(TypeError) do
        Vec3.cross(1.333, b)
      end
    end

    def test_unit_vector
      a = Vec3.new(1,2,3)
      len = a.length

      assert_equal Vec3.new(1/len,2/len,3/len), Vec3.unit(a)
    end

    def test_to_s
      assert_equal "0.0 0.0 0.0", Vec3.new.to_s
      assert_equal "1.0 2.0 3.0", Vec3.new(1,2,3).to_s
    end
  end
end
