# frozen_string_literal: true

# game logic class
class Game
  def initialize
    @round_number = 1
    @secret_word = select_word
    puts @secret_word
    @player1 = HumanPlayer.new(self)
    Hangman.new(self)
    game_turn
  end

  def game_turn
    if @round_number == 6
      puts game_over_loser
    else
      guess = @player1.guess_letter
    end
  end

  protected

  def read_secret_word
    @secret_word
  end

  private

  def select_word
    words = []
    File.open("dictionary.txt").readlines.each { |word| words.push(word) }
    words.sample.chomp
  end
end

# drawing methods for the gameboar
class Hangman
  def initialize(game)
    @game = game
    @board = {head: "O", body: " |", arms: "-|-", legs: "/ \\", empty: " "}
    @current_board = [@board[:head], @board[:body], @board[:arms], @board[:legs]]
    @stock = draw_stock
  end

  protected

  def draw_stock
    print "     ____\n    |    |\n    |    #{@current_board[0]}\n    |   #{@current_board[2]}\n    |   #{@current_board[3]}\n    |\n    |\n    |    \n-----------\n"
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
  end

  def guess_letter
    puts "Guess a letter\n"
    guess = gets.chomp.downcase.strip
    until guess.length == 1 && guess.match?(/[a-z]/)
      puts "You can only enter a single letter"
      guess = gets.chomp.downcase.strip
    end
    guess
  end
end

# methods for computer player
class ComputerPlayer < Players
end


puts "Hangman Initialized!"
Game.new