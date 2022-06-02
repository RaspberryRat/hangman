# frozen_string_literal: true

# game logic class
class Game
  def initialize
    @secret_word = select_word
    puts @secret_word
    Hangman.new
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





# 
class Hangman
  def initialize
    @stock = draw_stock
  end

  protected
  
  def draw_stock
    print "     ____\n    |    |\n    |\n    |\n    |\n    |\n    |\n    |\n-----------\n"
  end
end

  class Players
    def initialize(name, role)
      @name = name
      @role = role
    end
  end

  class PlayerGuess < Players
    def initialize
      super
    end
  end

  class ComputerPlayer < Players
  end


puts "Hangman Initialized!"
Game.new