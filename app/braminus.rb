#!/usr/bin/env ruby

require 'json'
require './app/brain'
require './app/grid'
require './app/snake'
require './app/a_star'
require './helpers/braminus_helper'
require 'sinatra'

# The real deal BattleSnake 2017
class Braminus < Sinatra::Base
  include BraminusHelper

  SNAKE_NAME = 'Braminus'.freeze
  COLOUR = '#8B008B'.freeze

  def initialize(*)
    super
    @@brains = {}
    @@grids = {}
    @@moves = Hash.new([])
    @@our_lengths = {}
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
    game_id = params['game_id']
    bram = Snake.new(params['you'], params['snakes'])
    others = other_snakes(bram.id, params['snakes'])
    # This is where the brain should check whether one snake is getting too good
    dead_space, other_heads = obstacles_and_heads(others, bram)
    food = closest_to_food(params['food'], bram.head, other_heads)
    move = next_move(bram, food, dead_space, params)
    @@moves[game_id].push(move)
    { move: delta_direction(bram.head, move) }.to_json
  end

  private

  def other_snakes(our_id, snakes)
    adversaries = []
    snakes.each do |s|
      adversaries.push(Snake.new(s['id'], snakes)) unless s['id'] == our_id
    end
    adversaries
  end

  def next_move(bram, food, dead_space, params)
    game_id = params['game_id']
    astar = AStar.new(@@grids[game_id], dead_space)
    path = astar.search(bram.head, food)
    if path.nil?
      # No path to food, move to the tail
      path = astar.search(bram.head, bram.tail)
    elsif path_is_deadend?(bram, path, astar)
      # Don't move into a deadend to get to the food
      path = nil
    end
    # Possibly need another check to make sure this doesn't deadend
    path ? path[1] : move_somewhere(bram.head, dead_space)
  end

  def path_is_deadend?(bram, path, astar)
    body = bram.possible_body(path)
    astar.search(body.first, body.last).nil?
  end

  def closest_to_food(food, our_head, other_heads)
    return food.first if other_heads.nil? # for test cases
    food.each do |dot|
      our_distance = distance(dot, our_head)
      their_delta = other_heads.collect { |e| distance(dot, e) }
      return dot if their_delta.empty? || (our_distance < their_delta.sort.min)
    end
    nil
  end

  # Array of possible locations a snake with a larger head could be next turn
  def dangerous_snake_head(nodes, length, their_length)
    their_length >= length ? possibles(nodes[0], nodes[1]) : []
  end

  def obstacles_and_heads(others, bram)
    occupied = []
    other_heads = []
    others.each do |s|
      occupied += dangerous_snake_head(s.body, bram.length, s.length)
      other_heads.push(s.head)
      occupied += s.body.drop(1)
    end
    occupied += bram.body[0...-1]
    [occupied, other_heads]
  end

  run! if app_file == $PROGRAM_NAME
end
