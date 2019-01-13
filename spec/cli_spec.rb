# frozen_string_literal: true

# noinspection RubyResolve
require 'cli'

RSpec.describe Cli, '#run' do
  context 'with version arg' do
    it 'outputs the cli version' do
      cli = Cli.new(['-V'], StringIO.new(''))
      expect { cli.run }.to output(/cli\.rb version/).to_stdout
    end
  end

  context 'with help arg' do
    it 'outputs the help / usage' do
      cli = Cli.new(['-h'], StringIO.new(''))
      expect { cli.run }.to output(/Usage/).to_stdout
    end
  end

  context 'with verbose arg' do
    it 'outputs verbose info' do
      cli = Cli.new(['-v'], StringIO.new(''))
      expect { cli.run }.to output(/verbose = true/).to_stdout
    end
  end

  context 'with file arg' do
    it 'requires at least one filename' do
      cli = Cli.new(['-f'], StringIO.new(''))
      expect { cli.run }.to output(/missing argument/).to_stdout
    end

    it 'accepts a single filename' do
      cli = Cli.new(%w[-f file1.txt], StringIO.new(''))
      expect { cli.run }.to output(/file1\.txt/).to_stdout
    end

    it 'accepts a list of filenames' do
      cli = Cli.new(%w[-f file1.txt file2.txt], StringIO.new(''))
      expect { cli.run }.to output(/file1\.txt, file2\.txt/).to_stdout
    end

    it 'ignores duplicate filenames' do
      cli = Cli.new(%w[-f file1.txt file2.txt file1.txt], StringIO.new(''))
      expect { cli.run }.to output(/file1\.txt, file2\.txt/).to_stdout
    end
  end

  context 'with no arg' do
    it 'requires at least one filename when STDIN is empty' do
      cli = Cli.new([], StringIO.new(''))
      expect { cli.run }.to output(/specify input file/).to_stdout
    end
  end

  context 'with non-option args' do
    it 'accepts a single filename' do
      cli = Cli.new(%w[myfile.txt], StringIO.new(''))
      expect { cli.run }.to output(/myfile\.txt/).to_stdout
    end

    # The program accepts as arguments a list of one or more file paths (e.g. ./solution.rb file1.txt file2.txt ...)
    it 'accepts a multiple filenames' do
      cli = Cli.new(%w[myfile.txt yourfile.txt], StringIO.new(''))
      expect { cli.run }.to output(/myfile\.txt, yourfile\.txt/).to_stdout
    end

    it 'ignores duplicate filenames' do
      cli = Cli.new(%w[myfile.txt yourfile.txt yourfile.txt theirfile.txt yourfile.txt], StringIO.new(''))
      expect { cli.run }.to output(/myfile\.txt, yourfile\.txt, theirfile\.txt/).to_stdout
    end
  end

  # The program also accepts input on stdin (e.g. cat file1.txt | ./solution.rb).
  context 'with stdin' do
    it 'does not show help with any stdin input' do
      cli = Cli.new([], StringIO.new('data'))
      expect { cli.run }.to_not output(/specify input file/).to_stdout
    end
  end
end
