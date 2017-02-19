#!/usr/bin/env ruby

require 'json'
require './app/brain'
require './app/grid'
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
    @@our_lengths[params['game_id']] = 3
    { name: SNAKE_NAME, color: COLOUR }.to_json
  end

  post '/move' do
    params = parse_post(request.body.read)
    snake_id = params['you']
    game_id = params['game_id']
    head = @@moves[game_id].last || our_head(params['snakes'], snake_id)
    snake_lengths = @@brains[game_id].snake_lengths(params['snakes'])
    dead_space, other_heads = obstacles_and_heads(params['snakes'],
                                                  head,
                                                  @@our_lengths[game_id],
                                                  snake_lengths)
    food = closest_to_food(params['food'], head, other_heads)
    move = next_move(snake_id, head, food, dead_space, params)
    { move: delta_direction(head, move) }.to_json
  end

  private

  def next_move(snake_id, head, food, dead_space, params)
    game_id = params['game_id']
    astar = AStar.new(@@grids[game_id], dead_space)
    path = astar.search(head, food)
    path = astar.search(head, our_tail(params['snakes'], snake_id)) if path.nil?
    path ? path[1] : move_somewhere(head, dead_space)
  end

  def closest_to_food(food, our_head, other_heads)
    return food.first if other_heads.nil?
    food.each do |dot|
      our_distance = distance(dot, our_head)
      their_delta = other_heads.collect { |e| distance(dot, e) }
      return dot if their_delta.empty? || (our_distance < their_delta.sort.min)
    end
    nil
  end

  def move_somewhere(head, obstacles)
    x = head[0]
    y = head[0]
    return [x, y + 1] unless obstacles.include?([x, y + 1])
    return [x + 1, y] unless obstacles.include?([x + 1, y])
    return [x, y - 1] unless obstacles.include?([x, y - 1])
    [x - 1, y]
  end

  # Array of possible locations a snake with a larger head could be next turn
  def dangerous_snake_head(nodes, length, s, others)
    possibles(nodes[0], nodes[1]) if others[s['id']] >= length
  end

  def possibles(snake_head, body)
    x = snake_head[0]
    y = snake_head[1]
    dx = snake_head[0] - body[0]
    dy = snake_head[1] - body[1]
    possible_moves(x, y, dx, dy)
  end

  def snake_bodies(nodes)
    arr = []
    nodes.drop(1).each do |c|
      arr.push(c)
    end
  end

  # others is their lengths
  def obstacles_and_heads(snakes, head, length, others)
    occupied = []
    other_heads = []
    snakes.each do |s|
      nodes = s['coords']
      other_heads.push(nodes.first) unless nodes.first == head
      occupied.push(dangerous_snake_head(nodes, length, s, others))
      occupied.push(snake_bodies(nodes))
    end
    [occupied.uniq, other_heads]
  end

  run! if app_file == $PROGRAM_NAME
end
