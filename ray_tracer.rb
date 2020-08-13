#!/usr/bin/env ruby

require_relative "vec3"
require_relative "ray"

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

def hit_sphere(center, radius, r)
  oc = r.origin - center
  a = Vec3.dot(r.direction, r.direction)
  b = 2.0 * Vec3.dot(oc, r.direction)
  c = Vec3.dot(oc, oc) - radius * radius
  discriminant = b * b - 4 * a * c

  discriminant > 0
end

def ray_color(r)
  return Color.new(1.0, 0.0, 0.0) if hit_sphere(Point3.new(0,0,-1), 0.5, r)

  unit_direction = r.direction.unit
  t = 0.5 * (unit_direction.y + 1.0)
  (1.0 - t) * Color.new(1.0, 1.0, 1.0) + t * Color.new(0.5, 0.7, 1.0)
end

ppm(IMAGE_WIDTH, IMAGE_HEIGHT) do |i, j|
  u = i.to_f / (IMAGE_WIDTH - 1)
  v = j.to_f / (IMAGE_HEIGHT - 1)
  r = Ray.new(ORIGIN, LOWER_LEFT_CORNER + u * HORIZONTAL + v * VERTICAL - ORIGIN)

  ray_color(r)
end
