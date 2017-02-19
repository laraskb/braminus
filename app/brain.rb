# How Braminus gets her smarts
class Brain
  def initialize
  end

  def snake_lengths(snakes)
    snake_lengths = {}
    snakes.each do |s|
      snake_lengths[s['id']] = s['coords'].length
    end
    snake_lengths
  end
end
