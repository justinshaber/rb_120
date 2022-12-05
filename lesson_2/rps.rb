require 'yaml'

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
    if human.score > computer.score
      prompt('final_winner')
    else
      prompt('final_loser')
    end
  end

  def display_history
    Player.move_history.each do |k, v|
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

  @@move_history = {}

  def initialize
    @score = 0
  end

  def self.move_history
    @@move_history
  end

  def beats?(other_player)
    Move::WIN_OPTIONS[move.to_s].include?(other_player.move.to_s)
  end
end

class Human < Player
  def initialize
    set_name
    Player.move_history[name] = []
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
        display_history
        show_history_switch = false
        next
      end
      reset_display
      prompt('invalid_choice')
      show_history_switch = true
    end
    reset_display
    choice = Move::VALUES[choice.to_sym] if choice.length <= 2
    self.move = Move.new(choice)
    Player.move_history[name] << choice.dup
  end

  def valid_move?(choice)
    Move::VALUES.key?(choice.to_sym) ||
      Move::VALUES.value?(choice)
  end
end

module Computer
  class Hal < Player # Chooses randomly
    def initialize
      self.name = "Hal"
      Player.move_history[name] = []
      super
    end

    def choose
      self.move = Move.new(Move::VALUES.values.sample)
      Player.move_history[name] << move.value.dup
    end
  end

  class Anakin < Player # Hand chopped off, can only play rock.
    def initialize
      self.name = "Anakin"
      Player.move_history[name] = []
      super
    end

    def choose
      self.move = Move.new('rock')
      Player.move_history[name] << move.value.dup
    end
  end

  class Patrick < Player # No fingers, can only play paper.
    def initialize
      self.name = "Patrick"
      Player.move_history[name] = []
      super
    end

    def choose
      self.move = Move.new('paper')
      Player.move_history[name] << move.value.dup
    end
  end

  class Watson < Player # wins every time
    LOSE_OPTIONS = {
      'rock' => ['paper', 'spock'],
      'paper' => ['scissors', 'lizard'],
      'scissors' => ['rock', 'spock'],
      'lizard' => ['rock', 'scissors'],
      'spock' => ['paper', 'lizard']
    }

    def initialize
      self.name = "Watson"
      Player.move_history[name] = []
      super
    end

    def choose
      human_name = Player.move_history.keys[0]
      human_move = Player.move_history[human_name].last.downcase
      computer_move = LOSE_OPTIONS[human_move].sample
      self.move = Move.new(computer_move)
      Player.move_history[name] << move.value.dup
    end
  end

  class C3PO < Player # Loses every time
    def initialize
      self.name = "C3PO"
      Player.move_history[name] = []
      super
    end

    def choose
      human_name = Player.move_history.keys[0]
      human_move = Player.move_history[human_name].last.downcase
      computer_move = Move::WIN_OPTIONS[human_move].sample
      self.move = Move.new(computer_move)
      Player.move_history[name] << move.value.dup
    end
  end
end

class Move
  attr_reader :value

  def initialize(value)
    @value = value
  end

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

  def to_s
    @value
  end
end

# Game Orchestration Engine
class RPSGame
  include Displayable, Scorable
  attr_accessor :human, :computer, :winner

  def choose_opponent
    case rand(1..5)
    when 1 then Computer::Anakin.new
    when 2 then Computer::Hal.new
    when 3 then Computer::Patrick.new
    when 4 then Computer::Watson.new
    when 5 then Computer::C3PO.new
    end
  end

  def initialize
    @human = Human.new
    @computer = choose_opponent
  end

  def decide_winner
    if human.beats?(computer)
      self.winner = 'human'
      human.score_point
      Player.move_history[human.name][-1].upcase!
    elsif computer.beats?(human)
      self.winner = 'computer'
      computer.score_point
      Player.move_history[computer.name][-1].upcase!
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
      prompt("ask_play_again")
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must be y or n."
    end

    return false if answer == 'n'
    return true if answer == 'y'
  end
end

RPSGame.new.play
