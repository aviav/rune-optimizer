require 'thor'
require_relative 'rune-optimizer.rb'

class RuneCLI < Thor
  desc 'optimize', 'optimize runes'
  option :scrape, type: :boolean
  option :free, type: :boolean
  option :rank_purchases, type: :boolean
  option :page_number, type: :numeric, default: 2
  def optimize
    run_optimizer(options[:scrape], options[:page_number], options[:free], options[:rank_purchases])
  end
end

RuneCLI.start(ARGV)
