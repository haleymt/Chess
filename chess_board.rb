class Array
  def deep_dup
    [].tap do |new_array|
      self.each do |el|
        new_array << (el.is_a?(Piece) || el.is_a?(Array) ? el.deep_dup : el)
      end
    end
  end
end

class Board
  attr_accessor :kings_position, :board
  def initialize
    @directions = {
      :up => [-1,0],
      :down => [1,0],
      :left => [0,-1],
      :right => [0,1]
    }
    @cursor = [7,0]
    @board = Array.new(8) { Array.new(8) }
    #TODO initalize starting board
    new_board
    # load_pieces(black_pieces, white_pieces) also for save/load
  end

  def [](array)
    @board[array.first][array.last]
  end

  def []=(array, new_value)
    @board[array.first][array.last] = new_value
  end

  def each_piece(&prc)
    @board.each do |row|
      row.each do |tile|
        prc.call(tile) if tile
      end
    end
  end

  def in_check?(color)
    each_piece do |piece|
      if piece.opposing_piece?(color)
        return true if valid_move?(piece.pos, @kings_position[color], piece.color, false)
      end
    end
    false
  end

  def move(start_pos, end_pos, color)
    # relies on game and valid_move to supply a good move
    # executes good move
    piece = self[start_pos]
    @kings_position[color] = end_pos if piece.symbol == '&'
    piece.pos = end_pos
    if self[end_pos]
      self[end_pos].pos = nil
    end
    self[end_pos] = self[start_pos]
    self[start_pos] = nil
  end

  def valid_move?(start_pos, end_pos, color, redisplay = true)
    return false if start_pos.nil? || end_pos.nil?
    # start_pos
    #  - is there a piece? board
    raise NoPieceThere if self[start_pos] == nil
    #  - is it our piece? piece
    piece = self[start_pos]
    raise ThatsNotYours if piece.opposing_piece?(color)
    # - is it in bounds? board
    raise OutOfBoard unless in_bounds?(start_pos) && in_bounds?(end_pos)
    # end_pos
    # - is the direction correct PIECE RESPONSIBLE
    raise InvalidMove unless piece.valid_direction?(start_pos, end_pos)
    # - SLIDING PIECE does it move THROUGH a piece BOARD RESPONSIBLE
    #  for position in piece.check_position
    #       is there a piece there?
    pos_to_check = piece.possible_blocking_positions(start_pos, end_pos)
    pos_to_check.each do |pos|
      raise BlockedMove if self[pos]
    end
    if self[end_pos]
    # - Is there something in the end_position and can we take it?
      raise BlockedMove unless self[end_pos].opposing_piece?(color)
    end
    true
  rescue ChessError => e
    display(e) if redisplay
    return false
  end

  def new_board
    back_lines = [[],[]].tap do |arr|
      [[:black, 0], [:white, 7]].each_with_index do |inits, ind|
        arr[ind] << Rook.new(inits.first, [inits.last,0])
        arr[ind] << Knight.new(inits.first, [inits.last,1])
        arr[ind] << Bishop.new(inits.first, [inits.last,2])
        arr[ind] << Queen.new(inits.first, [inits.last,3])
        arr[ind] << King.new(inits.first, [inits.last,4])
        arr[ind] << Bishop.new(inits.first, [inits.last,5])
        arr[ind] << Knight.new(inits.first, [inits.last,6])
        arr[ind] << Rook.new(inits.first, [inits.last,7])
      end
    end
    pawns = [[],[]].tap do |arr|
      [[:black,1],[:white,6]].each_with_index do |inits, ind|
        arr[ind] << Pawn.new(inits.first, [inits.last,0], self)
        arr[ind] << Pawn.new(inits.first, [inits.last,1], self)
        arr[ind] << Pawn.new(inits.first, [inits.last,2], self)
        arr[ind] << Pawn.new(inits.first, [inits.last,3], self)
        arr[ind] << Pawn.new(inits.first, [inits.last,4], self)
        arr[ind] << Pawn.new(inits.first, [inits.last,5], self)
        arr[ind] << Pawn.new(inits.first, [inits.last,6], self)
        arr[ind] << Pawn.new(inits.first, [inits.last,7], self)
      end
    end

    @board[0] = back_lines[0]
    @board[1] = pawns[0]
    @board[6] = pawns[1]
    @board[7] = back_lines[1]

    @kings_position = {:black => [0,4], :white => [7,4]}
  end

  def in_bounds?(pos)
    pos.first.between?(0,7) && pos.last.between?(0,7)
  end

  def deep_dup
    new_board = self.dup
    new_board.kings_position = Marshal.load(Marshal.dump(@kings_position))
    new_board.board = @board.deep_dup
    new_board
  end

  def cursor_move(dir)
    new_cursor = [@cursor.first + @directions[dir].first, @cursor.last + @directions[dir].last]
    @cursor = new_cursor if in_bounds?(new_cursor)
  end

  def get_cursor_position
    @cursor
  end

  def display(message = nil)
    system('clear')
    print "#{message}\n"
    @board.each_with_index do |row, row_index|
      row.each_with_index do |tile, col_index|
        is_black = ((row_index + col_index) % 2 == 1)
        back_c = is_black ? :yellow : :magenta
        if @cursor == [row_index, col_index]
          back_c = :red
        end
        if tile
          tile.display(back_c)
        else
          print "   ".colorize(background: back_c)
        end
      end
      print "\n"
    end
  end
end
