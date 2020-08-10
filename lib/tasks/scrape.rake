namespace :scrape do
  desc ""
  task scrape_channel: :environment do
    channels = Channel.all
    puts channels
  end
end
