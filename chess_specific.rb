require_relative 'chess_piece.rb'

class Pawn < Piece
  def initialize( color, pos)
      super( color, pos, 'P')
  end

  def deep_dup
    new_piece = Pawn.new(color, pos)
  end
end

class Queen < SlidingPieces
  def initialize( color, pos)
      super( color, pos, 'Q')
  end

  def deep_dup
    new_piece = Queen.new(color, pos)
  end

  def valid_direction?(start_p, end_p)
    diag_match?(start_p, end_p) || row_match?(start_p, end_p) || col_match?(start_p, end_p)
  end
end

class Rook < SlidingPieces
  def initialize( color, pos)
      super( color, pos, 'R')
  end

  def deep_dup
    new_piece = Rook.new(color, pos)
  end

  def valid_direction?(start_p, end_p)
    row_match?(start_p, end_p) || col_match?(start_p, end_p)
  end
end

class Bishop < SlidingPieces
  def initialize( color, pos)
      super( color, pos, 'B')
  end

  def deep_dup
    new_piece = Bishop.new(color, pos)
  end

  def valid_direction?(start_p, end_p)
    diag_match?(start_p, end_p)
  end
end

class King < SteppingPieces
  def initialize(color, pos)
    super( color, pos, '&')
    @dirs = [-1, 0, 1].permutation(2).to_a - [[0,0]] + [[1,1], [-1,-1]]
  end

  def deep_dup
    new_piece = King.new(color, pos)
    new_piece.dirs = @dirs
    new_piece
  end

end

class Knight < SteppingPieces
  def initialize(color, pos)
    super( color, pos, 'K')
    @dirs = [
      [-2, -1],
      [-2,  1],
      [-1, -2],
      [-1,  2],
      [ 1, -2],
      [ 1,  2],
      [ 2, -1],
      [ 2,  1]
    ]
  end

  def deep_dup
    new_piece = Knight.new(color, pos)
    new_piece.dirs = @dirs
    new_piece
  end

end
