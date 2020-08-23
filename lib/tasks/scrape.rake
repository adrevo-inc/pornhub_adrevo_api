namespace :scrape do

  desc "regular scraping"
  task scrape_channel: :environment do
    puts '-------'
    puts Time.now

    # GSSよりchannel名取得
    require 'google_drive'
    session = GoogleDrive::Session.from_config('config/gss_service_account.json')
    sp = session.spreadsheet_by_key(CONFIG['gss_key'])
    ws = sp.worksheet_by_title(CONFIG['gss_sheet'])
    channel_names = (0..ws.num_rows).map{ |r| ws.list[r]['channel_name'] }.filter{ |r| r.present? }
    label_names = (0..ws.num_rows).map{ |r| ws.list[r]['label_name'] }.filter{ |r| r.present? }

    # 各channelのvideoデータを取得
    controller = ScrapeController.new
    agent = controller.login()
    videos = controller.fetch_channel_video_data(agent, channel_names.each)

    # 各channelのchannelデータを取得
    channels = []
    channel_names.zip(label_names) do |c,l|
      channels = (channels << controller.fetch_channel_data(agent, c, l))
    end
  end

#  desc "import tsv file to channel table"
#  task :import_chanel, ['filepath'] => :environment do |task, args|
#    require 'csv'
#    CSV.read(args[:filepath], col_sep: "\t").each do |r|
#      
#    end
#  end

end
