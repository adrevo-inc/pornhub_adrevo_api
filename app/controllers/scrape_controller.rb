class ScrapeController < ApplicationController
  include ScrapeCommon

### Get methods

  def get_channel_data
    agent = login()

    @json_h = params.slice(:channel, :label).permit(:channel, :label)
    channel_data = fetch_channel_data(agent, @json_h[:channel], @json_h[:label])
    @json_h = @json_h.merge(channel_data)

    respond_to do |format|
      format.html { render template: 'scrape/index' }
      format.json { render json: @json_h }
    end
  end

  def get_video_data_by_key
    agent = login()

    @json_h = {}
    @json_h["view"] = []

    logger.debug params[:key]
    params[:key].split(?,).each do |e|
      views = ''
      if e.present? then
        views = fetch_video_data(agent, e)
      end
      @json_h["view"] = (@json_h["view"] << views)
    end
    logger.debug @json_h.inspect

    respond_to do |format|
      format.html { render template: 'scrape/index' }
      format.json { render json: @json_h }
    end
  end

  # 指定したchannelのvideo_keyを全取得する (premium動画のみ)
  def get_video_keys_by_channel
    agent = login()

    @json_h = {}
    params[:channel].split(?,).each do |e|
      if e.present? then
        @json_h[e] = fetch_video_keys(agent, e, fetch_vtype='premium')
        logger.debug @json_h
      end
    end

    respond_to do |format|
      format.html { render template: 'scrape/index' }
      format.json { render json: @json_h }
    end
  end

  # 指定したchannelの全videoのデータを取得する
  def get_video_data_by_channel
    agent = login()

    @json_h = fetch_channel_video_data(agent, params[:channel].split(?,).each)

    respond_to do |format|
      format.html { render template: 'scrape/index' }
      format.json { render json: @json_h }
    end
  end

## Select DB methods

  # 1日に複数回データが入っている可能性がある
  # また、Scraping処理が伸びて24時以降に取得している可能性もある
  # これらを考慮し、指定当日23:00〜翌日22:59までで最古のデータを取得している
  def _filter_oldest(date, rawdata, uniq_key)
    result = []
    checklist = {}
    rawdata.each do |r|
      k = r[uniq_key]
      if !checklist.has_key?(k) || checklist[k] > r.created_at then
        result = (result << r)
        checklist[k] = r.created_at
      end
    end
    return result
  end

  def select_channels
    logger.debug params
    date = params[:date] || Time.zone.now.strftime('%Y-%m-%d')
    channel = params[:channel]


    if channel.present? then
      datefrom = date + ' 23:00:00'
      dateto = Time.zone.parse(datefrom).since(1.days).strftime('%Y-%m-%d %H:%M:%S')
      rawdata = Channel.where("channel = ? and created_at >= ? and created_at < ?", channel, datefrom, dateto)
      @channels = _filter_oldest(date, rawdata, 'channel')

      respond_to do |format|
        format.html { render template: 'scrape/list_channels' }
        format.json { render json: @channels }
      end
    end
  end

  def select_videos
    logger.debug params
    date = params[:date] || Time.zone.now.strftime('%Y-%m-%d')
    vtype = params[:vtype] || 'premium'
    channel = params[:channel]

    if channel.present? then
      vkeys = VideoChannelMap.where("channel = ? and video_type = ?", channel, vtype).map{ |r| r.video_id }

      datefrom = date + ' 23:00:00'
      dateto = Time.zone.parse(datefrom).since(1.days).strftime('%Y-%m-%d %H:%M:%S')
      rawdata = Video.where("video_id in (?) and created_at >= ? and created_at < ?", vkeys, datefrom, dateto)
      @videos = _filter_oldest(date, rawdata, 'video_id')

      respond_to do |format|
        format.html { render template: 'scrape/list_videos' }
        format.json { render json: @videos }
      end
    end
  end

end
