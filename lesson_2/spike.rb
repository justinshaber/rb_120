=begin
Keep track of a history of moves

As long as the user doesn't quit, keep track of a history of moves by both the human and computer. What data structure will you reach for? Will you use a new class, or an existing class? What will the display output look like?
=end

=begin
PROBLEM: Keep track of a history of moves

input: press [x] to see past moves
output:
           Justin     Comp   Score
Round 1   SCISSORS    paper   1-0

EXAMPLES:
  At any time, you can press h to see the moves on the scoreboard
DATA STRUCTURES:
  Hash
    key - round
    value - array with both moves
   [1] => [rock, scissors]

  Which class to use?
  What has a history?
    - each player has a history
    - We already have a displayable Module
  OPTIONS:
    Own class
    Own module
    existing class/module
      - scoring module


  human.choose
  computer.choose
  calculate_winner # RPSGame class
  update_score # RPSGame class
  display_moves
  display_winner
  display_score

  goal:
  Break up display_winner
    - calculate winner     -> RPSGame class
        - update_score     -> Scorable, this will update the history and score
  
  move_history    -> Player class b/c each player has a history
  display_history -> Displayable, upcase winning move

ALGORITHM:
CODE:
=end