#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/cli.rb'

cli = Cli.new(ARGV, STDIN)
exit(cli.run) # cli.run returns a shell exit code
