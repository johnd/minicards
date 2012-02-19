require 'chunky_png'
require 'chunky_png/rmagick'

class Background

  attr_reader :x, :y, :canvas

  def initialize(options = {})
    options = {:x => 874, :y => 378}.merge options
    @x = options[:x]
    @y = options[:y]
    @canvas = ChunkyPNG::Image.new(x,y,ChunkyPNG::Color::WHITE)
    self
  end

  def generate
    (0...x).to_a.keep_if {|n| n % 38 == 0 }.each do |col|
      (0...y).to_a.keep_if {|n| n % 27 == 0}.each do |row|
        colour = random_colour
        (col...col+38).each do |c|
          (row...row+27).each do |r|
            canvas[c,r] = colour
          end
        end
      end
    end
    rmagick_process
    self
  end

  def save(filename = "./test.png")
    canvas.save filename
  end

  private
  
  def rmagick_process
    image = ChunkyPNG::RMagick.export(canvas)
    image2 = image.radial_blur(45.0).adaptive_blur
    @canvas = ChunkyPNG::RMagick.import(image2).to_image
  end

  def random_colour
    ChunkyPNG::Color(ChunkyPNG::Color::PREDEFINED_COLORS.keys[rand(ChunkyPNG::Color::PREDEFINED_COLORS.keys.length)])
  end
end
