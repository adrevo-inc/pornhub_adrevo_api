class ScrapeController < ApplicationController

  require 'mechanize'
  require 'open-uri'
  require 'nokogiri'
  require 'json'

  def index
    agent = Mechanize.new
    login(agent)

    @json_h = params.slice(:channel, :label)
    channel_name = params[:channel]
    label = params[:label]

    # get rank, c_sub (num of channel subscribers)
    contents = get_contents(agent, "#{CONFIG['domain']}/channels/#{channel_name}")
    contents.search("div[@class='ranktext']").search('span').each do |content|
      @json_h["rank"] = content.content
    end
    @json_h["c_sub"] = contents.search("div[@id='stats']").search('div')[2].content.split[0]

    # get pre_num (num of premium videos)
    contents = get_contents(agent, "#{CONFIG['domain']}/users/#{label}/videos/premium")
    @json_h["pre_num"] = contents.search("span[@class='totalSpan']")[0].content

    # get pub_num (num of public videos)
    contents = get_contents(agent, "#{CONFIG['domain']}/users/#{label}/videos/public")
    contents_search = contents.search("span[@class='totalSpan']")[0]
    @json_h["pub_num"] = contents_search.present? ? contents_search.content : 0

    # get l_sub (num of label subscribers)
    contents = get_contents(agent, "#{CONFIG['domain']}/users/#{label}")
    @json_h["l_sub"] = contents.search("div[@class='bottomInfoContainer']").search("span[@class='number']")[0].content.strip

    # get feature (num of featured videos, but actually this check only first page..)
    contents = get_contents(agent, "#{CONFIG['domain']}/video/manage?o=mv")
    @json_h["feature"] = contents.content.scan('特集').length - 1

    @channel = Channel.new(channel_params(@json_h))
    @channel.save

    respond_to do |format|
      format.html
      format.json { render json: @json_h }
    end
  end

  def get_video_list
    agent = Mechanize.new
    login(agent)

    @json_h = {}
    @json_h["view"] = []

    logger.debug params["key"]
    params["key"].split(?,).each do |e|
      views = ''
      if e.present?
        contents = get_contents(agent, "#{CONFIG['domain']}/webmasters/video_by_id?id=#{e}")
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
      end
      @json_h["view"] = (@json_h["view"] << views)
    end
    logger.debug @json_h.inspect

    respond_to do |format|
      format.html
      format.json { render json: @json_h }
    end
  end

  def list_channels
    @channels = Channel.all
  end

  def list_videos
    @videos = Video.all
  end

  private

    def login(agent)
      # get login page
      agent.max_history = 2
      agent.user_agent = 'Mac Safari'
      page = agent.get("#{CONFIG['domain']}/premium/login")

      # login
      form = page.form_with()
      form.action = "#{CONFIG['domain']}/front/authenticate"
      form.username = CONFIG['username']
      form.password = CONFIG['password']
      form.method = "POST"

      login_page = agent.submit(form)
    end

    def get_contents(agent, url)
      sleep(1)
      html = agent.get("#{url}").content.toutf8
      return Nokogiri::HTML(html, nil, 'utf-8')
    end

    def channel_params(p)
      columns = Channel.column_symbolized_names
      p.permit(*columns)
    end

end
