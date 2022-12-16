=begin

Tic Tac Toe is a two player game in which players take turns placing pieces on a square on a 3x3 grid. A player wins by making a vertical, horizontal or diagonal line using their pieces.

Verbs - mark, play
Nouns - Game, Player, Board, Square

Game
Player
  mark
  play
Grid
Square

=end

class Board
  # Will need to track the moves as state
  # Initialize a board with a graphic interface
  # The board will need to be displayed.
end

class Square
  def initialize
    # status to keep track of who is occupying this square
  end
end

class Player
end

class Human
  def choose
    # User makes choice
  end
end

class Computer
  def choose
    # Reads board, makes choice
  end
end

class TTT_Game
  def display_welcome_message
    puts "Welcome to TTT"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing! Goodbye!"
  end

  def display_board
    puts ""
  puts "     |     |"
  puts "  x  |  x  |  x"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  x  |  x  |  x"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  x  |  x  |  x"
  puts "     |     |"
  puts ""
  end

  def play
    display_welcome_message
    loop do
      display_board
      break
      player1_moves
      break if winner? || board_full?

      player2_moves
      break if winner? || board_full?
    end
    # display_winner
    display_goodbye_message
  end
end

game = TTT_Game.new
game.play