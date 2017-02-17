# Represents possible (closed or open set) nodes visited
class Node
  attr_accessor :coords, :f, :g, :neighbours, :parent
  def initialize(coords, h, grid, snakes, parent = nil)
    @coords = coords
    @grid = grid
    @parent = parent
    @g = parent.nil? ? 0 : parent.g + 1
    @f = g + h
    @neighbours = find_neighbours(snakes)
  end

  private

  def coords_within_grid(coords)
    (coords[0] >= 0 && coords[1] >= 0) &&
      (coords[0] < @grid.width && coords[1] < @grid.height)
  end

  # Returns array of possible neighbours (excludes obstacles)
  def find_neighbours(snakes)
    x = @coords[0]
    y = @coords[1]
    neighbours = [[x, y + 1], [x + 1, y], [x, y - 1], [x - 1, y]]
    neighbours.keep_if do |e|
      coords_within_grid(e) && !snakes.include?(e)
    end
  end
end
