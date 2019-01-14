# frozen_string_literal: true

# noinspection RubyResolve
require 'word_analyzer'

# TODO: # The program ignores punctuation, line endings, and is case insensitive (e.g. “I love\nsandwiches.” should be
#       treated the same as "(I LOVE SANDWICHES!!)")

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

  context 'with invalid arguments' do
    it 'raises an exception for delimiter array' do
      expect { WordAnalyzer.new(%w[one two]) }.to raise_error(ArgumentError)
    end

    it 'raises an exception for string chunk' do
      expect { WordAnalyzer.new('.', '3') }.to raise_error(ArgumentError)
    end
  end
end

RSpec.describe WordAnalyzer, '#process_stdin' do
  context 'with "blank" stdin' do
    it 'returns a message (and does nothing otherwise)' do
      word_analyzer = WordAnalyzer.new

      result = word_analyzer.process_stdin(StringIO.new(''))

      expect(result).to match(/No input/)
    end
  end

  context 'with short stdin (< chunk < words)' do
    it 'returns a message (and does nothing otherwise)' do
      word_analyzer = WordAnalyzer.new

      result = word_analyzer.process_stdin(StringIO.new('one'))

      expect(result).to match(/Not enough data/)
    end
  end

  # The program outputs a list of the 100 most common three word sequences in the text, along with a count of how many
  # times each occurred in the text. For example: 231 - i will not, 116 - i do not, 105 - there is no, 54 - i know not,
  # 37 - i am not …
  context 'with minimal valid input' do
    it 'returns a single frequency result' do
      word_analyzer = WordAnalyzer.new

      result = word_analyzer.process_stdin(StringIO.new('one two three'))

      expect(result).to be_a(Hash)
      expect(result).to eq('one two three' => 1)
    end
  end

  context 'with sufficient valid input of unique phrases' do
    it 'returns a frequency result' do
      word_analyzer = WordAnalyzer.new

      result = word_analyzer.process_stdin(StringIO.new('one two three four five'))

      expect(result).to be_a(Hash)
      expect(result).to eq(
        'one two three' => 1,
        'two three four' => 1,
        'three four five' => 1
      )
    end

    it 'returns a longer frequency result' do
      word_analyzer = WordAnalyzer.new

      result = word_analyzer.process_stdin(StringIO.new('one two three four five apple banana cheese'))

      expect(result).to be_a(Hash)
      expect(result).to eq(
        'one two three' => 1,
        'two three four' => 1,
        'three four five' => 1,
        'four five apple' => 1,
        'five apple banana' => 1,
        'apple banana cheese' => 1
      )
    end
  end

  context 'with filterable input of unique phrases' do
    it 'handles all filtered special characters' do
      word_analyzer = WordAnalyzer.new

      result = word_analyzer.process_stdin(StringIO.new('!!one@  #$two%^&* ()_=+three [{]} \|;:\'"four,<.>    /?five'))

      expect(result).to be_a(Hash)
      expect(result).to eq(
        'one two three' => 1,
        'two three four' => 1,
        'three four five' => 1
      )
    end

    it 'handles the given special example (Exhibit A)' do
      word_analyzer = WordAnalyzer.new

      result = word_analyzer.process_stdin(StringIO.new("I love\nsandwiches."))

      expect(result).to be_a(Hash)
      expect(result).to eq('i love sandwiches' => 1)
    end

    it 'handles the given special example (Exhibit B)' do
      word_analyzer = WordAnalyzer.new

      result = word_analyzer.process_stdin(StringIO.new('"(I LOVE SANDWICHES! !) ")'))

      expect(result).to be_a(Hash)
      expect(result).to eq('i love sandwiches' => 1)
    end

    it 'counts dashes as word chars' do
      word_analyzer = WordAnalyzer.new

      result = word_analyzer.process_stdin(StringIO.new('one two-three four five'))

      expect(result).to be_a(Hash)
      expect(result).to eq(
        'one two-three four' => 1,
        'two-three four five' => 1
      )
    end

    it 'handles international characters' do
      word_analyzer = WordAnalyzer.new

      result = word_analyzer.process_stdin(StringIO.new('индустрия คือ ტექსტს 的幽默 और וההקלדה'))

      expect(result).to be_a(Hash)
      expect(result).to eq(
        'индустрия คือ ტექსტს' => 1,
        'คือ ტექსტს 的幽默' => 1,
        'ტექსტს 的幽默 और' => 1,
        '的幽默 और וההקלדה' => 1
      )
    end

    it 'handles emoji characters' do
      word_analyzer = WordAnalyzer.new

      result = word_analyzer.process_stdin(StringIO.new('🙈 🙉 🙊 🐵'))

      expect(result).to be_a(Hash)
      expect(result).to eq(
        '🙈 🙉 🙊' => 1,
        '🙉 🙊 🐵' => 1
      )
    end
  end

  context 'with multi-frequency phrases' do
    it 'correctly counts phrases' do
      word_analyzer = WordAnalyzer.new

      result = word_analyzer.process_stdin(StringIO.new('a b c a b c a b c'))

      expect(result).to be_a(Hash)
      expect(result).to eq(
        'a b c' => 3,
        'b c a' => 2,
        'c a b' => 2
      )
    end
  end
end

RSpec.describe WordAnalyzer, '#process_files' do
end

RSpec.describe WordAnalyzer, '#process_analyze' do
end
