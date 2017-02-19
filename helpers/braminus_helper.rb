# Helps the Braminus class
module BraminusHelper
  UP = 'up'.freeze
  DOWN = 'down'.freeze
  LEFT = 'left'.freeze
  RIGHT = 'right'.freeze

  # Should we move UP, DOWN, LEFT, or RIGHT
  def delta_direction(head, next_node)
    dx = head[0] - next_node[0]
    return dx > 0 ? LEFT : RIGHT if dx.zero?
    head[1] - next_node[1] > 0 ? DOWN : UP
  end

  def our_head(snakes, us)
    snakes.find { |s| s['id'] == us }['coords'].first
  end

  def our_tail(snakes, us)
    snakes.find { |s| s['id'] == us }['coords'].last
  end

  def distance(a, b)
    (a[0] - b[0]).abs + (a[1] - b[1]).abs
  end

  def parse_post(request)
    JSON.parse(request)
  end

  # Given a snakes head and body positions, where could it move
  def possible_moves(x, y, dx, dy)
    arr = []
    arr.push(
      if dx > 0
        [[x - 1, y], [x, y + 1], [x, y - 1]]
      elsif dx < 0
        [[x + 1, y], [x, y + 1], [x, y - 1]]
      elsif dy > 0
        [[x + 1, y], [x, y + 1], [x - 1, y]]
      else
        [[x + 1, y], [x, y - 1], [x - 1, y]]
      end
    )
    arr
  end
end
