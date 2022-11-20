require 'yaml'
require 'Pry'

module Displayable
  MESSAGE = YAML.load_file('rps_messages.yml')

  def prompt(message, options = nil)
    if options
      puts format(MESSAGE[message], options)
    else
      puts "=> #{MESSAGE[message]}"
    end
  end

  def reset_display
    system "clear"
  end

  def display_welcome_message
    prompt('welcome')
  end

  def display_goodbye_message
    prompt('goodbye')
  end

  def display_moves
    puts ""
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
    puts ""
  end

  def display_winner(winner)
    case winner
      when 'human'    then prompt('win', winner: human.name)
      when 'computer' then prompt('lose', winner: computer.name)
      when 'none'     then prompt('tie')
    end
  end

  def display_score
    puts "| SCOREBOARD |"
    puts "#{human.name}: #{human.score}"
    puts "#{computer.name}: #{computer.score}"
    puts
  end

  def display_final_result
    human.score > computer.score ? prompt('final_winner') : prompt('final_loser')
  end

  def display_info
    
  end
end

module Scorable
  attr_accessor :score

  def score_point
    self.score += 1
  end

  def reset_scores
    human.score = 0
    computer.score = 0
  end
end

class Player
  include Displayable, Scorable
  attr_accessor :move, :name

  def initialize
    set_name
    @score = 0
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      prompt('game_prompt', options: Move::VALUES.values.join(', '))
      choice = gets.chomp.downcase
      break if valid_choice?(choice)
      prompt('invalid_choice')
    end
    reset_display
    choice = Move::VALUES[choice.to_sym] if choice.length <= 2

    self.move = case choice
                when 'rock'     then Rock.new
                when 'paper'    then Paper.new
                when 'scissors' then Scissors.new
                when 'lizard'   then Lizard.new
                when 'spock'    then Spock.new
                end
  end

  def valid_choice?(choice)
    Move::VALUES.key?(choice.to_sym) ||
      Move::VALUES.value?(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    choice = Move::VALUES.values.sample
    self.move = case choice
                when 'rock'     then Rock.new
                when 'paper'    then Paper.new
                when 'scissors' then Scissors.new
                when 'lizard'   then Lizard.new
                when 'spock'    then Spock.new
                end
  end
end

class Move
  attr_reader :value

  VALUES = {
    r: 'rock',
    p: 'paper',
    s: 'scissors',
    l: 'lizard',
    sp: 'spock'
  }

  def initialize(value)
    @value = value
  end

  def to_s
    @value
  end
end

class Rock < Move
  def initialize
    @value = 'rock'
  end

  def beats(other_move)
    ['lizard', 'scissors'].include?(other_move.to_s)
  end
end

class Paper < Move
  def initialize
    @value = 'paper'
  end

  def beats(other_move)
    ['rock', 'spock'].include?(other_move.to_s)
  end
end

class Scissors < Move
  def initialize
    @value = 'scissors'
  end

  def beats(other_move)
    ['lizard', 'paper'].include?(other_move.to_s)
  end
end

class Lizard < Move
  def initialize
    @value = 'lizard'
  end

  def beats(other_move)
    ['paper', 'spock'].include?(other_move.to_s)
  end
end

class Spock < Move
  def initialize
    @value = 'spock'
  end

  def beats(other_move)
    ['rock', 'scissors'].include?(other_move.to_s)
  end
end

# Game Orchestration Engine
class RPSGame
  include Displayable, Scorable
  attr_accessor :human, :computer, :winner

  def initialize
    @human = Human.new
    @computer = Computer.new()
  end

  def decide_winner
    human_move = human.move
    computer_move = computer.move

    if human_move.beats(computer_move)
      self.winner = 'human'
      human.score_point
    elsif computer_move.beats(human_move)
      self.winner = 'computer'
      computer.score_point
    else
      self.winner = 'none'
    end
  end

  def play
    display_welcome_message
    loop do
      loop do
        human.choose
        computer.choose
        display_moves

        decide_winner
        display_winner(winner)
        display_score
        if human.score == 3 || computer.score == 3
          display_final_result
          reset_scores
          break
        end
      end
      break unless play_again?
    end
    display_goodbye_message
  end

  def play_again?
    answer = nil

    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must be y or n."
    end

    return false if answer == 'n'
    return true if answer == 'y'
  end
end

RPSGame.new.play
