# frozen_string_literal: true

# noinspection RubyResolve
require 'word_analyzer'

RSpec.describe WordAnalyzer, '#initialize' do
  context 'with no arguments' do
    it 'sets a sane default for delimiter' do
      word_analyzer = WordAnalyzer.new

      expect(word_analyzer.delimiter).to_not eq(nil)
      expect(word_analyzer.delimiter).to_not be_empty
      expect(word_analyzer.delimiter).to be_a(String)
    end

    it 'sets a sane default for chunk' do
      word_analyzer = WordAnalyzer.new

      expect(word_analyzer.chunk).to_not eq(nil)
      expect(word_analyzer.chunk).to_not eq(0)
      expect(word_analyzer.chunk).to be_a(Integer)
    end
  end

  context 'with override arguments' do
    it 'sets delimiter' do
      word_analyzer = WordAnalyzer.new('.')

      expect(word_analyzer.delimiter).to eq('.')
    end

    it 'sets chunk' do
      word_analyzer = WordAnalyzer.new('.', 3)

      expect(word_analyzer.chunk).to be(3)
    end
  end
end

RSpec.describe WordAnalyzer, '#process_stdin' do
end

RSpec.describe WordAnalyzer, '#process_files' do
end

#
# ANALYZER
# handles 0,1,2 word input without breaking
# handles 3 word input correctly
# handles ... (brainstorm other test cases
#

RSpec.describe WordAnalyzer, '#process_analyze' do
end