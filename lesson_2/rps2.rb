class Player
  attr_accessor :move, :name

  def initialize(player_type = :human)
    @player_type = player_type
    @move = nil
    set_name
  end

  def set_name
    if human?
      n = ""
      loop do
        puts "What is your name?"
        n = gets.chomp
        break unless n.empty?
        puts "Input a value"
      end
      self.name = n
    else
      self.name = ['R2D2', 'Hal', 'Sonny'].sample
    end
  end

  def choose
    if human?
      choice = nil
      loop do
        puts "Choose rock, paper, scissors"
        choice = gets.chomp
        break if ['rock', 'paper', 'scissors'].include?(choice)
      end
      self.move = choice
    else
      self.move = ['rock', 'paper', 'scissors'].sample
    end
  end

  def human?
    @player_type == :human
  end
end

class Move
  def initialize
    # seems like we need something to keep track
    # of the choice... a move object can be "paper", "rock" or "scissors"
  end
end

class Rule
  def initialize
    # not sure what the "state" of a rule object should be
  end
end

# not sure where "compare" goes yet
def compare(move1, move2)

end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Player.new
    @computer = Player.new(:computer)
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

    case human.move
    when 'rock'
      puts "tie" if computer.move == 'rock'
      puts "winner!" if computer.move == 'scissors'
      puts "you lost" if computer.move == 'paper'
    when 'paper'
      puts "tie" if computer.move == 'paper'
      puts "winner!" if computer.move == 'rock'
      puts "you lost" if computer.move == 'scissors'
    when 'scissors'
      puts "tie" if computer.move == 'scissors'
      puts "winner!" if computer.move == 'paper'
      puts "you lost" if computer.move == 'rock'
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