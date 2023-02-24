=begin
change <=>
determine winner - not clear
  - self.winner = # pass the human or dealer object
    - have an object instance variable that shows the outcome
=end

require 'yaml'

MESSAGE = YAML.load_file('21_messages.yml')

def prompt(message)
  puts format("=> #{MESSAGE[message]}")
end

module Hand
  def blackjack?
    hard_total == 21 || soft_total == 21
  end

  def bust?
    hard_total > 21
  end

  def display_cards
    cards.map(&:to_s).join
  end

  def display_cards_with_totals
    "#{display_cards} => #{display_total}"
  end

  def display_total
    return "BlackJack!" if blackjack?
    return hard_total.to_s if soft_total.nil?
    display_final_total ? soft_total.to_s : "#{hard_total} or #{soft_total}"
  end

  def valid_high_score
    [hard_total, soft_total].select { |total| !total.nil? && total <= 21 }.max
  end

  def calculate_total
    total = cards.collect(&:blackjack_value).sum
    ace_in_hand? && total < 12 ? [total, total + 10] : [total]
  end

  def update_totals
    self.hard_total, self.soft_total = calculate_total
  end

  def ace_in_hand?
    cards.any? { |card| card.value == "A" }
  end

  def compare_to(other)
    a = valid_high_score
    b = other.valid_high_score

    return wins_high if a > b
    return other.wins_high if a < b
    return both_blackjack if a == 21 && b == 21
    return push if a == b
  end
end

class Player
  include Hand
  attr_accessor :cards, :hard_total, :soft_total, :display_final_total

  def initialize
    @cards = []
    @hard_total = nil
    @soft_total = nil
    @display_final_total = false
  end

  def both_blackjack
    'both_blackjack'
  end

  def push
    'push'
  end
end

class Human < Player
  def hit_or_stay?
    loop do
      prompt("hit_or_stay?")
      answer = gets.chomp.downcase

      return answer if answer == "h" || answer == "s"
      prompt("invalid_response")
    end
  end

  def blackjack
    'human_blackjack'
  end

  def busted
    'human_busted'
  end

  def wins_high
    blackjack? ? blackjack : 'human_wins_high'
  end
end

class Dealer < Player
  attr_accessor :hole_card

  def initialize
    @hole_card = true
    super
  end

  def display_correct_cards
    hole_card ? display_with_hole_card : display_cards_with_totals
  end

  def display_with_hole_card
    "|**|#{cards.last} ==> ??"
  end

  def hard_17_or_soft_18
    hard_total >= 17 || (soft_total && soft_total >= 18)
  end

  def reveal_hole_card
    self.hole_card = false
  end

  def blackjack
    'dealer_blackjack'
  end

  def busted
    'dealer_busted'
  end

  def wins_high
    blackjack? ? blackjack : 'dealer_wins_high'
  end
end

class Deck
  attr_accessor :deck

  SUITS = %w(c d h s)
  NUM_CARDS = ("2".."10").to_a
  FACE_CARDS = %w(J Q K A)
  ALL_CARDS = NUM_CARDS + FACE_CARDS

  def initialize
    @deck = []
    build_deck
  end

  def build_deck
    SUITS.each do |suit|
      ALL_CARDS.each do |value|
        @deck << Card.new(value, suit)
      end
    end
  end

  def shuffle
    deck.shuffle!
  end

  def deal_to(player)
    player.cards << deck.shift
  end
end

class Card
  SPADE = "\u2660".encode('utf-8')
  CLUB = "\u2663".encode('utf-8')
  HEART = "\u2665".encode('utf-8')
  DIAMOND = "\u2666".encode('utf-8')

  attr_reader :value, :suit, :blackjack_value

  def initialize(value, suit)
    @value = value
    @suit = suit
    @blackjack_value = calculate_blackjack_value
  end

  def calculate_blackjack_value
    return value.to_i if Deck::NUM_CARDS.include?(value)
    return 10         if %w(J Q K).include?(value)
    return 1          if value == "A"
  end

  def to_s
    symbol = case suit
             when 's'  then SPADE
             when 'c'  then CLUB
             when 'h'  then HEART
             when 'd'  then DIAMOND
             end
    "|#{@value}#{symbol}|"
  end
end

module Displays
  def clear_display
    system 'clear'
  end

  def display_welcome_message
    clear_display
    prompt('welcome')
  end

  def display_table
    clear_display
    puts "     Dealer"
    puts "    #{dealer.display_correct_cards}"
    puts ""
    puts "    #{human.display_cards_with_totals}"
    puts "     Player"
    puts ""
  end

  def display_winning_message
    prompt(winner)
  end

  def display_goodbye_message
    prompt('thank_you')
  end

  def display_results
    human.display_final_total = true
    dealer.display_final_total = true
    display_table
    display_winning_message
  end

  def enter_to_continue
    prompt('press_enter')
    STDIN.gets
  end
end

class Game
  include Displays
  attr_reader :deck, :human, :dealer
  attr_accessor :winner, :current_player

  def initialize
    @deck = Deck.new
    @human = Human.new
    @dealer = Dealer.new
    @winner = ""
    @current_player = human
  end

  def play
    display_welcome_message
    enter_to_continue
    loop do
      start_phase
      main_game_phase if winner.empty?
      display_results
      break unless play_again?
      reset_game
    end
    display_goodbye_message
  end

  private

  def start_phase
    deck.shuffle
    initial_deal
    update_player_totals
    display_table

    return unless dealer.blackjack?

    self.winner = (human.blackjack? ? both_blackjack : dealer.blackjack)
    dealer.reveal_hole_card
  end

  def main_game_phase
    2.times do
      current_player_turn
      if current_player.bust?
        self.winner = current_player.busted
        return
      end
      self.current_player = dealer
    end

    calculate_winner
  end

  def initial_deal
    2.times do
      deck.deal_to human
      deck.deal_to dealer
    end
  end

  def update_player_totals
    human.update_totals
    dealer.update_totals
  end

  def current_player_turn
    current_player == human ? player_turn : dealer_turn
  end

  def player_turn
    loop do
      break if human.blackjack?

      choice = human.hit_or_stay?
      hit if choice == 'h'
      break if choice == 's' || human.bust?
    end
  end

  def dealer_turn
    dealer.reveal_hole_card
    display_table
    sleep 1
    loop do
      break if dealer.hard_17_or_soft_18
      hit
      sleep 1
    end
  end

  def hit
    deck.deal_to current_player
    current_player.update_totals
    display_table
  end

  def calculate_winner
    self.winner = human.compare_to(dealer)
  end

  def play_again?
    loop do
      prompt('ask_play_again')
      answer = gets.chomp

      return true if answer.downcase == 'y'
      return false if answer.downcase == 'n'

      prompt('invalid_quit')
    end
  end

  def reset_game
    initialize
  end
end

game = Game.new
game.play
