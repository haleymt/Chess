require_relative 'chess_game.rb'

if __FILE__ == $PROGRAM_NAME
  p1 = Player.new(:white, 'white')
  p2 = Player.new(:black, 'black')
  g = Game.new(p1,p2)
  g.run
end
