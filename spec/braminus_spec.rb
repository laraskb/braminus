require 'benchmark'
require 'spec_helper'
require 'rack/test'
require_relative '../web'
require 'json'

RSpec.describe 'Braminus Web App' do
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
    within_limit(post('/move', fixture('./spec/fixtures/move_parameters.json')))
    expect(last_response.body).to eq(expected)
  end
end
