class Piece
  attr_accessor :color, :pos
  attr_reader :symbol
  def initialize( color, pos, symbol)
    @symbol = symbol
    @pos = pos
    @color = color
  end

  def valid_moves
    raise NotImplementedError
  end

  def opposing_piece?(other_color)
    @color == other_color
  end

  def diag_match?(p1, p2)
    (p1[0] - p2[0]).abs == (p1[1] - p2[1]).abs
  end

  def row_match?(p1, p2)
    p1[0] == p2[0]
  end

  def col_match?(p1, p2)
    p1[1] == p2[1]
  end

  def add_pos(p1, p2)
    [p1.first + p2.first, p1.last + p2.last]
  end

  def sub_pos(p1, p2)
    [p2.first - p1.first, p2.last - p1.last]
  end

  def display(back_c)
    print " #{@symbol} ".colorize(background: back_c, color: @color)
  end

end

class SlidingPieces < Piece

  # IF i want to move from start to end, where do I have to check for pieces
  def possible_blocking_positions(start_pos, end_pos)
    positions = []
    direction = get_direction(start_pos, end_pos)
    current_pos = add_pos(start_pos, direction)
    while current_pos != end_pos
      positions << current_pos
      current_pos = add_pos(current_pos, direction)
    end
    positions
  end

  # what are the valid directions
  def valid_direction?(start_pos, end_pos)
    raise NotImplementedError
  end

  private
    def get_direction(start_p, end_p)
      x_dir = end_p[0] <=> start_p[0]
      y_dir = end_p[1] <=> start_p[1]
      [x_dir, y_dir]
    end

end

class SteppingPieces < Piece
  attr_accessor :dirs
  def possible_blocking_positions(start_pos, end_pos)
    return []
  end

  def valid_direction?(start_p, end_p)
    tried_move = sub_pos(start_p, end_p)
    @dirs.include?(tried_move)
  end

end
