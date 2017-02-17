#!/usr/bin/env ruby

require 'json'
require './app/grid'
require './app/a_star'

# The real deal BattleSnake 2017
class Braminus < Sinatra::Base
  UP = 'up'.freeze
  DOWN = 'down'.freeze
  LEFT = 'left'.freeze
  RIGHT = 'right'.freeze

  def initialize(*)
    super
  end

  post '/start' do
    @game_id = params[:game_id]
    @grid = Grid.new(params[:width], params[:height])
    { name: 'Braminus', color: '#8B008B' }.to_json
  end

  post '/move' do
    { move: UP }.to_json
  end

  run! if app_file == $PROGRAM_NAME
end
