#!/usr/bin/env ruby

IMG_WIDTH = 256
IMG_HEIGHT = 256

print "P3\n#{IMG_WIDTH} #{IMG_HEIGHT}\n255\n"

(IMG_HEIGHT - 1).downto(0) do |j|
  0.upto(IMG_WIDTH - 1) do |i|
    r = i.to_f / (IMG_WIDTH - 1)
    g = j.to_f / (IMG_HEIGHT - 1)
    b = 0.25

    ir = (255.999 * r).to_i
    ig = (255.999 * g).to_i
    ib = (255.999 * b).to_i

    print "#{ir} #{ig} #{ib}\n"
  end
end
