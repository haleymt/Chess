require_relative 'chess_board.rb'
require_relative 'chess_piece.rb'
require_relative 'chess_specific.rb'
require_relative 'chess_player.rb'
require_relative 'exception_names.rb'

require 'yaml'
require 'colorize'
require 'io/console'

class Game
  def initialize(player1, player2)
    @players = [player1, player2]
  end


  def run
    @board = Board.new
    turns = 0
    checkmate = false
    show_hist = false
    while !checkmate
      player = @players[turns%2]
      @message = "#{player.name}(#{player.color})'s turn to move"
      display
      move = player.get_move(@board)

      if move.first == 'save'
        save_game
        puts 'exit (Y/n)?'
        if(gets.chomp == 'n')
          next
        else
          exit(0)
        end
      elsif move.first == 'h'
        @board.history.shown = !@board.history.shown
        next
      end

      @board.move(move.first, move.last, player.color)
      other_player = @players[(turns + 1) % 2].color
      if @board.in_check?(other_player)
        if @board.checkmate?(other_player)
          @message = "Checkmate! #{player.name}(#{player.color}) wins!"
          checkmate = true
          display
          next
        end
        @message = 'Check!'
        display
      end
      turns += 1
    end
  end

  def display
    @board.display(@message)
  end

  def save_game
    puts "what filename do you want to save as (default chess.yml)?"
    filename = gets.chomp.gsub("\"", '')
    filename = 'chess' if filename.length < 1
    filename += '.yml' unless /.yml/ =~ filename

    File.write(filename, YAML.dump(self))
  end

  def self.load_game
    puts "load from what file (default chess.yml)?"
    filename = gets.chomp.gsub("\"", '')
    filename = 'chess' if filename.length < 1
    filename += '.yml' unless /.yml/ =~ filename

    YAML::load_file(filename)
  end
end

class History
  attr_accessor :history, :shown
  def initialize
    @history = []
    @shown = false
  end

  def record(start_p, end_p)
    @history.unshift [start_p, end_p]
  end

  def show_history
    @history[0..9].each_with_index do |moves, index|
      move_num = @history.size - index
      start = translate(moves.first)
      dest = translate(moves.last)
      c = movecolor(index)
      b = movecolor(index+1)
      print "#{move_num}|#{start}  #{dest}|\n".colorize(color: c, background: b)
    end
  end

  def deep_dup
    new_h = History.new
    new_h.history = @history.deep_dup
    new_h
  end
  private
  def movecolor(ind)
    ind.even? ? :white : :black
  end

  def translate(position)
    translated_pos = ""
    translated_pos += ('A'..'H').to_a[position.last]
    translated_pos += (7 - position.first).to_s
    translated_pos
  end


end
