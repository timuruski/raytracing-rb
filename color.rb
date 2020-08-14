require_relative "vec3"

Color = Class.new(Vec3) do
# void write_color(std::ostream &out, color pixel_color, int samples_per_pixel) {
#     auto r = pixel_color.x();
#     auto g = pixel_color.y();
#     auto b = pixel_color.z();

#     // Divide the color by the number of samples.
#     auto scale = 1.0 / samples_per_pixel;
#     r *= scale;
#     g *= scale;
#     b *= scale;

#     // Write the translated [0,255] value of each color component.
#     out << static_cast<int>(256 * clamp(r, 0.0, 0.999)) << ' '
#         << static_cast<int>(256 * clamp(g, 0.0, 0.999)) << ' '
#         << static_cast<int>(256 * clamp(b, 0.0, 0.999)) << '\n';
# }


  def to_s(samples = 1)
    scale = 1.0 / samples
    r = (256 * (x * scale).clamp(0.0, 0.999)).to_i
    g = (256 * (y * scale).clamp(0.0, 0.999)).to_i
    b = (256 * (z * scale).clamp(0.0, 0.999)).to_i

    "#{r} #{g} #{b}"
  end
end

def Color(v)
  Color.new(v.x, v.y, v.z)
end
