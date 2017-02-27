require 'benchmark'
require 'spec_helper'
require 'rack/test'
require_relative '../web'
require 'json'

RSpec.describe 'Braminus' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'responds to post at /start' do
    expected = { name: 'Braminus', color: '#8B008B' }.to_json
    post_data = { width: 20, height: 20, game_id: 'b1d-a112-4e0e' }.to_json
    within_limit(post('/start', post_data))
    expect(last_response.body).to eq(expected)
  end

  it 'responds to post at /move' do
    expected = { move: 'right' }.to_json
    post '/start', { width: 4, height: 4, game_id: 'b1d-a112-4e0e' }.to_json
    within_limit(post('/move', fixture('./spec/fixtures/move_parameters.json')))
    expect(last_response.body).to eq(expected)
  end

  it 'moves towards tail when a different snake is closer to food' do
    expected = { move: 'right' }.to_json
    post '/start', { width: 20, height: 20, game_id: 'b1d-a112-4e0e' }.to_json
    filename = './spec/fixtures/move_parameters_others.json'
    within_limit(post('/move', fixture(filename)))
    expect(last_response.body).to eq(expected)
  end

  it 'moves towards tail when a longer snake could cut us off' do
    expected = { move: 'left' }.to_json
    post '/start', { width: 4, height: 5, game_id: 'b1d-a112-4e0e' }.to_json
    filename = './spec/fixtures/move_longer_snake_head.json'
    within_limit(post('/move', fixture(filename)))
    expect(last_response.body).to eq(expected)
  end

  it 'will not go at food if we would enter a dead-end' do
    expected = { move: 'down' }.to_json # TODO: wrong
    post '/start', { width: 4, height: 4, game_id: 'b1d-a112-4e0e' }.to_json
    filename = './spec/fixtures/no_escape.json'
    within_limit(post('/move', fixture(filename)))
    expect(last_response.body).to eq(expected)
  end

  it 'chooses the closest food' do
    expected = { move: 'down' }.to_json
    post '/start', { width: 4, height: 4, game_id: 'b1d-a112-4e0e' }.to_json
    filename = './spec/fixtures/closest_food.json'
    within_limit(post('/move', fixture(filename)))
    expect(last_response.body).to eq(expected)
  end

  it 'updates the dead_space on tail checks' do
    expected = { move: 'down' }.to_json
    post '/start', { width: 4, height: 5, game_id: 'b1d-a112-4e0e' }.to_json
    filename = './spec/fixtures/updated_deadspace.json'
    within_limit(post('/move', fixture(filename)))
    expect(last_response.body).to eq(expected)
  end

  it 'will move to an open space if it is trapped' do
    expected = { move: 'down' }.to_json
    post '/start', { width: 4, height: 4, game_id: 'b1d-a112-4e0e' }.to_json
    filename = './spec/fixtures/trapped.json'
    within_limit(post('/move', fixture(filename)))
    expect(last_response.body).to eq(expected)
  end

  it 'will move to an open space if it is trapped in a total way' do
    expected = { move: 'up' }.to_json
    post '/start', { width: 4, height: 4, game_id: 'b1d-a112-4e0e' }.to_json
    filename = './spec/fixtures/trapped_again.json'
    within_limit(post('/move', fixture(filename)))
    expect(last_response.body).to eq(expected)
  end
end
