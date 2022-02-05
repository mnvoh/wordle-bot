# frozen_string_literal: true
require 'selenium-webdriver'

require_relative 'filters'

# Browser
class Browser
  attr_reader :driver, :current_row

  def initialize
    @driver = Selenium::WebDriver.for :chrome
    @current_row = 1

    driver.manage.window.resize_to(500, 800)
    driver.navigate.to('https://www.powerlanguage.co.uk/wordle/')
    wait = Selenium::WebDriver::Wait.new(timeout: 40)
    wait.until { close_dialog_button.displayed? }

    close_dialog_button.click if close_dialog_button.displayed?

    sleep(1)
  end

  def try(word:)
    return :failed if current_row > 6

    enter_word(word: word)
    send_word
    sleep(3)

    evaluate_attempt(word)
  end

  private

  def enter_word(word:)
    word.each_char do |letter|
      letter_key(letter: letter).click
      sleep 0.2
    end
  end

  def send_word
    enter_key.click
  end

  def evaluate_attempt(word)
    tiles = current_game_tiles

    return :success if tiles.map { |x| x[1] }.uniq == ['correct']

    if tiles.map { |x| x[1] }.any?(&:nil?)
      clear_row
      return [WordFilter.new(word: word)]
    end

    @current_row += 1

    tiles.each_with_index.map do |tile, index|
      letter, status = tile
      available_filters(letter, index)[status]
    end
  end

  def clear_row
    5.times do
      delete_key.click
      sleep 0.2
    end
  end

  def available_filters(letter, position)
    {
      'correct' => CorrectFilter.new(letter: letter, position: position),
      'present' => MisplacedFilter.new(letter: letter, position: position),
      'absent' => WrongFilter.new(letter: letter)
    }
  end

  def close_dialog_button
    script = '''
      return document
        .querySelector("game-app")
        .shadowRoot
        .querySelector("game-modal")
        .shadowRoot
        .querySelector("div.close-icon")
    '''
    driver.execute_script(script)
  end

  def letter_key(letter:)
    script = """
      return document
        .querySelector('game-app')
        .shadowRoot
        .querySelector('game-keyboard')
        .shadowRoot
        .querySelector('button[data-key=#{letter}]')
    """
    driver.execute_script(script)
  end

  def enter_key
    script = """
      return document
        .querySelector('game-app')
        .shadowRoot
        .querySelector('game-keyboard')
        .shadowRoot
        .querySelector('button[data-key=↵]')
    """
    driver.execute_script(script)
  end

  def delete_key
    script = """
      return document
        .querySelector('game-app')
        .shadowRoot
        .querySelector('game-keyboard')
        .shadowRoot
        .querySelector('button[data-key=←]')
    """
    driver.execute_script(script)
  end

  def current_game_tiles
    (1..5).map do |i|
      script = """
        return document
          .querySelector('game-app')
          .shadowRoot
          .querySelector('div#board')
          .querySelector('game-row:nth-child(#{current_row})')
          .shadowRoot
          .querySelector('game-tile:nth-child(#{i})')
      """
      driver.execute_script(script)
    end.map do |tile|
      [tile.attribute('letter'), tile.attribute('evaluation')]
    end
  end
end
