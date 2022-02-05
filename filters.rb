# frozen_string_literal: true

# CorrectFilter
class CorrectFilter
  attr_reader :letter

  def initialize(letter:, position:)
    @letter = letter
    @position = position
  end

  def remove?(word:)
    word[@position] != @letter
  end

  def to_s
    "CorrectFilter[#{@letter},#{@position}]"
  end
end

# MisplacedFilter
class MisplacedFilter
  def initialize(letter:, position:)
    @letter = letter
    @position = position
  end

  def remove?(word:)
    word[@position] == @letter || !word.tap { |s| s.slice(@position) }.include?(@letter)
  end

  def to_s
    "MisplacedFilter[#{@letter},#{@position}]"
  end
end

# WrongFilter
class WrongFilter
  attr_reader :letter

  def initialize(letter:)
    @letter = letter
  end

  def remove?(word:)
    word.include?(@letter)
  end

  def to_s
    "WrongFilter[#{@letter}]"
  end
end

# WordFilter
class WordFilter
  def initialize(word:)
    @word = word
  end

  def remove?(word:)
    @word == word
  end

  def to_s
    "WordFilter[#{@word}]"
  end
end
