require "bundler/gem_tasks"
task :default => :spec


task :console do
  require 'pry'
  require 'locate_urgent_care'

  def reload!
    # Change 'gem_name' here too:
    files = $LOADED_FEATURES.select { |feat| feat =~ /\/locate_urgent_care\// }
    files.each { |file| load file }
  end

  ARGV.clear
  Pry.start
end