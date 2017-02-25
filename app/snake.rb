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

  private

  # The JSON representing the snake
  def snake(snakes, id)
    snakes.find { |s| s['id'] == id }
  end
end
