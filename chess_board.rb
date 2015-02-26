class Array
  def deep_dup(new_board = nil)
    [].tap do |new_array|
      self.each do |el|
        if el.is_a?(Pawn) || el.is_a?(Array)
          duped_element = el.deep_dup(new_board)
        else
          duped_element = el.is_a?(Piece) ? el.deep_dup : el
        end
        new_array << (duped_element)
      end
    end
  end
end

class Board
  # draw
  attr_accessor :kings_position, :board, :history

  CURSOR_DIR = {
    :up => [-1, 0],
    :down => [1, 0],
    :left => [0, -1],
    :right => [0, 1]
  }

  def initialize
    @history = History.new
    @cursor = [7, 0]
    @board = Array.new(8) { Array.new(8) }
    new_board
  end

  def [](array)
    @board[array.first][array.last] if in_bounds?(array)
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

  def checkmate?(color)
    #checks if color is in checkmate
    each_piece do |piece|
      if !piece.opposing_piece?(color) #piece of color
        return false if valid_moves_for(piece).any?
      end
    end
    return true
  end

  def castle(kingp, kingpend, rookp, rookpend)
    self[kingpend] = self[kingp]
    self[kingpend].set_moved
    self[rookpend] = self[rookp]
    self[rookpend].set_moved
    self[kingp] = nil
    self[rookp] = nil
  end

  def move(start_pos, end_pos, color, checkpromotion = true)
    # relies on game and valid_move to supply a good move
    # executes good move
    #castle
    if is_castle?(start_pos, end_pos, color)
      step = end_pos.last <=> start_pos.last
      king_end = [start_pos.first, start_pos.last + (2 * step)]
      @kings_position[color] = king_end
      rook_end = [start_pos.first, start_pos.last + step]
      castle(start_pos, king_end, end_pos, rook_end)
    else
      piece = self[start_pos]
      piece.set_moved if piece.is_a?(Pawn) || piece.is_a?(King) || piece.is_a?(Rook)
      @kings_position[color] = end_pos if piece.symbol == '&'
      piece.pos = end_pos
      if self[end_pos]
        self[end_pos].pos = nil
      end
      self[end_pos] = piece
      #promotion
      if checkpromotion && promotions?(piece)
        promote_piece(piece)
      end
      self[start_pos] = nil
    end
    @history.record(start_pos, end_pos)
  end

  def promotions?(piece)
    piece.is_a?(Pawn) && piece.promotable?
  end

  def promote_piece(old_piece)
    puts "What would you like to promote your pawn to?"
    puts "1 (Queen), 2 (Rook), 3 (Knight), 4 (Bishop), 5 (Pawn)"

    new_piece = gets.chomp.to_i - 1
    pieces = ["Queen", "Rook", "Knight", "Bishop", "Pawn"]
    new_piece = Kernel.const_get(pieces[new_piece]).new(old_piece.color, old_piece.pos)

    self[old_piece.pos] = new_piece
    old_piece.pos = nil
  end

  def is_castle?(sp, ep, color)
    self[sp].is_a?(King) && self[ep].is_a?(Rook) && !self[sp].opposing_piece?(self[ep].color)
  end

  def castleable?(startp, endp, color)
    not_moved = [startp, endp].all? {|x| !self[x].moved?}
    betweens = []
    if endp.last == 7
      betweens << [startp.first, startp.last + 1]
      betweens << [startp.first, startp.last + 2]
    elsif endp.last == 0
      betweens << [startp.first, startp.last - 1]
      betweens << [startp.first, startp.last - 2]
      betweens << [startp.first, startp.last - 3]
    end
    vacant = betweens.all? { |x| self[x].nil? }
    line_safe = betweens[0..1].all? { |x| !move_into_check?(startp, x, color) }
    return (not_moved && !in_check?(color) && vacant && line_safe)
  end

  def move_into_check?(start_p, end_p, mycolor)
    duped_board = self.deep_dup
    duped_board.move(start_p, end_p, mycolor, false)
    duped_board.in_check?(mycolor)
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
    #is it a castle?
    if is_castle?(start_pos, end_pos, color) && castleable?(start_pos, end_pos, color)
      return true
    end
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

    raise MovedIntoCheck if move_into_check?(start_pos, end_pos, color)
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

  def deep_dup
    new_board = Board.new
    new_board.kings_position = Marshal.load(Marshal.dump(@kings_position))
    new_board.board = @board.deep_dup(new_board)
    new_board.history = @history.deep_dup
    new_board
  end

  def cursor_move(dir)
    new_cursor = [@cursor.first + CURSOR_DIR[dir].first, @cursor.last + CURSOR_DIR[dir].last]
    @cursor = new_cursor if in_bounds?(new_cursor)
  end

  def get_cursor_position
    @cursor
  end

  def display(message = nil)
    system('clear')
    render_rules
    print "#{message}\n"
    @board.each_with_index do |row, row_index|
      print_blankrow(row_index)
      row.each_with_index do |tile, col_index|
        is_black = ((row_index + col_index) % 2 == 1)
        back_c = is_black ? :green : :magenta
        if @cursor == [row_index, col_index]
          back_c = :red
        end
        if tile
          tile.display(back_c)
        else
          print "     ".colorize(background: back_c)
        end
      end
      print "\n"
      print_blankrow(row_index)
    end
    history_space
  end
private
  def render_rules
    puts "----------------------------------------------------"
    puts "************** Welcome to Chess ********************"
    puts "----------------------------------------------------"
    puts "Use the arrow keys to select a coordinate. "
    puts "Hit space to select a start and end position"
    puts "Enter: 's' to save"
    puts "       'q' to quit"
    puts "       'h' to toggle history"
    puts "       'r' to reset game"
    puts "----------------------------------------------------"
  end

  def print_blankrow(r)
    (0..7).each do |i|
      back_c = (i+r) % 2 == 1 ? :green : :magenta
      back_c = :red if @cursor == [r, i]
      print "     ".colorize(background: back_c)
    end
    print "\n"
  end

  def valid_moves_for(piece)
    # puts "#{piece.pos[0]}, #{piece.pos[1]}"
    valids = []
    @board.each_with_index do |row, r_ind|
      row.each_with_index do |tile, c_ind|
        potential_move = [r_ind, c_ind]
        # puts "#{potential_move.first}, #{potential_move.last}"
        if valid_move?(piece.pos, potential_move, piece.color, false)
          valids << potential_move
        end
      end
    end
    valids
  end

  def history_space
    @history.show_history
  end

  def in_bounds?(pos)
    pos.first.between?(0, 7) && pos.last.between?(0,7)
  end
end
