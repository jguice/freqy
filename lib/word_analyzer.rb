# frozen_string_literal: true

##
# Analyzes word (or multi-word) frequency in (potentially large) text
class WordAnalyzer
  # TODO: add phrase_size (and default) to argument list
  # TODO: convert options to named opts hash
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

  # Processes STDIN mechanism for data input.
  # @param text [IO] text data to process
  # @return [Hash] frequency counts by phrase
  def process_stdin(text)
    analyze(text)

    @freqs
  end

  # Processes file(s) mechanism for data input.  Skips files on (most) errors.
  # @param files [Enumerable] list of files to read and process
  # @return [Hash] frequency counts by phrase
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

  # Iterates through input text in fixed size chunks, loading as little data as possible into memory.
  # @param text [Enumerable] enumerable stream containing text (like a ruby IO object)
  def analyze(text)
    @phrase = [] # instance variable to share across multiple files (and calls to analyze)

    text.each(@delimiter).lazy.each_slice(@chunk) do |words|
      words = filter(words)

      count_phrases(words)
    end
  end

  # Filters words based on an exclusion character set, reduces case to lower, and splits words with inline line endings.
  # @param words [Enumerable] list of words to filter (input will be modified in-place)
  def filter(words)
    words.collect do |word|
      word.gsub!(@ignore_regex, '')

      word.downcase!

      # expand newlines (with optional preceding carriage returns [DOS]) into multiple words
      word.split(/\r?\n/)
    end.flatten # flatten any expanded words back into a single array/list and return it
  end

  # Counts occurrence of phrases in words (keeping track in a class property persistent across calls)
  # @param words [Enumerable] list of word to extract and count phrases in
  def count_phrases(words)
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
