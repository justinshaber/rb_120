require 'yaml'
MESSAGE = YAML.load_file('ttt_messages.yml')

def prompt(message, options = '')
  puts format("=> #{MESSAGE[message]}", options: options)
end

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

  def full?
    unmarked_keys.empty?
  end

  def get_third_square(marker)
    square = nil
    WINNING_LINES.each do |line|
      square = find_desired_square(line, marker)
      break if square
    end
    square
  end

  def someone_won?
    !!winning_marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
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
    puts "     |     | "
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  private

  def find_desired_square(line, marker)
    squares = @squares.values_at(*line).collect(&:marker)

    if squares.count(marker) == 2 &&
       squares.count(Square::INITIAL_MARKER) == 1

      desired_position = squares.index(Square::INITIAL_MARKER)
      return line[desired_position]
    end
    nil
  end

  def three_identical_markers?(squares)
    return nil if squares.any?(Square::INITIAL_MARKER)
    squares.uniq.size == 1
  end
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
  attr_accessor :marker, :name, :score

  def initialize
    @name = nil
    @marker = nil
    @score = 0
  end

  def score_point
    @score += 1
  end

  def to_s
    @name
  end
end

class TTTGame
  WINNING_SCORE = 3

  attr_reader :board, :human, :computer
  attr_accessor :current_player

  def initialize
    @board = Board.new
    @human = Player.new
    @computer = Player.new
    @current_player = nil
    @game = 0
  end

  def play
    welcome_phase
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
    available_squares = board.unmarked_keys
    computer_marker = computer.marker

    # Win if able.
    square = board.get_third_square(computer_marker)

    # If not, then prevent opponent win.
    square = board.get_third_square(human.marker) if !square

    # If not, then take square 5 (most advantageous square).
    (square = 5 if available_squares.include?(5)) if !square

    # If not, then choose random square
    square = available_squares.sample if !square

    board[square] = computer_marker
  end

  def current_player_moves
    human_turn? ? human_moves : computer_moves
    @current_player = alternate_player(current_player)
  end

  def display_goodbye_message
    prompt('goodbye')
  end

  def display_board
    display_scoreboard
    puts ""
    board.draw
    puts ""
  end

  def display_play_again_message
    prompt('play_again')
    puts ""
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      prompt('game_winner', human.name)
    when computer.marker
      prompt('game_winner', computer.name)
    else
      prompt('tie')
    end
  end

  def display_scoreboard
    buffer = " "*human.name.size
    puts "#{human} [#{human.marker}] | #{computer} [#{computer.marker}]"
    puts "#{buffer} #{human.score}   |      #{computer.score}"
  end

  def display_welcome_message
    prompt('welcome', WINNING_SCORE)
  end

  def enter_to_continue
    prompt('press_enter')
    STDIN.gets
  end

  def human_moves
    square_options = joinor(board.unmarked_keys)
    prompt('choose_square', square_options)
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      prompt('invalid_choice', square_options)
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
    loop do
      display_board
      player_turn_loop
      update_score
      display_result
      # break unless play_again?
      enter_to_continue unless match_winner?
      reset_phase
    end
  end

  def match_winner?
    human.score == 3 || computer.score == 3
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
      prompt('ask_play_again')
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      prompt('invalid_choice', '[y] or [n]')
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
      prompt('go_first', computer)

      first = gets.chomp.to_i

      break if [1, 2].include?(first)
      clear_display
      prompt('invalid_choice', joinor([1, 2]))
    end

    clear_display
    first == 1 ? 'Human' : 'Computer'
  end

  def set_computer_marker
    "\u266B".encode('utf-8')
  end

  def set_computer_name
    ['John Lennon', 'George Harrison', 'Paul McCartney', 'Ringo Starr'].sample
  end

  def set_player_info
    human.name = set_human_name
    computer.name = set_computer_name
    human.marker = set_human_marker
    computer.marker = set_computer_marker
    @current_player = set_first_to_go
  end

  def set_human_marker
    marker = nil
    loop do
      prompt('choose_marker')

      marker = gets.chomp

      break if marker.size == 1 && marker != " "
      clear_display
      prompt("invalid_choice", "any single character besides a space as your marker.")
    end

    marker
  end

  def set_human_name
    prompt('ask_name')
    gets.chomp
  end

  def update_score
    @game += 1
    case board.winning_marker
    when human.marker    then human.score_point
    when computer.marker then computer.score_point
    end
  end

  def welcome_phase
    clear_display
    display_welcome_message
    set_player_info
  end
end

game = TTTGame.new
game.play
