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

require 'pry'

module Hand
  def blackjack?
    low_total == 21 || high_total == 21
  end

  def bust?
    low_total > 21
  end

  def display_cards
    cards.map { |card| "#{card}" }.join
  end

  def display_cards_with_totals
    "#{display_cards} => #{display_total}"
  end

  def display_total
    return "BlackJack!" if low_total == 21 || high_total == 21
    high_total.nil? ? "#{low_total}" : "#{low_total} or #{high_total}"
  end

  def calculate_total
    total = cards.collect(&:blackjack_value).sum
    ace_in_hand? && total < 12 ? [total, total+10] : [total]
  end

  def ace_in_hand?
    cards.any? {|card| card.value == "A"}
  end
end

class Player
  # STATES - Hand, cards, total
  # BEHAVIOURS - hit, stay
  include Hand
  attr_accessor :cards, :low_total, :high_total

  def initialize
    @cards = []
    @low_total = nil
    @high_total = nil
  end
end

class Human < Player
end

class Dealer < Player
  attr_accessor :hole_card

  def initialize
    @hole_card = true
    super
  end

  def display_correct_cards
    hole_card ? "|**|#{cards.last} ==> ??" : display_cards_with_totals
  end
end

class Deck
  # STATES - cards
  # BEHAVIOURS - shuffle, deal

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

  def deal(player)
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
  attr_accessor :deck, :human, :dealer

  def initialize
    @deck = Deck.new
    @human = Human.new
    @dealer = Dealer.new
  end

  def deal_cards
    2.times do
      deck.deal(human)
      deck.deal(dealer)
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

  def game_over
    dealer.hole_card = false
    display_table
    display_goodbye_message
  end

  def display_goodbye_message
    puts "Gameover"
    puts "Dealer got Blackjack..."
    if human.blackjack?
      puts "But you also got Blackjack...it's a push!"
    else
      puts "You lose"
    end
  end

# refactor later
  def main_game_phase
    player_turn
    game_over if bust?

    dealer_turn
    game_over if bust?
  end

  def play
    start_phase
    # main_game_phase
    # show_cards
    # calculate_winner
  end

  def show_cards
    human.display_cards
    dealer.display_cards
  end

  def show_cards_with_totals
    human.display_cards_with_totals
    dealer.display_cards_with_totals
  end

  def start_phase
    deck.shuffle
    deal_cards
    update_totals
    display_table
    game_over if dealer.blackjack?
  end

  def update_totals
    human.low_total, human.high_total = human.calculate_total
    dealer.low_total, dealer.high_total = dealer.calculate_total
  end
end

game = Game.new
game.play
