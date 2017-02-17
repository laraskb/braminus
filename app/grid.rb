# Represents where we can and cannot go
class Grid
  attr_accessor :height, :snakes, :width
  def initialize(width, height, snakes)
    @width = width
    @height = height
    @snakes = snakes
  end
end
