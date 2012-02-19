require 'chunky_png'
require 'chunky_png/rmagick'

class VoronoiDiagram

  attr_reader :_max_x, :_max_y, :_point_cbs

  def initialize()
    @_point_cbs = {}
    @_max_x  = 0
    @_max_y  = 0
  end

  def colourPoint( x, y )
    @_max_x = [ x, _max_x ].max
    @_max_y = [ y, _max_y ].max
    @_point_cbs[ [ x, y] ] = lambda { |colour, canvas| canvas[x, y] = colour }
    self
  end

  def render( canvas )
    vpoints = make_points( _max_x, _max_y )
    _point_cbs.each { | coords, point_cb |
      point_cb.call( sort_by_distance( coords, vpoints )[0][:colour], canvas )
    }
    canvas
  end

  private

  def make_points( x, y, count = 0 )
    count = x/40 * y/40 if count == 0
    return (0...count).to_a.map { { :point => [ rand(x), rand(y) ], :colour => random_colour } }
  end

  def sort_by_distance( src, vpoints ) # ARGGG SO SLOW
    vpoints.each { | vpoint |
      vpoint[:dist] = (src[0]-vpoint[:point][0])**2 + (src[1]-vpoint[:point][1])**2
    }.sort_by { | vpoint | vpoint[:dist] }
  end

  def random_colour
    known_colours = ChunkyPNG::Color::PREDEFINED_COLORS.keys
    ChunkyPNG::Color( known_colours.sample )
  end

end

class BigPixel
  attr_reader :_max_x, :_max_y, :_point_cbs, :width, :height

  def initialize( options = {} )
    options = {
      :width  => 23,
      :height => 14,
    }.merge options
    @_point_cbs = {}
    @_max_x  = 0
    @_max_y  = 0
    @width   = options[ :width ]
    @height  = options[ :height ]
  end

  def colourPoint( x, y )
    @_max_x = [ x, _max_x ].max
    @_max_y = [ y, _max_y ].max
    @_point_cbs[ [ x, y] ] = lambda { |colour, canvas| canvas[x, y] = colour }
    self
  end

  def render( canvas )
    pixels = Hash.new { | hash, key | hash[ key ] = random_colour } # lazy
    haspect = (_max_x+1) / width # fencepost, _max_x is max x co-ord, not width in pixels
    vaspect = (_max_y+1) / height
    _point_cbs.each { | coords, point_cb |
      point_cb.call( pixels[ [ coords[0]/haspect, coords[1]/vaspect] ], canvas )
    }
    canvas
  end

  def random_colour
    known_colours = ChunkyPNG::Color::PREDEFINED_COLORS.keys
    ChunkyPNG::Color( known_colours.sample )
  end

end

class BlurredBigPixel < BigPixel

  def render( canvas )
    rmagick_process( super )
  end

  private

  def rmagick_process( canvas )
    image = ChunkyPNG::RMagick.export(canvas)
    image2 = image.radial_blur(45.0).adaptive_blur
    return ChunkyPNG::RMagick.import(image2).to_image
  end

end

class Background

  attr_reader :x, :y, :canvas, :generator

  def initialize(options = {})
    options = {
        :x      => 874,
        :y      => 378,
    }.merge options
    @x         = options[:x]
    @y         = options[:y]
    @canvas    = options[:canvas] || ChunkyPNG::Image.new( x, y, ChunkyPNG::Color::WHITE )
    @generator = options[:generator]
    self
  end

  def generate
    (0...x).to_a.map { |xx| (0...y).to_a.map { |yy| generator.colourPoint( xx, yy ) } }
    @canvas = generator.render( @canvas )
    self
  end

  def save(filename = "./test.png")
    @canvas.save filename
  end

end
