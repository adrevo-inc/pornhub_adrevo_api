module ScrapeCommon
  extend ActiveSupport::Concern
  require 'mechanize'
  require 'open-uri'
  require 'nokogiri'
  require 'json'
  require 'activerecord-import'

  def login
    agent = Mechanize.new
    agent.max_history = 2
    agent.user_agent = 'Mac Safari'
    page = agent.get("#{CONFIG['domain']}/premium/login")

    form = page.form_with()
    form.action = "#{CONFIG['domain']}/front/authenticate"
    form.username = CONFIG['username']
    form.password = CONFIG['password']
    form.method = "POST"

    login_page = agent.submit(form)

    return agent
  end

  def get_contents(agent, url)
    sleep(1)
    html = agent.get("#{url}").content.toutf8
    return Nokogiri::HTML(html, nil, 'utf-8')
  end

  # 指定したchannelのvideo_keyを取得
  def fetch_video_keys(agent, channel, fetch_vtype='all')
    vkeys = []
    vc_map = []

    if channel.present? then
      url = "#{CONFIG['domain']}/channels/#{channel}/videos"
      while true do
        contents = get_contents(agent, url)
        contents.search("div[@class='widgetContainer']").search('li').each do |content|
          vtype = content.search("i[@class='premiumIcon cl tooltipTrig']").empty? ? 'free' : 'premium'
          vkey = content.attribute("_vkey").value

          cond = (fetch_vtype == 'all') || # premium, free混合
            (fetch_vtype == vtype && fetch_vtype == 'premium') ||
            (fetch_vtype == vtype && fetch_vtype == 'free')
          logger.debug cond
          if cond then
            vkeys = (vkeys << vkey)
          end

          p = {channel: channel, video_id: vkey, video_type: vtype}
          vc_map = (vc_map << VideoChannelMap.new(p))
        end

        # 次ページがあれば引き続き探索
        next_page = contents.search("link[@rel='next']").attribute('href')
        if next_page then
          url = next_page.value
        else
          break
        end
      end

      # channel-video_key mappingの最新情報をDBへ格納（更新型）
      VideoChannelMap.import vc_map, on_duplicate_key_update: [:channel, :video_type]

      return vkeys
    end
  end

  # 指定したchannelのデータを取得
  def fetch_channel_data(agent, channel, label)
    if channel.present? && label.present? then
      data = {channel: channel, label: label}

      # get rank, c_sub (num of channel subscribers)
      contents = get_contents(agent, "#{CONFIG['domain']}/channels/#{channel}")
      contents.search("div[@class='ranktext']").search('span').each do |content|
        data["rank"] = content.content
      end
      data["c_sub"] = contents.search("div[@id='stats']").search('div')[2].content.split[0]

      # get pre_num (num of premium videos)
      contents = get_contents(agent, "#{CONFIG['domain']}/users/#{label}/videos/premium")
      data["pre_num"] = contents.search("span[@class='totalSpan']")[0].content

      # get pub_num (num of public videos)
      contents = get_contents(agent, "#{CONFIG['domain']}/users/#{label}/videos/public")
      contents_search = contents.search("span[@class='totalSpan']")[0]
      data["pub_num"] = contents_search.present? ? contents_search.content : 0

      # get l_sub (num of label subscribers)
      contents = get_contents(agent, "#{CONFIG['domain']}/users/#{label}")
      data["l_sub"] = contents.search("div[@class='bottomInfoContainer']").search("span[@class='number']")[0].content.strip

      # get feature (num of featured videos, but actually this check only first page..)
      contents = get_contents(agent, "#{CONFIG['domain']}/video/manage?o=mv")
      data["feature"] = contents.content.scan('特集').length - 1

      @channel = Channel.new(data)
      @channel.save

      return data
    end
  end

  # 指定したvideo_keyのデータを取得
  def fetch_video_data(agent, key)
    views = ''
    contents = get_contents(agent, "#{CONFIG['domain']}/webmasters/video_by_id?id=#{key}")
    json = JSON.parse(contents.content)

    if json.has_key?('video')
      v = json['video']
      p = v.slice('video_id', 'views', 'duration', 'rating', 'ratings', 'title', 'url', 'default_thumb', 'thumb', 'publish_date')
      p['tags'] = v.has_key?('tags') ? v['tags'].map{ |i| i['tag_name'] }.join(',') : ''
      p['pornstars'] = v.has_key?('pornstars') ? v['pornstars'].map{ |i| i['pornstar_name'] }.join(',') : ''
      p['categories'] = v.has_key?('categories') ? v['categories'].map{ |i| i['category'] }.join(',') : ''
      @video = Video.new(p)
      @video.save

      views = v['views'] || ''
    end
    return views
  end

  def fetch_channel_video_data(agent, channel_enum, fetch_vtype='all')
    result = {}
    channel_enum.each_entry do |c|
      if c.present? then
        vkeys = fetch_video_keys(agent, c, fetch_vtype) 
        vdata = {}
        vkeys.each do |k|
          vdata[k] = fetch_video_data(agent, k)
        end
        result[c] = vdata
      end
    end
    return result
  end

end
