require 'pry'

class Board
  WINNING_LINES = [
    [1, 2, 3], [4, 5, 6], [7, 8, 9],
    [1, 4, 7], [2, 5, 8], [3, 6, 9],
    [1, 5, 9], [3, 5, 7]
  ]

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def three_identical_markers?(squares)
    return nil if squares.any?(" ")
    squares.uniq.size == 1
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line).collect(&:marker)
      if three_identical_markers?(squares)
        return squares.first
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_reader :marker

  def initialize(marker)
    @marker = marker
  end
end

class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'

  attr_reader :board, :human, :computer
  attr_accessor :current_player

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @current_player = nil
  end

  def play
    clear_display
    display_welcome_message
    main_game_phase
    display_goodbye_message
  end

  private

  def alternate_player(current)
    current == 'Human' ? 'Computer' : 'Human'
  end

  def clear_display
    system 'clear'
  end

  def clear_screen_and_display_board
    clear_display
    display_board
  end

  def computer_moves
    square = board.unmarked_keys.sample
    board[square] = computer.marker
  end

  def current_player_moves
    human_turn? ? human_moves : computer_moves
    @current_player = alternate_player(@current_player)
  end

  def display_goodbye_message
    puts "Thanks for playing! Goodbye!"
  end

  def display_board
    puts "You are #{HUMAN_MARKER}. Computer is #{COMPUTER_MARKER}."
    puts ""
    board.draw
    puts ""
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
  end

  def display_welcome_message
    puts "Welcome to TTT"
    puts ""
  end

  def human_moves
    puts "Choose a square between: (#{board.unmarked_keys.join(', ')}) "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def human_turn?
    @current_player == 'Human'
  end

  def joinor(arr, delimiter = ", ", and_or = "or")
    case arr.size
    when 0 then ''
    when 1 then arr.join
    when 2 then arr.join(" #{and_or} ")
    else
      str = arr.join(delimiter)
      str[-2] = " #{and_or} "
      str
    end
  end

  def main_game_phase
    @current_player = set_first_to_go
    loop do
      display_board
      player_turn_loop
      display_result
      break unless play_again?
      reset_phase
    end
  end

  def player_turn_loop
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y,n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n."
    end

    answer == 'y'
  end

  def reset_phase
    board.reset
    clear_display
    display_play_again_message
    @current_player = set_first_to_go
    clear_display
  end

  def set_first_to_go
    first = nil
    loop do
      puts "Who should go first?\n[1] - You go first\n[2] - Computer goes first"

      first = gets.chomp.to_i

      break if [1, 2].include?(first)
      clear_display
      puts format("Invalid choice. Please choose #{joinor([1, 2, 3])}")
    end

    clear_display
    first == 1 ? 'Human' : 'Computer'
  end
end

game = TTTGame.new
game.play
