# frozen_string_literal: true

##
# Stub class demonstrating how to extend / override default analyzer.
# See notes in analyze about adaptive chunking
class AdaptiveWordAnalyzer < WordAnalyzer
  # analyzes element frequency in provided text
  # @param text [Enumerable] enumerable stream containing text (like a ruby IO object)
  # @return result [Hash] map of word chunks sorted by most to least frequent (top 'n' results)
  def analyze(text)
    @phrase = [] # instance variable to share across multiple files (and calls to analyze)

    # TODO: implement adaptive chunking
    # e.g. Measure time to process the following block with current chunk size, then store that time along with the size
    # and number of words processed.  Determine and store a words per time score for that chunk size also.
    # Next determine a new chunk size to try for the next iteration (maybe random or a percentage, exponential, etc)
    # and increase the chunk size for the next iteration...if the words per time increases then decrease the chunk size.
    # Ultimately the code should continue to refine the chunk size until it's producing the optimal words per time score
    text.each(@delimiter).lazy.each_slice(@chunk) do |words|
      words = filter(words)

      count_phrases(words)
    end
  end
end
