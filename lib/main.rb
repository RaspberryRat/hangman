# frozen_string_literal: true
require "pry-byebug"
require "pp"

# game logic class
class Game
  def initialize
    @round_number = 1
    @secret_word = select_word
    puts @secret_word
    @player1 = HumanPlayer.new(self)
    @hangman = Hangman.new(self)
    game_turn
  end

  def game_turn
    while @round_number < 7
      if @round_number == 6
        puts "game_over_loser"
        return
      else
        guess = @player1.guess_letter
        check_guess(guess)
        @round_number += 1
        # todo round number shouldnt increase, only with wrong numbers
      end
    end
  end

  def word_length
    read_secret_word.length
  end

  protected

  def read_secret_word
    @secret_word
  end

  private

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
    # untested, need turn logic
    return game_turn if previously_used_guess(letter) == false
    if correct_letter
      @hangman.correct_guess(letter)
      puts "Letter #{letter} is in #{word}"
    else
      # TODO  add hangman part
      puts "Wrong, letter: #{letter} is not in #{word}"
    end
  end

  def previously_used_guess(letter)
    if @player1.used_letters.include?(letter)
      puts "You have already guessed letter: #{letter}\n"
      return true
    else
      @player1.save_guess(letter)
    end
  end


end

# drawing methods for the gameboar
class Hangman < Game
  def initialize(game)
    @game = game
    @board = { head: "O", body: " |", arms: "-|-", legs: "/ \\", empty: " "}
    @current_board = [@board[:head], @board[:body], @board[:arms], @board[:legs]]
    @guess_board = Array.new(@game.word_length, " _ ")
    @stock = draw_stock
    display_guessed_letters
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

  protected

  def draw_stock
    print "     ____\n    |    |\n    |    #{@current_board[0]}\n    |   #{@current_board[2]}\n    |   #{@current_board[3]}\n    |\n    |\n    |    \n-----------\n"
  end

  def display_guessed_letters
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

# humanplayer and computerplayer superclass
class Players
  def initialize(game)
    @game = game
  end
end

# methods for human player, the guesser
class HumanPlayer < Players
  def initialize(name)
    super
    puts "What is your name?"
    @name = gets.chomp
    @used_letters = []
  end

  attr_reader :used_letters

  def guess_letter
    puts "Guess a letter\n"
    guess = gets.chomp.downcase.strip
    until guess.length == 1 && guess.match?(/[a-z]/)
      puts "You can only enter a single letter"
      guess = gets.chomp.downcase.strip
    end
    guess
  end

  def save_guess(letter)
    if used_letters.include?(letter)
      return
    else
      used_letters.push(letter)
    end
  end
end

# methods for computer player
class ComputerPlayer < Players
end


puts "Hangman Initialized!"
Game.new