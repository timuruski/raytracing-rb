#!/usr/bin/env ruby

require_relative "core"

ASPECT_RATIO = 3.0 / 2.0
IMAGE_WIDTH = 1200
IMAGE_HEIGHT = (IMAGE_WIDTH / ASPECT_RATIO).to_i
SAMPLES_PER_PIXEL = (ENV["SAMPLES"] || 1).to_i # 100 samples takes ~2 minutes
MAX_DEPTH = 50

at_exit do
  start_time = Time.now

  world = random_scene

  look_from = Point3.new(13,2,3)
  look_at = Point3.new(0,0,0)
  vup = Vec3.new(0,1,0)
  dist_to_focus = 10.0
  aperture = 0.1
  camera = Camera.new(look_from, look_at, vup, 20.0, ASPECT_RATIO, aperture, dist_to_focus)

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

def random_scene
  world = HittableList.new

  ground_material = Lambertian.new(Color.new(0.5, 0.5, 0.5))
  world.push Sphere.new(Point3.new(0,-1000,0), 1000.0, ground_material)

  -11.upto(10) do |a|
    -11.upto(10) do |b|
      choose_mat = rand
      center = Point3.new(a + 0.8 * rand, 0.2, b + 0.9 * rand)

      if (center - Point3.new(4, 0.2, 0)).length > 0.9
        if choose_mat < 0.8
          # diffuse
          albedo = Color.random * Color.random
          sphere_material = Lambertian.new(albedo)
          world.push Sphere.new(center, 0.2, sphere_material)
        elsif choose_mat < 0.95
          # metallic
          albedo = Color.random(0.5, 1)
          fuzz = rand(0.0..0.5)
          sphere_material = Metal.new(albedo, fuzz)
          world.push Sphere.new(center, 0.2, sphere_material)
        else
          # glass
          sphere_material = Dielectric.new(1.5)
          world.push Sphere.new(center, 0.2, sphere_material)
        end
      end
    end
  end

  material1 = Dielectric.new(1.5)
  world.push Sphere.new(Point3.new(0,1,0), 1.0, material1)

  material2 = Lambertian.new(Color.new(0.4,0.2,0.1))
  world.push Sphere.new(Point3.new(-4,1,0), 1.0, material2)

  material3 = Metal.new(Color.new(0.7,0.6,0.5), 0.0)
  world.push Sphere.new(Point3.new(4,1,0), 1.0, material3)

  world
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
