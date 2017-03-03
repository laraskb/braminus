require 'benchmark'
require 'spec_helper'
require 'rack/test'
require_relative '../web'
require 'json'

RSpec.describe 'Head Attacks' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context 'enemy shares one possible head location with us' do
    it 'will move into that one head location' do
      # moves into the 1 possible head location (the other snake is not forced)
      expected = { move: 'up' }.to_json
      filename = './spec/fixtures/attack_basic.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end
  end

  context 'enemy head is touching its own tail' do
    it 'will move into enemy tail, under assumption they will move there' do
      # Enemy head and tail are touching
      expected = { move: 'up' }.to_json
      filename = './spec/fixtures/attack_basic_two.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end
  end

  context 'enemy head and tail are seperated; there exists a path btwn them' do
    it 'cuts off the shortest path from their head to tail' do
      # Enemy head and tail are touching
      expected = { move: 'right' }.to_json
      filename = './spec/fixtures/attack_basic_three.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end

    it 'chooses head attack when enemy head is 3 spaces from tail' do
      # There is also food nearby
      expected = { move: 'right' }.to_json
      filename = './spec/fixtures/basic_attack_three_extra.json'
      within_limit(post('/move', fixture(filename)))
      expect(last_response.body).to eq(expected)
    end
  end
end
