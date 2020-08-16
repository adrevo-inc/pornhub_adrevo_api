namespace :scrape do

  desc "Scrape regularly"
  task scrape_channel: :environment do
    require 'google_drive'

    session = GoogleDrive::Session.from_config('config/gss_service_account.json')
    sp = session.spreadsheet_by_key(CONFIG['GSS_KEY'])
    ws = sp.worksheet_by_title('GSS_SHEET')

    # 各channelのデータを並列で処理
    # https://www.rubydoc.info/github/gimite/google-drive-ruby/GoogleDrive/Worksheet
    # https://www.xmisao.com/2018/07/22/how-to-use-ruby-parallel-gem.html
    channels = (0..ws.num_rows).map{ |r| ws.list[r]['channel_name'] }
    result = ScrapeController._get_all_video_list(Parallel.each(channels))
    logger.debug channels
    logger.debug result
  end

  desc "Import tsv file to DB"
  task :import_chanel, ['filepath'] :environment do |task, args|
    require 'csv'
    CSV.read(args[:filepath], col_sep: "\t").each do |r|
      
    end
    channels = Channel.all
    puts channels
  end

end
