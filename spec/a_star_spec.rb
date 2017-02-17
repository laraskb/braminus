require 'spec_helper'
require './app/grid'
require './app/a_star'

describe 'A* algorithm' do
  it 'finds a simple path with no obstacles' do
    final_path = [[1, 0], [1, 1], [1, 2]]
    grid = Grid.new(4, 4, [])
    expect(AStar.new([1, 0], [1, 2], grid).search).to eq(final_path)
  end

  it 'finds a longer path with no obstacles' do
    final_path = [[3, 2], [3, 1], [2, 1], [1, 1], [0, 1]]
    grid = Grid.new(4, 4, [])
    expect(AStar.new([3, 2], [0, 1], grid).search).to eq(final_path)
  end

  it 'finds a path with a simple obstacle' do
    final_path = [[3, 2], [2, 2], [1, 2], [1, 1], [0, 1]]
    grid = Grid.new(4, 4, [[2, 1]])
    expect(AStar.new([3, 2], [0, 1], grid).search).to eq(final_path)
  end

  it 'finds a path with a bigger obstacle' do
    final_path = [[3, 2], [2, 2], [2, 3], [1, 3], [0, 3], [0, 2], [0, 1]]
    grid = Grid.new(4, 4, [[1, 0], [1, 1], [1, 2]])
    expect(AStar.new([3, 2], [0, 1], grid).search).to eq(final_path)
  end
end
