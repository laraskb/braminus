require 'benchmark'
require 'spec_helper'
require 'rack/test'
require_relative '../web'
require 'json'

RSpec.describe 'Movement' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context 'looking for and dealing with food pathing scenarios' do
    it 'will not go at food if we would enter a dead-end' do
      expected = { move: 'down' }.to_json
      filename = './spec/fixtures/no_escape.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end

    it 'chooses the closest food' do
      expected = { move: 'down' }.to_json
      filename = './spec/fixtures/closest_food.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end

    it 'goes for food equidistant to her and a smaller snake' do
      expected = { move: 'right' }.to_json
      filename = './spec/fixtures/equidistant_to_food_with_short_snake.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end

    it 'does not bother going for food if equidistant longer snake' do
      expected = { move: 'up' }.to_json
      filename = './spec/fixtures/equidistant_to_food_with_long_snake.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end
  end

  context 'updating and dealing with dead-space concerns' do
    it 'updates the dead_space on tail checks' do
      expected = { move: 'down' }.to_json
      filename = './spec/fixtures/updated_deadspace.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end

    it 'knows that another snakes tail is not dead space' do
      expected = { move: 'right' }.to_json
      filename = './spec/fixtures/other_snake_tails.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end
  end

  context 'we have no path back to our tail at the moment' do
    it 'will move to an open space if it is trapped' do
      expected = { move: 'down' }.to_json
      filename = './spec/fixtures/trapped.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end

    it 'will move to an open space in another trapped scenario' do
      expected = { move: 'up' }.to_json
      filename = './spec/fixtures/trapped_again.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end

    it 'moves to an open space that allows it to get backs to its tail' do
      expected = { move: 'down' }.to_json
      filename = './spec/fixtures/move_choose_openspace_towards_tail.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end

    it 'favours a move into a possible head, not body' do
      expected = { move: 'left' }.to_json
      filename = './spec/fixtures/favour_possible_head_over_body.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end
  end

  context 'we should consider retreating; we may become trapped' do
    it 'moves towards tail when a different snake is closer to food' do
      expected = { move: 'right' }.to_json
      filename = './spec/fixtures/move_parameters_others.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end

    it 'moves towards tail when a longer snake could cut us off' do
      expected = { move: 'left' }.to_json
      filename = './spec/fixtures/move_longer_snake_head.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end
  end

  context 'when right beside an enemy snake' do
    it 'does not move into their body' do
      expected = { move: 'right' }.to_json
      filename = './spec/fixtures/beside_snake.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end

    it 'do not go for an attack on a bigger snake, brams' do
      expected = { move: 'down' }.to_json
      filename = './spec/fixtures/should_not_head_attack.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end
  end

  context 'does braminus need glasses? If she fails this test, then yes' do
    it 'does not move off the map, and instead moves into her tail' do
      expected = { move: 'up' }.to_json
      filename = './spec/fixtures/head_in_corner.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end
  end
end
