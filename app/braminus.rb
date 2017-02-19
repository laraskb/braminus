#!/usr/bin/env ruby

require 'json'
require './app/brain'
require './app/grid'
require './app/a_star'
require 'sinatra'

# The real deal BattleSnake 2017
class Braminus < Sinatra::Base
  SNAKE_NAME = 'Braminus'.freeze
  COLOUR = '#8B008B'.freeze
  UP = 'up'.freeze
  DOWN = 'down'.freeze
  LEFT = 'left'.freeze
  RIGHT = 'right'.freeze

  def initialize(*)
    super
    @@brains = {}
    @@grids = {}
    @@moves = Hash.new([])
  end

  post '/start' do
    params = parse_post(request.body.read)
    @@moves[params['game_id']] = []
    @@grids[params['game_id']] = Grid.new(params['width'], params['height'])
    @@brains[params['game_id']] = Brain.new
    { name: SNAKE_NAME, color: COLOUR }.to_json
  end

  post '/move' do
    params = parse_post(request.body.read)
    snake_id = params['you']
    game_id = params['game_id']
    head = @@moves[game_id].last || our_head(params['snakes'], snake_id)
    food = params['food'].first
    dead_space = obstacles(params['snakes'], head)
    move = next_move(snake_id, head, food, dead_space, params)
    { move: delta_direction(head, move) }.to_json
  end

  private

  def next_move(snake_id, head, food, dead_space, params)
    # astar = AStar.new
    game_id = params['game_id']
    path = AStar.new(head, food, @@grids[game_id], dead_space).search
    # Move towards the tail if there was no path
    if path.nil?
      tail = our_tail(params['snakes'], snake_id)
      path = AStar.new(head, tail, @@grids[game_id], dead_space).search
    end
    path ? path[1] : move_somewhere(head, dead_space)
  end

  def our_head(snakes, us)
    snakes.find { |s| s['id'] == us }['coords'].first
  end

  def our_tail(snakes, us)
    snakes.find { |s| s['id'] == us }['coords'].last
  end

  def move_somewhere(head, obstacles)
    x = head[0]
    y = head[0]
    return [x, y + 1] unless obstacles.include?([x, y + 1])
    return [x + 1, y] unless obstacles.include?([x + 1, y])
    return [x, y - 1] unless obstacles.include?([x, y - 1])
    [x - 1, y]
  end

  # Should we return UP, DOWN, LEFT, or RIGHT
  def delta_direction(head, next_node)
    dx = head[0] - next_node[0]
    return dx > 0 ? LEFT : RIGHT if dx.zero?
    head[1] - next_node[1] > 0 ? DOWN : UP
  end

  def parse_post(request)
    JSON.parse(request)
  end

  def obstacles(snakes, head)
    all_occupied = []
    snakes.each do |s|
      s['coords'].each do |c|
        all_occupied.push(c) if c != head
      end
    end
    all_occupied.uniq
  end

  run! if app_file == $PROGRAM_NAME
end
