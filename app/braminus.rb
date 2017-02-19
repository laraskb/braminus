#!/usr/bin/env ruby

require 'json'
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
    @@moves = Hash.new([])
    @@grids = {}
  end

  post '/start' do
    params = parse_post(request.body.read)
    @@moves[params['game_id']] = []
    @@grids[params['game_id']] = Grid.new(params['width'], params['height'])
    { name: SNAKE_NAME, color: COLOUR }.to_json
  end

  post '/move' do
    params = parse_post(request.body.read)
    id = params['game_id']
    our_snake = params['you']
    head = @@moves[id].last || our_head(params['snakes'], our_snake)
    food = params['food'].first
    dead_space = obstacles(params['snakes'], head)
    path = AStar.new(head, food, @@grids[id], dead_space).search
    # Move towards the tail if there was no path
    path = AStar.new(head, our_tail(params['snakes'], our_snake)) if path.nil?
    next_move = path ? path[1] : move_somewhere(head, obstactles)
    { move: delta_direction(head, next_move) }.to_json
  end

  private

  def our_head(snakes, us)
    snakes.find { |s| s['id'] == us }['coords'].first
  end

  def our_tail(snakes, us)
    snakes.find { |s| s['id'] == us }['coords'].last
  end

  def move_somewhere(head, obstacles)
    x = head[0]
    y = head[0]
    if !obstacles.include?([x, y + 1])
      return [x, y + 1]
    elsif !obstacles.include?([x + 1, y])
      return [x + 1, y]
    elsif !obstacles.include?([x, y - 1])
      return [x, y - 1]
    else
      return [x - 1, y]
    end
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
