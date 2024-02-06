require 'json' # Require the JSON library to handle saving and loading game state

class Hangman
  def initialize
    # Load dictionary file and filter words between 5 to 12 characters
    @dictionary = File.readlines('google-10000-english-no-swears.txt').map(&:chomp).select { |word| word.length.between?(5, 12) }
    # Select a random word from the filtered dictionary
    @secret_word = @dictionary.sample.downcase
    # Set initial guesses and arrays to track correct and incorrect guesses
    @guesses_left = 6
    @correct_guesses = []
    @incorrect_guesses = []
    # Create an array to represent the word being guessed, initially all characters are hidden
    @guessed_word = Array.new(@secret_word.length, '_')
  end

  def display_board
    # Display current state of the game board: guessed word, incorrect guesses, and remaining guesses
    puts "\nSecret Word: #{@guessed_word.join(' ')}"
    puts "Incorrect Guesses: #{@incorrect_guesses.join(', ')}"
    puts "Guesses Left: #{@guesses_left}"
  end

  def make_guess(letter)
    # Check if the guessed letter is in the secret word
    if @secret_word.include?(letter)
      # If the letter is correct, reveal its positions in the guessed word
      @secret_word.chars.each_with_index do |char, index|
        if char == letter
          @guessed_word[index] = letter
        end
      end
      # Add correct guess to the list of correct guesses
      @correct_guesses << letter
    else
      # If the letter is incorrect, decrement remaining guesses and add it to the list of incorrect guesses
      @incorrect_guesses << letter
      @guesses_left -= 1
    end
  end

  def save_game
    # Save the current game state to a JSON file
    File.open('saved_game.json', 'w') { |file| file.puts JSON.dump(self) }
    puts "Game saved successfully!"
  end

  def self.load_game
    # Load a saved game state from the JSON file
    return nil unless File.exist?('saved_game.json')

    saved_game = JSON.parse(File.read('saved_game.json'))
    puts "Game loaded successfully!"
    saved_game
  end

  def play
    # Display welcome message and prompt to start a new game or load a saved game
    puts "Welcome to Hangman!"
    puts "Type 'load' to load a saved game or any other key to start a new game."
    choice = gets.chomp.downcase
    # Load saved game or start a new game based on user's choice
    game = choice == 'load' ? Hangman.load_game : self

    # Main game loop
    until game.game_over?
      game.display_board
      puts "\nMake a guess (or type 'save' to save the game):"
      input = gets.chomp.downcase

      # Check if player wants to save the game
      if input == 'save'
        game.save_game
        next
      end

      # Validate user input (single letter)
      unless ('a'..'z').include?(input) && input.length == 1
        puts "Invalid input! Please enter a single letter."
        next
      end

      # Process the guessed letter
      game.make_guess(input)
    end

    # Display game result
    if game.won?
      puts "\nCongratulations! You've guessed the word: #{game.secret_word.capitalize}"
    else
      puts "\nSorry, you've run out of guesses. The word was: #{game.secret_word.capitalize}"
    end
  end

  def game_over?
    # Check if the game is over (no guesses left or all letters guessed)
    @guesses_left.zero? || !@guessed_word.include?('_')
  end

  def won?
    # Check if the player has won (all letters guessed)
    !@guessed_word.include?('_')
  end

  protected

  attr_reader :secret_word
end

# Start a new game of Hangman
Hangman.new.play
