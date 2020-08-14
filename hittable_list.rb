require_relative "hittable"

class HittableList
  include Hittable
  attr_reader :objects

  def initialize
    @objects = []
  end

  def push(obj)
    objects.push(obj)
  end

  def clear
    objects.clear
  end

  def hit(r, t_min, t_max, rec)
    hit_anything = false
    closest_so_far = t_max

    objects.each do |obj|
      if obj.hit(r, t_min, closest_so_far, rec)
        hit_anything = true
        closest_so_far = rec.t
      end
    end

    hit_anything
  end
end
