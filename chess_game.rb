require_relative 'chess_board.rb'
require_relative 'chess_piece.rb'
require_relative 'chess_specific.rb'
require_relative 'chess_player.rb'
require_relative 'exception_names.rb'

require 'yaml'
require 'colorize'
require 'io/console'

class Game
  attr_accessor :players, :board, :message
  def initialize(player1, player2)
    @players = [player1, player2]
    @message = "Welcome! This is the chess chess chess"
  end


  def run
    @board = Board.new
    turns = 0
    checkmate = false
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
      elsif move.first == 'load'
        new_gamestate = Game.load_game
        @board = new_gamestate.board
        @players = new_gamestate.players
        @message = new_gamestate.message
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
  def initialize
    @history = []
  end

  def record(start_p, end_p)
    @history << [start_p, end_p]
  end

  def show_history
    puts @history
  end

end
