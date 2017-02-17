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
  end

  post '/start' do
    params = parse_post(request.body.read)
    @game_id = params['game_id']
    @grid = Grid.new(params['width'], params['height'])
    { name: SNAKE_NAME, color: COLOUR }.to_json
  end

  post '/move' do
    params = parse_post(request.body.read)
    food = params['food'].first
    grid = Grid.new(params['width'], params['height']) # in here for the tests
    our_snake = params['you']
    head = params['snakes'].find { |s| s['id'] == our_snake }['coords'].first
    AStar.new(head, food, grid, find_obstacles(params['snakes'], head)).search
    { move: UP }.to_json
  end

  private

  def parse_post(request)
    JSON.parse(request)
  end

  def find_obstacles(snakes, head)
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
