# frozen_string_literal: true

# WordList
class WordList
  attr_reader :words

  def initialize
    @words = File.read('wordlist.txt').split(',').shuffle
  end

  def next
    words.first
  end

  def apply_filters!(filters)
    words.reject! { |word| remove_word?(filters, word) }
  end

  def words_left
    @words.length
  end

  private

  def remove_word?(filters, word)
    filters.map do |filter|
      if filter.is_a?(WrongFilter) && skip_wrong_filter?(filter, filters)
        false
      else
        filter.remove?(word: word)
      end
    end.any?
  end

  def skip_wrong_filter?(wrong_filter, filters)
    filters.select do |filter|
      return true if filter.is_a?(CorrectFilter) && filter.letter == wrong_filter.letter
    end

    false
  end
end
