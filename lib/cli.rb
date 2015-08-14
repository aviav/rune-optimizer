require 'thor'
require_relative 'rune-optimizer.rb'

class RuneCLI < Thor
  desc 'optimize', 'optimize runes'
  option :scrape, type: :boolean, default: :false
  def optimize(scrape: :false)
    run_optimizer(scrape)
  end
end

RuneCLI.start(ARGV)
