# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "log/crontab.log"
set :environment, :development

every 1.day, :at => '23:00' do
  rake "scrape:scrape_channel"
end

# Learn more: http://github.com/javan/whenever
