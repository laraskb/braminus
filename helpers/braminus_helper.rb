# Helps the Braminus class
module BraminusHelper
  UP = 'up'.freeze
  DOWN = 'down'.freeze
  LEFT = 'left'.freeze
  RIGHT = 'right'.freeze

  # Should we move UP, DOWN, LEFT, or RIGHT
  def delta_direction(head, next_node)
    dx = head[0] - next_node[0]
    return dx > 0 ? LEFT : RIGHT unless dx.zero?
    head[1] - next_node[1] > 0 ? DOWN : UP
  end

  def our_head(snakes, us)
    snakes.find { |s| s['id'] == us }['coords'].first
  end

  def our_tail(snakes, us)
    snakes.find { |s| s['id'] == us }['coords'].last
  end

  def our_health(snakes, us)
    snakes.find { |s| s['id'] == us }['health_points']
  end

  def distance(a, b)
    (a[0] - b[0]).abs + (a[1] - b[1]).abs
  end

  def parse_post(request)
    JSON.parse(request)
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
end
