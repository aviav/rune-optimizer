require 'thor'
require_relative 'rune-optimizer.rb'

class RuneCLI < Thor
  desc 'optimize', 'optimize runes'
  option :scrape, type: :boolean
  option :page_number, type: :numeric, default: 2
  def optimize
    run_optimizer(options[:scrape], options[:page_number])
  end
end

RuneCLI.start(ARGV)
