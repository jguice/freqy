# frozen_string_literal: true

require 'English'
require 'optparse'
require 'ostruct'
require 'date'
require 'pp'

require_relative 'word_analyzer'
require_relative 'adaptive_word_analyzer'

##
# Implements a command-line interface for the frequency analyzer
class Cli
  VERSION = '0.0.1'

  FILENAME = File.basename(__FILE__)

  BANNER = <<~BANNER

    🧮  Freqy (freaky) word analyzer.  Analyzes word (or phrase) frequency in text.
       Accepts stdin piped text, or file(s) via -f argument.

    Usage: #{FILENAME} [options]
  BANNER

  attr_reader :options

  # Initializes a cli instance
  # @param argv [Array] commandline arguments
  # @param stdin [IO] standard input
  def initialize(argv, stdin)
    @arguments = argv
    @stdin = stdin

    # options data structure
    @options = OpenStruct.new

    # set option defaults
    @options.verbose = false
    @options.number = 100

    @parser = OptionParser.new
  end

  # Handles a cli run: option setup and parsing, run execution
  # @return [Integer] shell exit code
  def run
    setup_options

    if parse_options?

      puts "Start at #{DateTime.now}\n\n" if @options.verbose

      show_effective_options if @options.verbose

      # do_work(WordAnalyzer)

      # example alternate analyzer implementation
      do_work(AdaptiveWordAnalyzer)

      puts "\nFinished at #{DateTime.now}" if @options.verbose

      0 # happy shell exit code
    else
      show_help
    end
  end

  protected

  # Processes user-provided options.
  # @return [Boolean] true if parse succeeds, false otherwise
  def parse_options?
    begin
      @parser.parse!(@arguments)
    rescue StandardError
      puts $ERROR_INFO
      false
    end

    # append any non-option files (optparse leaves these in ARGV conveniently)
    @options.files = [@options.files, @arguments].compact.reduce([], :|) # combine arrays, handling 1 or both being nil
    @options.files.uniq! # ensure unique filenames to process

    check_required

    true
  end

  # Defines accepted options, types, simple behaviors, etc.
  # @return [Integer, nil] shell exit code or nothing depending on user-provided options
  # noinspection RubyBlockToMethodReference
  def setup_options
    @parser.banner = BANNER

    @parser.on('-V', '--version', 'display version and exit') { show_version }
    @parser.on('-h', '--help', 'display help and exit') { show_help }
    @parser.on('-f', '--files=[file1.txt file2.txt ...]', Array, 'text files to read') { |o| @options.files = o }
    @parser.on('-n', '--number=NUM', Integer, 'number of results to show [default = 100]') do |n|
      @options.number = n
    end
    @parser.on('-v', '--verbose', 'verbose output') { @options.verbose = true }
  end

  # Validates required options and shows message + help if needed.
  def check_required
    # handle case where no files or text were passed (a tty is connected or STDIN is EOF in the latter case)
    return unless @options.files.to_a.empty? && (@stdin.tty? || @stdin.eof?) # to_a.empty? handles nil or empty case

    puts 'Either specify input file(s) or pipe text to STDIN'
    show_help
  end

  # Displays resulting option set.
  def show_effective_options
    puts "Options:\n"

    @options.marshal_dump.each do |name, val|
      puts "  #{name} = #{val}"
    end
  end

  # Shows application version.
  def show_version
    puts "#{FILENAME} version #{VERSION}"
  end

  # Displays user help.
  def show_help
    puts @parser
  end

  # Initiates actual functionality.
  def do_work(analyzer = WordAnalyzer)
    puts 'Analyzing Data: ' + @options.files.join(', ')

    word_analyzer = analyzer.new

    results =
      if @stdin.tty?
        word_analyzer.process_files(@options.files)
      else
        word_analyzer.process_stdin(@stdin)
      end

    verify_results(results)
  end

  # Formats and displays results.
  def show_results(results)
    if results.is_a?(Hash)
      results = results.sort_by(&:last).reverse

      results.each_with_index do |result, times|
        break if times == @options.number

        puts(format('%<count>3d - %<phrase>s', count: result[1], phrase: result[0]))
      end
    else
      puts results # didn't get a hash result (probably a helpful user message, just show it)
    end
  end

  # Verifies result data.
  def verify_results(results)
    if results.empty?
      puts 'Not enough data'
      0
    else
      show_results(results)
    end
  end
end
