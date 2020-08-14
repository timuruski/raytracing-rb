require_relative "vec3"

module Hittable
  HitRecord = Struct.new(:p, :normal, :t) do
    attr_reader :front_face

    def initialize(p = Point3.new, normal = Vec3.new, t = 0.0)
      super(p, normal, t)
    end

    def set_face_normal(r, outward_normal)
      @front_face = Vec3.dot(r.direction, outward_normal) < 0
      self.normal = @front_face ? outward_normal : -outward_normal
    end
  end

  def hit(r, t_min, t_max, rec)
    false
  end
end
