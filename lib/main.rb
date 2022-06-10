# frozen_string_literal: true
require "pry-byebug"
require "json"

# game logic class
class Game
  def initialize
    @used_letters = []
    @round_number = 0
    @secret_word = select_word
    @hangman = Hangman.new(self)
    load_game
    game_turn
  end

  attr_reader :round_number, :secret_word, :used_letters

  def word_length
    read_secret_word.length
  end

  def read_secret_word
    @secret_word
  end

  def save_game
    puts "GAME SAVED!"
    to_json
  end

  private

  def save_guess(letter)
    used_letters.include?(letter) ? return : used_letters.push(letter)
  end
  def game_turn
    while round_number < 8
      check_for_win
      if round_number == 6
        game_over_loser
      else
        @hangman.draw_stock
        @hangman.display_correct_letters
        puts "Type 'save' to save your game."
        guess = guess_letter
        check_guess(guess)
      end
    end
  end

  def guess_letter
    puts "\nGuess a letter:\n"
    guess = gets.chomp.downcase.strip
    save_game if guess == "save"
    until guess.length == 1 && guess.match?(/[a-z]/)
      puts "You can only enter a single letter"
      guess = gets.chomp.downcase.strip
      save_game if guess == "save"
    end
    guess
  end

  def load_game
    puts "Would you like to load a previous game? (yes/no)"
    answer = gets.chomp.strip.downcase
    answer == "yes" ? from_json : false
  end

  def select_word
    words = []
    File.open("dictionary.txt").readlines.each { |word| words.push(word) }
    word = words.sample.chomp
    until word.length < 12 && word.length > 5
      word = words.sample.chomp
    end
    word
  end

  def check_guess(letter)
    word = read_secret_word
    correct_letter = word.include?(letter)
    return game_turn if previously_used_guess(letter) == false

    if correct_letter
      @hangman.correct_guess(letter)
      puts "Correct! Letter #{letter} is in the secret word."
    else
      puts "Wrong, letter: #{letter} is not in the secret word."
      increase_round_number
      @hangman.add_body_part
    end
  end

  def increase_round_number
    @round_number += 1
  end

  def previously_used_guess(letter)
    if used_letters.include?(letter)
      puts "You have already guessed letter: #{letter}\n"
      true
    else
      save_guess(letter)
    end
  end

  def check_for_win
    word = @secret_word
    guessed_word = @hangman.guess_board.join('')
    game_over_winner if guessed_word == word
  end

  def game_over_winner
    @hangman.display_correct_letters
    puts "You win!"
    new_game
  end

  def game_over_loser
    @hangman.draw_stock
    puts "You lost the game... you failed to guess the word: #{@secret_word}"
    new_game
  end

  def new_game
    puts "\n\nHello, would you like to play a new game of Hangman? (yes/no)?"
    answer = gets.chomp

    until %w[yes no].include?(answer)
      puts "\nWould you like to play a new game of Hangman? (yes/no)?"
      answer = gets.chomp
    end

    answer == "yes" ? Game.new : exit
  end

  def to_json
    game_save = JSON.dump ({
      :round_number => @round_number,
      :secret_word => @secret_word,
      :used_letters => @used_letters,
      :current_board => @hangman.current_board,
      :guess_board => @hangman.guess_board
    })
    save = File.open("hangman_save.txt", "w")
    save.puts game_save
    save.close
    end_game
    
  end

  def from_json
    save_file = File.read("hangman_save.txt")
    save_data = JSON.parse(save_file)
    # secret_word is being added to round_number for some reason
    @round_number = save_data['round_number'] 
    @secret_word = save_data['secret_word']
    @used_letters = save_data['used_letters']
    @hangman.load_game(save_data['current_board'], save_data['guess_board'] )
  end

  def end_game
    answer = ""
    until %w[yes no].include?(answer)
      puts "Your game was saved.\nDo you want to end the game? (yes/no)"
      answer = gets.chomp.strip.downcase
    end
    answer == "yes" ? exit : return
  end
end

# drawing methods for the gameboar
class Hangman
  def initialize(game)
    @game = game
    @board = { head: "O", body: " |", left_arm: "-|", arms: "-|-", left_leg: "/", legs: "/ \\", empty: " " }
    @current_board = [@board[:empty], @board[:empty], @board[:empty], @board[:empty]]
    @guess_board = Array.new(@game.word_length, " _ ")
  end

  attr_reader :guess_board, :current_board

  def correct_guess(letter)
    # print out locations where letters match.
    word = @game.read_secret_word.split("")
    letter_index = []
    word.each_with_index do |l, index|
      letter_index.push(index) if letter == l
    end
    update_guesses(letter, letter_index)
  end

  def add_body_part
    round_number = @game.round_number
    case round_number
    when 1 then @current_board[0] = @board[:head]
    when 2 then @current_board[1] = @board[:body]
    when 3 then @current_board[1] = @board[:left_arm]
    when 4 then @current_board[1] = @board[:arms]
    when 5 then @current_board[2] = @board[:left_leg]
    when 6 then @current_board[2] = @board[:legs]
    end
  end

  def draw_stock
    print "     ____\n    |    |\n    |    #{@current_board[0]}\n    |   #{@current_board[1]}\n    |   #{@current_board[2]}\n    |\n    |\n    |    \n-----------\n"
  end

  def display_correct_letters
    puts "\n#{guess_board.join(' ')}\n"
  end

  def load_game(current_board, guess_board)
    @current_board = current_board
    @guess_board = guess_board
  end

  private

  def update_guesses(letter, index_array)
    i = 0
    index_array.length.times do
      guess_board[index_array[i]] = letter
      i += 1
    end
  end
end

Game.new
