class Player

  attr_accessor :color, :name

  def initialize(color, name)
    @color = color
    @name = name
  end

  def get_move(board)
    move_array = []
    begin
      puts "Use the arrow keys to select a coordinate. Hit space to select a start and end position"
      puts "Enter 's' to save or 'l' to load"
      input = read_char
      case input
      when "\e[A" #up
        board.cursor_move(:up)
      when "\e[B" #down
        board.cursor_move(:down)
      when "\e[C" #right
        board.cursor_move(:right)
      when "\e[D" #left
        board.cursor_move(:left)
      when ' '
        move_array << board.get_cursor_position
      when 's'
        return ['save']
      when 'q'
        exit 0
      when 'l'
        return ['load']
      when "\u0003"
        exit 0
      else
        puts 'invalid action'
      end
      raise NotEnoughElements
    rescue NotEnoughElements
      board.display("#{name}(#{color})'s turn to move")
      if move_array.length < 2
        retry
      elsif board.valid_move?(move_array.first, move_array.last, @color)
        return move_array
      else
        move_array = []
        retry
      end
    end
  end

  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e"
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end

end
