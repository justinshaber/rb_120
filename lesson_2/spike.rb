=begin
Keep track of a history of moves

As long as the user doesn't quit, keep track of a history of moves by both the human and computer. What data structure will you reach for? Will you use a new class, or an existing class? What will the display output look like?
=end

=begin
PROBLEM: Keep track of a history of moves AND display it if desired

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
  display_history -> Displayable, upcase winning move
    - display the history
    - ask the user if they want to see the history

  ------Done
  Break up display_winner
      - calculate winner     -> RPSGame class
          - update_score     -> Scorable, this will update the history and score

  move_history    -> Player class b/c each player has a history
    INIT a move_history instance variable to an empty array within the Player class
    APPEND the choice within each Player#choose

ask the user if they want to see the history
  - When they make their move, they can also choose to see the history
  - if they decide to input the history
    - the scoreboard pops up
    - they are prompted to make their choice

Ask user to make a choice - r,p,s,l,sp or h to view history
  if no valid choice - ask again
  if they make a choice - continue with the game
  if they choose h - show history, ask user to make a choice (but don't show 'h')

ALGORITHM:

INIT boolean = true
LOOP
  IF boolean
    PROMPT USER TO MAKE CHOICE && SHOW HISTORY PROMPT
  else
    PROMPT USER TO MAKE CHOICE
  end
  BREAK IF choice is a valid move
  IF choice is 'h'
    RESET_Display
    DISPLAY History
    boolean = false
    NEXT
  PROMPT invalid choice
  boolean = true
CODE:

  choice = nil
  show_history_switch = true
    loop do
      prompt('game_prompt', options: Move::VALUES.values.join(', '))
      prompt('show history') if show_history_switch       # create prompt('show history')
      choice = gets.chomp.downcase
      break if valid_move?(choice)                        
      if choice == 'h'
        reset_display
        display_history                                   # create display_history
        show_history_switch = false
        next
      end
      prompt('invalid_choice')
      show_history_switch = true
    end
    reset_display
=end