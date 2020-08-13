#!/usr/bin/env ruby

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
      r, g, b = yield i, j

      $stdout.puts "#{r} #{g} #{b}"
    end
  end

  $stderr.print "\e[0;0H\e[KDone!\n"
end

ppm(IMG_WIDTH, IMG_HEIGHT) do |i, j|
  r = i.to_f / (IMG_WIDTH - 1)
  g = j.to_f / (IMG_HEIGHT - 1)
  b = 0.25

  ir = (255.999 * r).to_i
  ig = (255.999 * g).to_i
  ib = (255.999 * b).to_i

  [ir, ig, ib]
end
