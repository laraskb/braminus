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
    head = @@moves[id].last || get_head(params['snakes'], params['you'])
    food = params['food'].first
    dead_space = obstacles(params['snakes'], head)
    path = AStar.new(head, food, @@grids[id], dead_space).search
    { move: delta_direction(head, path[1]) }.to_json
  end

  private

  def get_head(snakes, us)
    snakes.find { |s| s['id'] == us }['coords'].first
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
