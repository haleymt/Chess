require_relative 'chess_game.rb'
#require 'byebug'

if __FILE__ == $PROGRAM_NAME
  puts "New(N) or Start from saved file(L)?"
  option = gets.chomp
  if /^l/=~ option.downcase
    g = Game.load_game
    g.run
  else
    puts "Player 1 name?"
    p1n = gets.chomp
    puts "Player 2 name?"
    p2n = gets.chomp
    p1 = Player.new(:white, p1n)
    p2 = Player.new(:black, p2n)
    g = Game.new(p1,p2)
    g.run
  end
end
