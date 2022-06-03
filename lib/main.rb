# frozen_string_literal: true
require "pry-byebug"
require "pp"

# game logic class
class Game
  def initialize
    @round_number = 0
    @secret_word = select_word
    puts @secret_word
    @player1 = HumanPlayer.new(self)
    @hangman = Hangman.new(self)
    game_turn
  end

  attr_reader :round_number

  def game_turn
    while round_number < 8
      if round_number == 6
        @hangman.draw_stock
        puts "game_over_loser"
        return
      else
        @hangman.draw_stock
        @hangman.display_correct_letters
        guess = @player1.guess_letter
        check_guess(guess)
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
    @board = { head: "O", body: " |", left_arm: "-|", arms: "-|-", left_leg: "/", legs: "/ \\", empty: " "}
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