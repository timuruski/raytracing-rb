#!/usr/bin/env ruby

require_relative "vec3"

IMG_WIDTH = 256
IMG_HEIGHT = 256

def ppm(width, height)
  # Clear before printing status output
  # $stderr.print "\e[0;0H\e[K\e[0m"
  $stderr.print "\e[2J"

  # PPM header
  $stdout.puts "P3\n#{IMG_WIDTH} #{IMG_HEIGHT}\n255"

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

ppm(IMG_WIDTH, IMG_HEIGHT) do |i, j|
  Color.new(i.to_f / (IMG_WIDTH - 1), j.to_f / (IMG_HEIGHT - 1), 0.25)
end
