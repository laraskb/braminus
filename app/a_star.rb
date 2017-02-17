require './app/grid'
require './app/node'

# Implements the A* pathfinding algorithm
class AStar
  def initialize(origin, destination, grid)
    @g = 0 # distance from origin
    distance_to_destination = distance(origin, destination)
    @grid = grid
    @open_set = [Node.new(origin, @g, distance_to_destination, @grid)]
    @closed_set = []
    @origin = origin
    @destination = destination
  end

  # The A* search function
  # => All spaces occupied by snakes are considered obstacles
  def search
    until @open_set.empty?
      current = @open_set.min_by(&:f) # get node with the smallest f cost
      @open_set.delete(current)
      @closed_set.push(current)
      return construct_path(current) if current.coords == @destination # we win
      update_neighbours(current)
    end
  end

  private

  # Distance (dx + dy) between two points
  def distance(a, b)
    (a[0] + b[0]).abs + (a[1] + b[1]).abs
  end

  # Array of coordinates showing the final path
  def construct_path(node)
    path = [node.coords]
    loop do
      node = node.parent
      path.push(node.coords)
      return path.reverse if node.parent.nil? # Origin node has nil parent
    end
  end

  # Calculates the f cost (g + h) of the neighbour node
  def calculate_costs(neighbour, coords, current)
    h = distance(coords, @destination)
    if neighbour.nil? # we have not seen this node before
      neighbour = Node.new(coords, current.g + 1, h, @grid, current)
      @open_set.push(neighbour)
    elsif neighbour.f > ((current.g + 1) + h) # we have found a shorter path
      neighbour.f = (current.g + 1) + h
      neighbour.parent = current
    end
  end

  # Update the f cost for all neighbours of a node
  def update_neighbours(current)
    current.neighbours.each do |e|
      next if @closed_set.any? { |n| n.coords == e } # already checked the node
      neighbour ||= @open_set.find { |n| n.coords == e }
      calculate_costs(neighbour, e, current)
    end
  end
end
