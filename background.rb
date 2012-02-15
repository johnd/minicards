require 'chunky_png'

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
    (0...x).each do |col|
      (0...y).each do |row|
        canvas[col,row] = random_colour
      end
    end
    self
  end

  def save(filename = "./test.png")
    canvas.save filename
  end

  private

  def random_colour
    ChunkyPNG::Color(ChunkyPNG::Color::PREDEFINED_COLORS.keys[rand(ChunkyPNG::Color::PREDEFINED_COLORS.keys.length)])
  end
end
