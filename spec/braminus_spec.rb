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
    post '/start', { width: 20, height: 20, game_id: 'b1d-a112-4e0e' }.to_json
    expect(last_response.body).to eq(expected)
  end

  it 'responds to post at /move' do
    expected = { move: 'right' }.to_json
    post '/start', { width: 20, height: 20, game_id: 'b1d-a112-4e0e' }.to_json
    path = File.expand_path('./spec/fixtures/move_parameters.json')
    post '/move', File.read(path)
    expect(last_response.body).to eq(expected)
  end
end
