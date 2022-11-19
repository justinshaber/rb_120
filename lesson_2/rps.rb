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

  def display_score
    puts "| SCOREBOARD |"
    puts "#{human.name}: #{human.score}"
    puts "#{computer.name}: #{computer.score}"
    puts
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
    self.move = Move.new(choice)
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
    self.move = Move.new(Move::VALUES.values.sample)
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

  WIN_OPTIONS = {
    'rock' => ['lizard', 'scissors'],
    'paper' => ['rock', 'spock'],
    'scissors' => ['lizard', 'paper'],
    'lizard' => ['paper', 'spock'],
    'spock' => ['rock', 'scissors']
  }

  def initialize(value)
    @value = value
    # @value = case value
    #          when 'rock'     then Rock.new
    #          when 'paper'    then Paper.new
    #          when 'scissors' then Scissors.new
    #          when 'Lizard'   then Lizard.new
    #          when 'Spock'    then Spock.new
    #          end
  end

  def to_s
    @value
  end
end

# Game Orchestration Engine
class RPSGame
  include Displayable, Scorable
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new()
  end

  def display_winner
    if Move::WIN_OPTIONS[human.move.to_s].include?(computer.move.to_s)
      prompt('win', winner: human.name)
      human.score_point
    elsif Move::WIN_OPTIONS[computer.move.to_s].include?(human.move.to_s)
      prompt('lose', winner: computer.name)
      computer.score_point
    else
      prompt('tie')
    end
  end

  def play
    display_welcome_message
    loop do
      loop do
        human.choose
        computer.choose
        display_moves
        display_winner
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
# playing with git some more
