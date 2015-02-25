class Pawn < Piece
  def initialize( color, pos, board)
    super( color, pos, 'P')
    @board = board
    @moved = false
    @v_dirs = {
      white: [
        [-1, 1],
        [-1, 0],
        [-1, -1],
        [-2, 0]
      ],
      black: [
        [1, 1],
        [1, 0],
        [1, -1],
        [2, 0]
      ]
    }
  end

  def set_moved
    @moved = true
  end

  def valid_direction?(from, to)
    move_dir = sub_pos(from, to)
    eat_dir1 = @v_dirs[@color][0]
    eat_dir2 = @v_dirs[@color][2]
    poss_moves = [@v_dirs[@color][1]]
    poss_moves << eat_dir1 if @board[add_pos(from, eat_dir1)]
    poss_moves << eat_dir2 if @board[add_pos(from, eat_dir2)]
    poss_moves << @v_dirs[@color][3] unless @moved
    poss_moves.include?(move_dir)
  end

  def possible_blocking_positions(from, to)
    move_dir = sub_pos(from,to)
    return [] unless move_dir.include?(0)
    any_move = add_pos(@pos, @v_dirs[@color][1])
    first_move = add_pos(@pos, @v_dirs[@color][3])
    return (@moved && !(sub_pos(from, to).inject(&:+) > 1)) ? [any_move] : [any_move, first_move]
  end

  def deep_dup
    new_piece = Pawn.new(@color, @pos, @board)
  end

  def utf_symbol
    color == :white ? "\u2659" : "\u265F"
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

  def utf_symbol
    color == :white ? "\u2655" : "\u265B"
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

  def utf_symbol
    color == :white ? "\u2656" : "\u265C"
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

  def utf_symbol
    color == :white ? "\u2657" : "\u265D"
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

  def utf_symbol
    color == :white ? "\u2654" : "\u265A"
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

  def utf_symbol
    color == :white ? "\u2658" : "\u265E"
  end
end
