#!/usr/bin/env ruby

require_relative "core"

ASPECT_RATIO = 16.0 / 9.0
IMAGE_WIDTH = 400
IMAGE_HEIGHT = (IMAGE_WIDTH / ASPECT_RATIO).to_i
SAMPLES_PER_PIXEL = 20 # 100 samples takes ~2 minutes
MAX_DEPTH = 50

at_exit do
  world = HittableList.new
  world.push Sphere.new(Point3.new(0,0,-1), 0.5)
  world.push Sphere.new(Point3.new(0,-100.5,-1), 100)

  camera = Camera.new

  ppm(IMAGE_WIDTH, IMAGE_HEIGHT) do |i, j|
    pixel_color = Color.new(0,0,0)
    SAMPLES_PER_PIXEL.times do
      u = (i.to_f + rand) / (IMAGE_WIDTH - 1)
      v = (j.to_f + rand) / (IMAGE_HEIGHT - 1)
      r = camera.get_ray(u, v)
      pixel_color += ray_color(r, world, MAX_DEPTH)
    end

    pixel_color.to_s(SAMPLES_PER_PIXEL)
  end
end

def ppm(width, height)
  # Clear before printing status output
  # $stderr.print "\e[0;0H\e[K\e[0m"
  $stderr.print "\e[2J"

  # PPM header
  $stdout.puts "P3\n#{width} #{height}\n255"

  (height - 1).downto(0) do |j|
    $stderr.print "\e[0;0H"
    $stderr.print "\e[0;0HScanlines remaining: #{j}\e[K"
    $stderr.flush

    0.upto(width - 1) do |i|
      $stdout.puts yield i, j
    end
  end

  $stderr.print "\e[0;0H\e[KDone!\n"
end

def ray_color(r, world, depth)
  rec = Hittable::HitRecord.new
  return Color.new(0,0,0) if depth <= 0

  if world.hit(r, 0, Float::INFINITY, rec)
    target = rec.p + rec.normal + Vec3.random_in_unit_sphere
    0.5 * ray_color(Ray.new(rec.p, target - rec.p), world, depth - 1)
  else
    unit_direction = Vec3.unit(r.direction)
    t = 0.5 * (unit_direction.y + 1.0)
    (1.0 - t) * Color.new(1.0, 1.0, 1.0) + t * Color.new(0.5, 0.7, 1.0)
  end
end
