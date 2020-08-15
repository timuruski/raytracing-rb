#!/usr/bin/env ruby

require_relative "core"

ASPECT_RATIO = 16.0 / 9.0
IMAGE_WIDTH = 400
IMAGE_HEIGHT = (IMAGE_WIDTH / ASPECT_RATIO).to_i
SAMPLES_PER_PIXEL = (ENV["SAMPLES"] || 5).to_i # 100 samples takes ~2 minutes
MAX_DEPTH = (ENV["DEPTH"] || 10).to_i # 50 Takes a long time

at_exit do
  start_time = Time.now

  r = Math.cos(Math::PI / 4)
  world = HittableList.new

  material_ground = Lambertian.new(Color.new(0.8, 0.8, 0.0))
  material_center = Lambertian.new(Color.new(0.1, 0.2, 0.5))
  material_left = Dielectric.new(1.5)
  material_right = Metal.new(Color.new(0.8, 0.6, 0.2), 0.0)

  world.push Sphere.new(Point3.new( 0.0, -100.5, -1.0), 100.0, material_ground)
  world.push Sphere.new(Point3.new( 0.0,    0.0, -1.0),   0.5, material_center)
  world.push Sphere.new(Point3.new(-1.0,    0.0, -1.0),   0.5, material_left)
  world.push Sphere.new(Point3.new(-1.0,    0.0, -1.0), -0.45, material_left)
  world.push Sphere.new(Point3.new( 1.0,    0.0, -1.0),   0.5, material_right)

  camera = Camera.new(Point3.new(-2, 2, 1), Point3.new(0,0,-1), Vec3.new(0,1,0), 20.0, ASPECT_RATIO)

  Renderer.new(IMAGE_WIDTH, IMAGE_HEIGHT).ppm do |i, j|
    pixel_color = Color.new(0,0,0)
    SAMPLES_PER_PIXEL.times do
      u = (i.to_f + rand) / (IMAGE_WIDTH - 1)
      v = (j.to_f + rand) / (IMAGE_HEIGHT - 1)
      r = camera.get_ray(u, v)
      pixel_color += ray_color(r, world, MAX_DEPTH)
    end

    pixel_color.to_s(SAMPLES_PER_PIXEL)
  end

  $stderr.print "\e[0;0H✨ Finished in #{duration(start_time)}!\e[K\n"
end

def ray_color(r, world, depth, attentuation = Color.new)
  rec = Hittable::HitRecord.new
  return Color.new(0,0,0) if depth <= 0

  if world.hit(r, 0.001, Float::INFINITY, rec)
    scattered = Ray.new

    scattered, attenuation, did_scatter = rec.material.scatter(r, rec, attenuation, scattered)
    if did_scatter
      attenuation * ray_color(scattered, world, depth - 1, attentuation)
    else
      Color.new(0,0,0)
    end
  else
    unit_direction = Vec3.unit(r.direction)
    t = 0.5 * (unit_direction.y + 1.0)
    (1.0 - t) * Color.new(1.0, 1.0, 1.0) + t * Color.new(0.5, 0.7, 1.0)
  end
end

def duration(start_time, finish_time = Time.now)
  diff = (finish_time.to_i - start_time.to_i)
  min, rest = diff.divmod(60)
  sec, _ = rest.divmod(1)

  "#{min} min, #{sec} sec"
end

class Renderer
  attr_reader :width, :height, :total

  def initialize(width, height)
    @width = width
    @height = height
    @total = width * height
  end

  def ppm
    # Clear before printing status output
    $stderr.print "\e[2J"

    # PPM header
    $stdout.puts "P3\n#{width} #{height}\n255"

    (height - 1).downto(0) do |j|
      0.upto(width - 1) do |i|
        start_time = Time.now
        $stdout.puts yield i, j

        $stderr.print progress(i, j, start_time)
        $stderr.flush
      end
    end
  end

  def progress(i, j, start_time)
    complete = (height - j) * width + (i + 1)
    percent = (complete.to_f / total.to_f * 100)
    remaining = (Time.now - start_time) * (total - complete)
    "\e[0;0H⏳ Rendering #{"%4.2f" % percent}%, estimated remaining: #{"%3d" % remaining} sec...\e[K"
  end
end
