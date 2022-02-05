# frozen_string_literal: true

require_relative 'browser'
require_relative 'wordlist'

wordlist = WordList.new
browser = Browser.new

while wordlist.words_left.positive?
  puts "CURRENT_WORD: #{wordlist.next}"
  result = browser.try(word: wordlist.next)

  case result
  when :success
    puts 'Found it'
    break
  when :failed
    puts 'Failed'
    break
  end

  words_left = wordlist.words_left

  wordlist.apply_filters!(result)

  puts "Eleminated #{words_left - wordlist.words_left}, #{wordlist.words_left} words left."
end

sleep 5
