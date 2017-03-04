require 'sinatra'
require 'json'
require_relative './classes/grid'
require_relative './classes/snake'
require_relative './classes/a_star'

SNAKE_NAME = 'Braminus'.freeze
COLOUR = '#8B008B'.freeze
UP = 'up'.freeze
DOWN = 'down'.freeze
LEFT = 'left'.freeze
RIGHT = 'right'.freeze

post '/start' do
  { name: SNAKE_NAME, color: COLOUR }.to_json
end

post '/move' do
  params = JSON.parse(request.body.read)
  grid = Grid.new(params['width'], params['height'])
  bram = Snake.new(params['you'], params['snakes'])
  others = other_snakes(bram.id, params['snakes'])
  other_heads = others.map(&:head)
  bodies, possible_heads = obstacles_and_possible_heads(others, bram)
  dead_space = bodies + possible_heads
  prey = possible_kill(bram, others, grid, dead_space)
  return { move: delta_direction(bram.head, prey) }.to_json unless prey.nil?
  # This is where the brain should check whether one snake is getting too good
  food = closest_to_food(params['food'], bram.head, other_heads)
  move = next_move(bram, others, food, params, bodies, possible_heads)
  { move: delta_direction(bram.head, move) }.to_json
end

private

# Check if we could move into the next head location of a snake
# Only finds one snake at the moment!
def possible_kill(bram, others, grid, dead_space)
  smaller_snakes = others.find_all { |s| s.length < bram.length }
  prey = smaller_snakes.detect { |s| distance(s.head, bram.head) == 2 }
  return nil if prey.nil? # no suitable snakes to kill
  astar = AStar.new(grid, dead_space)
  tailpath = astar.search(prey.head, prey.tail) # enemy path head to tail
  unless tailpath.nil? || !killzone?(bram, tailpath[1][0], tailpath[1][1], grid)
    return tailpath[1]
  end
  # We need to cut off their "head", their tail isn't "in the picture"
  # Try and get lucky!
  possible = prey.possible_heads.reject do |a, b|
    killzone?(bram, a, b, grid)
  end
  possible.first
end

def killzone?(bram, a, b, grid)
  (a.negative? || b.negative? || a >= grid.width || b >= grid.height) ||
    (distance(bram.head, [a, b]) > 1)
end

def other_snakes(our_id, snakes)
  adversaries = []
  snakes.each do |s|
    adversaries.push(Snake.new(s['id'], snakes)) unless s['id'] == our_id
  end
  adversaries
end

def next_move(bram, others, food, params, bodies, possible_heads)
  # We should consider possible heads dead at first
  dead_space = bodies + possible_heads
  astar = AStar.new(Grid.new(params['width'], params['height']), dead_space)
  path = astar.search(bram.head, food)
  if path.nil?
    # No path to food, move to the tail
    path = astar.search(bram.head, bram.tail)
  elsif path_is_deadend?(bram, path, astar, dead_space)
    # Don't move into a deadend to get to the food
    path = nil
  end
  # Possibly need another check to make sure this doesn't deadend
  path ? path[1] : best_move(bram, bodies, possible_heads, astar, params)
end

def path_is_deadend?(bram, path, astar, dead_space)
  body = bram.possible_body(path)
  # Forget about our old body
  new_dead_space = update_deadspace(bram.body, body, dead_space)
  astar.search(body.first, body.last, new_dead_space).nil?
end

def update_deadspace(actual, possible, dead_space)
  (dead_space - (actual - possible))[0...-1]
end

def closest_to_food(food, our_head, other_heads)
  return food.first if other_heads.nil? # for test cases
  closest = 9999 # not "correct" obviously
  desired = nil
  food.each do |dot|
    our_distance = distance(dot, our_head)
    their_delta = other_heads.collect { |e| distance(dot, e) }
    next unless (their_delta.empty? || (our_distance < their_delta.sort.min)) &&
                (our_distance < closest)
    closest = our_distance
    desired = dot
  end
  desired.nil? ? nil : desired
end

# Array of possible locations a snake with a larger head could be next turn
def dangerous_snake_head(bram, other_snake)
  other_snake.length >= bram.length ? other_snake.possible_heads : []
end

# occupied is solely bodies
def obstacles_and_possible_heads(others, bram)
  occupied = []
  possible_heads = []
  others.each do |s|
    possible_heads += dangerous_snake_head(bram, s)
    occupied += s.body.drop(1)[0...-1]
  end
  occupied += bram.body[0...-1]
  [occupied, possible_heads]
end

# Should we move UP, DOWN, LEFT, or RIGHT
def delta_direction(head, next_node)
  dx = head[0] - next_node[0]
  return dx > 0 ? LEFT : RIGHT unless dx.zero?
  head[1] - next_node[1] > 0 ? UP : DOWN
end

def distance(a, b)
  (a[0] - b[0]).abs + (a[1] - b[1]).abs
end

# Just don't move into a wall or box yourself in
def best_move(bram, bodies, possible_heads, astar, params)
  dead_space = bodies + possible_heads
  x = bram.head[0]
  y = bram.head[1]
  open_spot = []
  open_possible_head = [] # These are possibly open, and our second best choice
  path_back_to_tail = []
  surrounding_cells_within_grid(x, y, params).each do |c|
    next if bodies.include?(c) # do not under any circumstances move there
    possible_heads.include?(c) ? open_possible_head.push(c) : open_spot.push(c)
    unless path_is_deadend?(bram, [bram.head, c], astar, dead_space)
      path_back_to_tail.push(c)
    end
    # If it's open and opens a path back to the tail take it
    return c if open_spot.include?(c) && path_back_to_tail.include?(c)
  end
  if open_spot.empty?
    open_possible_head.first
  else
    open_spot.first # all are dead-ends so just pick an open spot
  end
end

def surrounding_cells_within_grid(x, y, params)
  [[x, y + 1], [x + 1, y], [x, y - 1], [x - 1, y]].reject do |a, b|
    a.negative? || b.negative? || a >= params['width'] || b >= params['height']
  end
end
