require 'sinatra'
require 'json'
require_relative './classes/grid'
require_relative './classes/brain'
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
  bram = Snake.new(params['you'], params['snakes'])
  others = other_snakes(bram.id, params['snakes'])
  other_heads = others.map(&:head)
  # This is where the brain should check whether one snake is getting too good
  dead_space = obstacles(others, bram)
  food = closest_to_food(params['food'], bram.head, other_heads)
  move = next_move(bram, food, dead_space, params)
  { move: delta_direction(bram.head, move) }.to_json
end

private

def other_snakes(our_id, snakes)
  adversaries = []
  snakes.each do |s|
    adversaries.push(Snake.new(s['id'], snakes)) unless s['id'] == our_id
  end
  adversaries
end

def next_move(bram, food, dead_space, params)
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
  path ? path[1] : move_somewhere(bram, dead_space, astar, params)
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

def obstacles(others, bram)
  occupied = []
  others.each do |s|
    occupied += dangerous_snake_head(bram, s)
    occupied += s.body.drop(1)
  end
  occupied += bram.body[0...-1]
  occupied
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
def move_somewhere(bram, dead_space, astar, params)
  x = bram.head[0]
  y = bram.head[1]
  open_spot = []
  surrounding_cells_within_grid(x, y, params).each do |c|
    next if dead_space.include?(c) # do not under any circumstances move there
    open_spot.push(c)
    return c unless path_is_deadend?(bram, [bram.head, c], astar, dead_space)
  end
  open_spot.first # all are dead-ends so just pick an open spot
end

def surrounding_cells_within_grid(x, y, params)
  [[x, y + 1], [x + 1, y], [x, y - 1], [x - 1, y]].reject do |a, b|
    a.negative? || b.negative? || a >= params['width'] || b >= params['height']
  end
end
