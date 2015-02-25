require_relative 'chess_board.rb'
require_relative 'chess_piece.rb'
require_relative 'chess_specific.rb'
require_relative 'chess_player.rb'
require_relative 'exception_names.rb'

require 'colorize'
require 'io/console'
#game logic
#printing
#save and load
class Game
  def initialize(player1, player2)
    @players = [player1, player2]
    @message = "Welcome! This is the chess chess chess"
  end

  def move_into_check?(start_p, end_p, mycolor)
    duped_board = @board.deep_dup
    duped_board.move(start_p, end_p, mycolor)
    duped_board.in_check?(mycolor)
  end

  def run
    @board = Board.new
    turns = 0
    while !checkmate?
      display
      move = @players[turns%2].get_move(@board)
      if move_into_check?(move.first, move.last, @players[turns%2].color)
        @message = "Can't move yourself into check!"
      else
        @board.move(move.first, move.last)
        turns += 1
        if @board.in_check?
          @message = 'Check!'
          display
        end
      end
    end
  end

  def checkmate?
    false
  end

  def display
    @board.display(@message)
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

if __FILE__ == $PROGRAM_NAME
  p1 = Player.new(:white, 'one')
  p2 = Player.new(:black, 'two')
  g = Game.new(p1,p2)
  g.run
end
