#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'optparse'
require 'ostruct'
require 'date'
require 'pp'

##
# Implements a command-line interface for the frequency analyzer
class Cli
  VERSION = '0.0.1'

  BANNER = <<~BANNER

    🧮  Freqy (freaky) word analyzer.  Analyzes word (or phrase) frequency in text.
       Accepts stdin piped text, or file(s) via -f argument.

    Usage: #{@filename} [options]
  BANNER

  attr_reader :options

  # Initializes a cli instance
  # @param argv [Array] commandline arguments
  # @param stdin [IO] standard input
  def initialize(argv, stdin)
    @arguments = argv
    @stdin = stdin

    # my filename (for portable help over renames)
    @filename = File.basename(__FILE__)

    # options data structure
    @options = OpenStruct.new

    # set option defaults
    @options.verbose = false

    @parser = OptionParser.new
  end

  # Handles a cli run: option setup and parsing, run execution
  # @return [Integer] shell exit code
  def run
    setup_options

    if parse_options?

      puts "Start at #{DateTime.now}\n\n" if @options.verbose

      show_effective_options if @options.verbose

      do_work

      puts "\nFinished at #{DateTime.now}" if @options.verbose

      0 # happy shell exit code
    else
      show_help
    end
  end

  protected

  # process user-provided options
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

  # define accepted options, types, simple behaviors, etc.
  # @return [Integer, nil] shell exit code or nothing depending on user-provided options
  def setup_options
    @parser.banner = BANNER

    @parser.on('-V', '--version', 'display version and exit') do
      show_version
      0
    end
    @parser.on('-h', '--help', 'display help and exit', &method(:show_help))
    @parser.on('-f', '--files file1.txt file2.txt ...', Array, 'text files to read') { |o| @options.files = o }
    @parser.on('-v', '--verbose', 'verbose output') { @options.verbose = true }
  end

  # validate required options and show message + help if needed
  def check_required
    # handle case where no files or text were passed
    return unless @options.files.to_a.empty? # handles nil or empty case

    puts 'Either specify input file(s) or pipe text to STDIN'
    show_help
  end

  # display resulting option set
  def show_effective_options
    puts "Options:\n"

    @options.marshal_dump.each do |name, val|
      puts "  #{name} = #{val}"
    end
  end

  # show application version
  def show_version
    puts "#{@filename} version #{VERSION}"
  end

  # display user help
  def show_help
    puts @parser
    0
  end

  # initiate actual functionality
  def do_work
    puts 'Analyzing Data: ' + @options.files.join(', ')

    word_analyzer = WordAnalyzer.new()

    if @stdin.tty?
      word_analyzer.process_files(@options.files)
    else
      word_analyzer.process_stdin(@stdin)
    end
  end
end
