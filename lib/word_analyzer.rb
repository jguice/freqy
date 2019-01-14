# frozen_string_literal: true

##
# Analyzes word (or multi-word) frequency in (potentially large) text
class WordAnalyzer

  # TODO: add top_n argument to allow for something besides top 100
  # TODO: add words argument to allow for something besides 3 word phrase
  attr_reader(:delimiter, :chunk)

  # Creates new word analyzer
  # @param delimiter [String] text that separates "words"
  # @param chunk [Integer] number of word chunks to read in a batch (adjust for performance tuning)
  def initialize(delimiter = ' ', chunk = 1000)
    @delimiter = delimiter # char that separates "words"
    @chunk = chunk # words
    @phrase_size = 3
    @ignore_chars = Regexp.escape('!@#$%^&*()_=+[{ ]}|;:\'",<.>\/?')
    @ignore_regex = Regexp.new(/[#{@ignore_chars}]/)

    # validate argument types
    raise(ArgumentError) unless @delimiter.class == String
    raise(ArgumentError) unless @chunk.class == Integer

    @freqs = Hash.new(0)
  end

  def process_stdin(text)
    analyze(text)
  end

  def process_files(files)
    files.each do |file|
      analyze(File.open(file))
    end
  end

  # analyzes element frequency in provided text
  # @param text [Enumerable] enumerable stream containing text (like a ruby IO object)
  # @return result [Hash] map of word chunks sorted by most to least frequent (top 'n' results)
  def analyze(text)
    @phrase = [] # instance variable to share across multiple files (and calls to analyze)

    text.each(@delimiter).lazy.each_slice(@chunk) do |words|
      words = filter(words)

      words.each do |word|

  def filter(words)
    words.collect do |word|
      word.gsub!(@ignore_regex, '')

      word.downcase!

      # expand newlines (with optional preceding carriage returns [DOS]) into multiple words
      word.split(/\r?\n/)
    end.flatten # flatten any expanded words back into a single array/list and return it
  end

  protected

  def process_words(words)
    words.each do |word|
      next if word.empty? # skip empty words (can happen in some filtering edge-cases)

      @phrase << word

      if @phrase.size == @phrase_size
        @freqs[@phrase.join(@delimiter)] += 1
        @phrase.shift
      end
    end
  end
end
