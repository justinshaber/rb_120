=begin
  TODO

  After initial deal
    Only show soft high total if 18 and over
  Refactor
    Game.update_totals?
  Welcome Messages
  Goodbye Messages
  Play Again
  
  EXTRA
    Animate initial deal?

  # //lose - dealer bj / human no bj             'dealer_blackjack'
  # //tie - dealer bj / human bj                 'both_blackjack'
  # win - dealer no bj / human bj                'human_blackjack'
  # // lose - human busts                        'human_busted'
  # // win - dealer busts / human doesn't bust   'dealer_busted'
  # // win - human total > dealer total          'human_wins_high'
  # // lose - dealer total > human total         'dealer_wins_high'
  # // tie - human total = dealer                'push'
=end

require 'pry'
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
    cards.map { |card| "#{card}" }.join
  end

  def display_cards_with_totals
    "#{display_cards} => #{display_total}"
  end

  def display_total
    return "BlackJack!" if blackjack?
    soft_total.nil? ? "#{hard_total}" : "#{hard_total} or #{soft_total}"
  end

  def get_valid_high_score
    [hard_total, soft_total].select {|total| !total.nil? && total <= 21}.max
  end

  def calculate_total
    total = cards.collect(&:blackjack_value).sum
    ace_in_hand? && total < 12 ? [total, total+10] : [total]
  end

  def update_totals
    self.hard_total, self.soft_total = calculate_total
  end

  def ace_in_hand?
    cards.any? {|card| card.value == "A"}
  end

  def <=>(other)
    a = get_valid_high_score
    b = other.get_valid_high_score

    return wins_high if a > b
    return other.wins_high if a < b
    return both_blackjack if a == 21 && b == 21
    return push if a == b
  end
end

class Player
  include Hand
  attr_accessor :cards, :hard_total, :soft_total

  def initialize
    @cards = []
    @hard_total = nil
    @soft_total = nil
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

  def wins_high
    blackjack? ? blackjack : 'human_wins_high'
  end

  def blackjack
    'human_blackjack'
  end

  def busted
    'human_busted'
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

  def wins_high
    blackjack? ? blackjack : 'dealer_wins_high'
  end

  def blackjack
    'dealer_blackjack'
  end

  def busted
    'dealer_busted'
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

  def size
    deck.size
  end

  def to_s
    deck.map { |card| "#{card}" }.join
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
    @blackjack_value = get_blackjack_value
  end

  def get_blackjack_value
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

class Game
  attr_accessor :deck, :human, :dealer, :winner, :current_player

  def initialize
    @deck = Deck.new
    @human = Human.new
    @dealer = Dealer.new
    @winner = ""
    @current_player = human
  end

  def initial_deal
    2.times do
      deck.deal_to human
      deck.deal_to dealer
    end
  end

  def display_table
    system 'clear'
    puts "     Dealer"
    puts "    #{dealer.display_correct_cards}"
    puts ""
    puts "    #{human.display_cards_with_totals}"
    puts "     Player"
    puts ""
  end

  def display_goodbye_message
    prompt(winner)
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

  def current_player_turn
    current_player == human ? player_turn : dealer_turn
  end

  def hit
    deck.deal_to current_player
    current_player.update_totals
    display_table
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

  def calculate_winner
    self.winner = human <=> dealer
  end

  def play
    start_phase
    main_game_phase if winner.empty?
    display_table
    display_goodbye_message
  end

  def start_phase
    deck.shuffle
    initial_deal
    update_totals
    display_table

    if dealer.blackjack?
      self.winner = (human.blackjack? ? both_blackjack : dealer.blackjack)
      dealer.reveal_hole_card
    end
  end

  # refactor
  def update_totals
    human.update_totals
    dealer.update_totals
  end
end

game = Game.new
game.play

=begin
Overview:
  Blackjack is a card game that has between 1-7 players trying get a higher total than the dealer, without exceeding 21
Equipment used
  DECK: 1-8 52 card decks are used.
  CARDS 2-10 score the indicated value; Face cards score 10 points; Aces can be scored as 1 or 11.
Game play
  All players are dealt 2 cards, dealer has only one card showing.
  If the dealer has 21
    players who also have 21 tie
    all other players lose
  PLAYER TURN
    HIT - Recieve another card from the deck
    STAY - do not recieve another card, end their turn
    A player may hit as many times as they want, given they do not exceed 21.
  DEALER TURN
    The dealer hits as long as their soft total is 17 or below.
Winning
  When the dealer his a valid hand, totals are compared.
    Players win if they have a higher total
    Players lose if they have a lower total
    Players tie if they push (have an total equal to the dealer)
=end

=begin
Make an initial guess at organizing the verbs into nouns
Nouns
  Player/Dealer
    Hand
      total
      bust
      status?
    hit
    stay
  Deck
    Cards
    shuffle
    deal
  Cards
  Hand
    total
    bust
    status?
  Game
    play
    
Verbs
  hit
  stay
  deal
  shuffle
  Total
  bust
=end
