# frozen_string_literal: true

##
# Analyzes word (or multi-word) frequency in (potentially large) text
class WordAnalyzer

  attr_reader(:delimiter, :chunk)

  # Creates new word analyzer
  # @param delimiter [String] text that separates "words"
  # @param chunk [Integer] number of word chunks to read in a batch (adjust for performance tuning)
  def initialize(delimiter = ' ', chunk = 1000)
    @delimiter = delimiter # char that separates "words"
    @chunk = chunk # words

    # validate argument types
    raise(ArgumentError) unless @delimiter.class == String
    raise(ArgumentError) unless @chunk.class == Integer

    @freqs = {}
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
  def analyze(text)
    text.each(@delimiter).lazy.each_slice(@chunk) do |words|
      pp words
    end
  end

end