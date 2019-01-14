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

    # remove special chars/spaces (NOTE: this is subtractive partly in an attempt to preserve International characters)
    @ignore_chars = Regexp.escape('!@#$%^&*()_=+[{ ]}|;:\'",<.>\/?')
    @ignore_regex = Regexp.new(/[#{@ignore_chars}]/)

    # validate argument types
    raise(ArgumentError) unless @delimiter.class == String
    raise(ArgumentError) unless @chunk.class == Integer

    @freqs = Hash.new(0)
  end

  def process_stdin(text)
    analyze(text)

    @freqs
  end

  def process_files(files)
    files.each do |file|
      analyze(File.open(file))

    # TODO: return info to the caller about handled exceptions and let it puts, etc.
    rescue Errno::ENOENT
      STDERR.puts("⚠️  No such file #{file}...skipping")
    rescue Errno::EISDIR
      STDERR.puts("⚠️  #{file} is a directory...skipping")
    end

    @freqs
  end

  protected

  # analyzes element frequency in provided text
  # @param text [Enumerable] enumerable stream containing text (like a ruby IO object)
  # @return result [Hash] map of word chunks sorted by most to least frequent (top 'n' results)
  def analyze(text)
    @phrase = [] # instance variable to share across multiple files (and calls to analyze)

    text.each(@delimiter).lazy.each_slice(@chunk) do |words|
      words = filter(words)

      process_words(words)
    end
  end

  def filter(words)
    words.collect do |word|
      word.gsub!(@ignore_regex, '')

      word.downcase!

      # expand newlines (with optional preceding carriage returns [DOS]) into multiple words
      word.split(/\r?\n/)
    end.flatten # flatten any expanded words back into a single array/list and return it
  end

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
