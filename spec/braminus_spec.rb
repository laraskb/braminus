require 'benchmark'
require 'spec_helper'
require 'rack/test'
require './app/braminus'
require 'json'

RSpec.describe Braminus do
  include Rack::Test::Methods

  def app
    Braminus
  end

  it 'responds to post at /start' do
    expected = { name: 'Braminus', color: '#8B008B' }.to_json
    post_data = { width: 20, height: 20, game_id: 'b1d-a112-4e0e' }.to_json
    within_limit(post('/start', post_data))
    expect(last_response.body).to eq(expected)
  end

  it 'responds to post at /move' do
    expected = { move: 'right' }.to_json
    post '/start', { width: 20, height: 20, game_id: 'b1d-a112-4e0e' }.to_json
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
end
