=begin
TO DO
Make history pretty
Show how each move beats the other
Personalities
Organize moves into module
=end

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
    reset_display
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

  def display_history
    Player.move_history.each do |k,v|
      puts "#{k} => #{v}" 
    end
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
  attr_accessor :move, :name, :move_history

  def initialize
    @score = 0
    @@move_history = {
                        human: [],
                        computer: []
                      }
  end

  def self.move_history
    @@move_history
  end
end

class Human < Player
  def initialize
    set_name
    super
  end

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
    show_history_switch = true
    loop do
      prompt('game_prompt', options: Move::VALUES.values.join(', '))
      prompt('show_history_prompt') if show_history_switch == true
      choice = gets.chomp.downcase
      break if valid_move?(choice)
      if choice == 'h'
        reset_display
        display_history                                   # create display_history
        show_history_switch = false
        next
      end
      reset_display
      prompt('invalid_choice')
      show_history_switch = true
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

    Player.move_history[:human] << choice
  end

  def valid_move?(choice)
    Move::VALUES.key?(choice.to_sym) ||
      Move::VALUES.value?(choice)
  end
end

# class Computer < Player
#   def set_name
#     self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
#   end

#   def choose
#     self.move = [Rock.new, Paper.new, Scissors.new, Lizard.new, Spock.new].sample
#     Player.move_history[:computer] << self.move.value
#   end
# end

module Personalities
  class R2D2 < Player
    def initialize
      self.name = "R2D2"
      super
    end

    def choose
      self.move = Rock.new
      Player.move_history[:computer] << self.move.value
    end
  end

  class Hal < Player
    def initialize
      self.name = "Hal"
      super
    end

    def choose
      self.move = [Rock.new, Paper.new, Scissors.new, Lizard.new, Spock.new].sample
      Player.move_history[:computer] << self.move.value
    end
  end

  class Patrick < Player
    def initialize
      self.name = "Patrick"
      super
    end

    def choose
      self.move = Paper.new
      Player.move_history[:computer] << self.move.value
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
    @computer = [ 
                  Personalities::R2D2.new,
                  Personalities::Hal.new,
                  Personalities::Patrick.new
                ].sample
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
