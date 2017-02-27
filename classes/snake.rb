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

  private

  # The JSON representing the snake
  def snake(snakes, id)
    snakes.find { |s| s['id'] == id }
  end
end
