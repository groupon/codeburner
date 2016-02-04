require './config/boot'
require './config/environment'
require 'pp'

namespace :burn do
  task :list do
    Burn.order('id DESC').page(1).per(10).each do |burn|
      pp burn
    end
  end

  task :delete do
    ARGV.each { |a| task a.to_sym do ; end }

    id = ARGV[1]
    burn = Burn.find(id)

    puts "This will delete burn ##{id} and all #{Finding.burn_id(id).count} findings associated with it.  Are you sure? [y/N]"
    input = STDIN.getch
    raise RuntimeError unless input.downcase == 'y'

    Finding.burn_id(id).destroy_all
    burn.destroy
    puts "Successfully deleted burn ##{id} and #{Finding.burn_id(id).count} findings"

    $redis.del ["burn_list", "burn_stats", "stats", "history", "history_range"]
  end
end
