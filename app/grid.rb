# Represents where we can and cannot go
class Grid
  attr_accessor :height, :width
  def initialize(width, height)
    @width = width
    @height = height
  end
end
