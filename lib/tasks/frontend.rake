require './config/boot'
require './config/environment'

namespace :frontend do
  task :build do
    puts `cd client && grunt build && cp -r dist/* #{Dir.pwd}/public/`
  end
end
