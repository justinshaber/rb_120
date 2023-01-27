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
    hit
    stay
    bust
    total
  Deck
    Cards
    shuffle
    deal
  Cards
  Hand
    total
  Game
    
Verbs
  hit
  stay
  deal
  shuffle
  Total
  bust
=end



class Game
  def initialize
    @deck = Deck.new
    
  end

  def play
    start_phase
    main_game_phase
    show_cards
    calculate_winner
  end

  private

# refactor later
  def main_game_phase
    player_turn
    game_over if bust?

    dealer_turn
    game_over if bust?
  end

  def start_phase
    deal_cards
    show_cards
    game_over if dealer_blackjack?
  end
end

game = Game.new
game.play
