# frozen_string_literal: true

# game logic class
class Game
  def initialize
    @secret_word = select_word
    puts @secret_word
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



puts "Hangman Initialized!"
Game.new


