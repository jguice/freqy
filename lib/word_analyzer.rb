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
    return 'No input to process' if text.eof?

    phrase = []

    text.each(@delimiter).lazy.each_slice(@chunk) do |words|
      pp words
      pp @delimiter

      words.each do |word|

        # remove special chars/spaces (NOTE: this is subtractive to attempt to preserve International characters)
        word.gsub!(/[ !@%&"]/, '')
        word.downcase!

        phrase << word

        if phrase.size == 3
          @freqs[phrase.join(@delimiter)] += 1
        end
      end

    end

    pp @freqs

    return 'Not enough data' if @freqs.empty?

    @freqs
  end

end
