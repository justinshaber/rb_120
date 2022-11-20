require 'pry'

class Move
  VALUES = ['rock', 'paper', 'scissors']

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def scissors?
    @value == 'scissors'
  end
end

class Rock < Move
  def initialize
    @value = 'rock'
  end

  def >(other_move)
    other_move.scissors?
  end

  def <(other_move)
    other_move.paper?
  end

  def to_s
    @value
  end
end

class Paper < Move
  def initialize
    @value = 'paper'
  end

  def >(other_move)
    other_move.rock?
  end

  def <(other_move)
    other_move.scissors?
  end

  def to_s
    @value
  end
end

class Scissors < Move
  def initialize
    @value = 'scissors'
  end

  def >(other_move)
    other_move.paper?
  end

  def <(other_move)
    other_move.rock?
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :name
  attr_writer :move

  def initialize
    set_name
  end

  def move
    @move
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      puts "What is your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Input a value"
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Choose rock, paper, scissors"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
    end
    # self.move = Move.new(choice)

    self.move = case choice
                when 'rock'     then Rock.new
                when 'paper'    then Paper.new
                when 'scissors' then Scissors.new
                end
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Sonny'].sample
  end

  def choose
    choice = Move::VALUES.sample
    # self.move = Move.new(Move::VALUES.sample)
    self.move = case choice
                when 'rock'     then Rock.new
                when 'paper'    then Paper.new
                when 'scissors' then Scissors.new
                end
  end
end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to RPS!"
  end

  def display_goodbye_message
    puts "Thanks for playing RPS!"
  end

  def display_winner
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "must put y or n"
    end

    return true if answer == 'y'
    return false
  end

  def play
    display_welcome_message

    loop do
      human.choose
      computer.choose
      display_winner
      display_goodbye_message
      break unless play_again?
    end
  end
end

RPSGame.new.play