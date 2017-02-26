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
  # This is where the brain should check whether one snake is getting too good
  dead_space, other_heads = obstacles_and_heads(others, bram)
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
  path ? path[1] : move_somewhere(bram.head, dead_space)
end

def path_is_deadend?(bram, path, astar, dead_space)
  body = bram.possible_body(path)
  # Forget about our old body
  new_dead_space = update_deadspace(bram.body, body, dead_space)
  astar.search(body.first, body.last, new_dead_space).nil?
end

def update_deadspace(actual, possible, dead_space)
  dead_space - (actual[0...-1] - possible[0...-1])
end

def closest_to_food(food, our_head, other_heads)
  return food.first if other_heads.nil? # for test cases
  closest = 9999 # not "correct" obviously
  desired = nil
  food.each do |dot|
    our_distance = distance(dot, our_head)
    their_delta = other_heads.collect { |e| distance(dot, e) }
    if (their_delta.empty? || (our_distance < their_delta.sort.min)) &&
       our_distance < closest
      closest = our_distance
      desired = dot
    end
  end
  desired.nil? ? nil : desired
end

# Array of possible locations a snake with a larger head could be next turn
def dangerous_snake_head(nodes, length, their_length)
  their_length >= length ? possibles(nodes[0], nodes[1]) : []
end

def obstacles_and_heads(others, bram)
  occupied = []
  other_heads = []
  others.each do |s|
    occupied += dangerous_snake_head(s.body, bram.length, s.length)
    other_heads.push(s.head)
    occupied += s.body.drop(1)
  end
  occupied += bram.body[0...-1]
  [occupied, other_heads]
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

def possibles(snake_head, body)
  x = snake_head[0]
  y = snake_head[1]
  dx = snake_head[0] - body[0]
  dy = snake_head[1] - body[1]
  possible_moves(x, y, dx, dy)
end

# Given a snakes head and body positions, where could it move
def possible_moves(x, y, dx, dy)
  return [[x - 1, y], [x, y + 1], [x, y - 1]] if dx > 0
  return [[x + 1, y], [x, y + 1], [x, y - 1]] if dx < 0
  return [[x + 1, y], [x, y + 1], [x - 1, y]] if dy > 0
  [[x + 1, y], [x, y - 1], [x - 1, y]]
end

# Just don't move into a wall
def move_somewhere(head, obstacles)
  x = head[0]
  y = head[1]
  return [x, y + 1] unless obstacles.include?([x, y + 1])
  return [x + 1, y] unless obstacles.include?([x + 1, y])
  return [x, y - 1] unless obstacles.include?([x, y - 1])
  [x - 1, y]
end
