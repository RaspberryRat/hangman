puts "Hangman Initialized!"

dictionary = File.open("dictionary.txt", "r")
while !dictionary.eof?
  line = dictionary.readline
  puts line
end
puts dictionary.closed?

dictionary.close
puts dictionary.closed?