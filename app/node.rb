# Represents possible (closed or open set) nodes visited
class Node
  attr_accessor :coords, :f, :g, :neighbours, :parent
  def initialize(coords, g, h, grid, parent = nil)
    @coords = coords
    @g = g
    @grid = grid
    @f = g + h
    @parent = parent
    @neighbours = find_neighbours
  end

  private

  def coords_within_grid(coords)
    (coords[0] >= 0 && coords[1] >= 0) &&
      (coords[0] < @grid.width && coords[1] < @grid.height)
  end

  # Returns array of possible neighbours (excludes obstacles)
  def find_neighbours
    x = @coords[0]
    y = @coords[1]
    neighbours = [[x, y + 1], [x + 1, y], [x, y - 1], [x - 1, y]]
    neighbours.keep_if do |e|
      coords_within_grid(e) && !@grid.snakes.include?(e)
    end
  end
end
