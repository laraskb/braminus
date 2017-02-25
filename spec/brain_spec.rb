require 'spec_helper'
require_relative '../classes/brain'
require 'json'

describe "Braminus' Brain" do
  it 'reports the length of adversaries' do
    snakes = fixture('./spec/fixtures/snake_lengths.json')
    lengths = Brain.new.snake_lengths(JSON.parse(snakes)['snakes'])
    expect(lengths.length).to eq(2)
    expect(lengths.values[0]).to eq(3)
    expect(lengths.values[1]).to eq(5)
  end
end
