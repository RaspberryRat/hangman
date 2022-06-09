# frozen_string_literal: true
require "pry-byebug"
require 'json'

# game logic class
class Game
  def initialize
    if load?
      Game.from_json("game")
    else
      @round_number = 0
      @secret_word = select_word
      @player1 = Player.new(self)
      @hangman = Hangman.new(self)
      game_turn
    end
  end

  attr_reader :round_number

  def game_turn
    while round_number < 8
      check_for_win
      if round_number == 6
        game_over_loser
      else
        @hangman.draw_stock
        @hangman.display_correct_letters
        puts "Type 'save' to save your game."
        guess = @player1.guess_letter
        check_guess(guess)
      end
    end
  end

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

  def load?
    puts "Would you like to load a previous game? (yes/no)"
    answer = gets.chomp.strip.downcase
    answer == "yes" ? true : false
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
    if @player1.used_letters.include?(letter)
      puts "You have already guessed letter: #{letter}\n"
      true
    else
      @player1.save_guess(letter)
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
      :player1 => @player1,
      :hangman => @hangman,
    })
    save = File.open("hangman_save.txt", "w")
    save.puts game_save
    save.close
    
  end

  def self.from_json
    data = JSON.load "hangman.txt"
    self.new(data['round_number'], data['secret_word'], data['player1'], data['hangman'])
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

  attr_reader :guess_board

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

  private

  def update_guesses(letter, index_array)
    i = 0
    index_array.length.times do
      guess_board[index_array[i]] = letter
      i += 1
    end
  end
end


# methods for human player, the guesser
class Player
  def initialize(game)
    @game = game
    puts "What is your name?"
    @name = gets.chomp
    @used_letters = []
  end

  attr_reader :used_letters

  def guess_letter
    puts "\nGuess a letter:\n"
    guess = gets.chomp.downcase.strip
    @game.save_game if guess == "save"
    until guess.length == 1 && guess.match?(/[a-z]/)
      puts "You can only enter a single letter"
      guess = gets.chomp.downcase.strip
      @game.save_game if guess == "save"
    end
    guess
  end

  def save_guess(letter)
    used_letters.include?(letter) ? return : used_letters.push(letter)
  end
end


Game.new
