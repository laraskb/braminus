# Represents a snake
class Snake
  attr_reader :id, :body, :head, :tail, :health, :length

  def initialize(id, snakes)
    @id = id
    @snake_info = snake(snakes, id)
    @body = @snake_info['coords']
    @head = @snake_info['coords'].first
    @tail = @snake_info['coords'].last
    @health = @snake_info['health_points']
    @length = @body.length # Bad OO?
  end

  # After a move, this is what the body would be
  def possible_body(path)
    if @length > path.length
      path.reverse + @body.drop(1).first(@length - path.length)
    elsif @length < path.length
      path.last(@length)
    else
      path
    end
  end

  def possible_heads
    x = @head[0]
    y = @head[1]
    dx = x - @body[1][0]
    dy = y - @body[1][1]
    possible_moves(x, y, dx, dy)
  end

  private

  # Given a snakes head and body positions, where could it move
  def possible_moves(x, y, dx, dy)
    return [[x - 1, y], [x, y + 1], [x, y - 1]] if dx > 0
    return [[x + 1, y], [x, y + 1], [x, y - 1]] if dx < 0
    return [[x + 1, y], [x, y + 1], [x - 1, y]] if dy > 0
    [[x + 1, y], [x, y - 1], [x - 1, y]]
  end

  # The JSON representing the snake
  def snake(snakes, id)
    snakes.find { |s| s['id'] == id }
  end
end
