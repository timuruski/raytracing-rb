#!/usr/bin/env ruby

require_relative "core"

ASPECT_RATIO = 16.0 / 9.0
IMAGE_WIDTH = 400
IMAGE_HEIGHT = (IMAGE_WIDTH / ASPECT_RATIO).to_i

VIEWPORT_HEIGHT = 2.0
VIEWPORT_WIDTH = ASPECT_RATIO * VIEWPORT_HEIGHT
FOCAL_LENGTH = 1.0

ORIGIN = Point3.new(0,0,0)
HORIZONTAL = Vec3.new(VIEWPORT_WIDTH,0,0)
VERTICAL = Vec3.new(0,VIEWPORT_HEIGHT,0)
LOWER_LEFT_CORNER = ORIGIN - HORIZONTAL / 2 - VERTICAL / 2 - Vec3.new(0,0,FOCAL_LENGTH)

at_exit do
  world = HittableList.new
  world.push Sphere.new(Point3.new(0,0,-1), 0.5)
  world.push Sphere.new(Point3.new(0,-100.5,-1), 100)

  ppm(IMAGE_WIDTH, IMAGE_HEIGHT) do |i, j|
    u = i.to_f / (IMAGE_WIDTH - 1)
    v = j.to_f / (IMAGE_HEIGHT - 1)
    r = Ray.new(ORIGIN, LOWER_LEFT_CORNER + u * HORIZONTAL + v * VERTICAL - ORIGIN)

    ray_color(r, world)
  end
end

def ppm(width, height)
  # Clear before printing status output
  # $stderr.print "\e[0;0H\e[K\e[0m"
  $stderr.print "\e[2J"

  # PPM header
  $stdout.puts "P3\n#{IMAGE_WIDTH} #{IMAGE_HEIGHT}\n255"

  (height - 1).downto(0) do |j|
    $stderr.print "\e[0;0H"
    $stderr.puts "Scanlines remaining: #{j}"
    $stderr.flush

    0.upto(width - 1) do |i|
      $stdout.puts yield i, j
    end
  end

  $stderr.print "\e[0;0H\e[KDone!\n"
end

def ray_color(r, world)
  rec = Hittable::HitRecord.new
  if world.hit(r, 0, Float::INFINITY, rec)
    0.5 * Color(rec.normal + Color.new(1,1,1))
  else
    unit_direction = Vec3.unit(r.direction)
    t = 0.5 * (unit_direction.y + 1.0)
    (1.0 - t) * Color.new(1.0, 1.0, 1.0) + t * Color.new(0.5, 0.7, 1.0)
  end
end
