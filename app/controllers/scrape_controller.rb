class ScrapeController < ApplicationController
  def index
    require 'mechanize'
    require 'open-uri'
    require 'nokogiri'

    channel = params[:channel]
    label = params[:label]

    # return json hash
    @json_h = {}

    # get login page
    agent = Mechanize.new
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

    # get rank
    sleep(1)
    url = "#{CONFIG['domain']}/channels/#{channel}"
    html = agent.get("#{url}").content.toutf8
    contents = Nokogiri::HTML(html, nil, 'utf-8')

    contents.search("div[@class='ranktext']").search('span').each do |content|
      @json_h["rank"] = content.content
    end

    # get c_sub
    sleep(1)
    @json_h["c_sub"] = contents.search("div[@id='stats']").search('div')[2].content.split[0]

    # get pre_num
    sleep(1)
    url = "#{CONFIG['domain']}/users/#{label}/videos/premium"
    html = agent.get("#{url}").content.toutf8
    contents = Nokogiri::HTML(html, nil, 'utf-8')
    @json_h["pre_num"] = contents.search("span[@class='totalSpan']")[0].content

    # get pub_num
    sleep(1)
    url = "#{CONFIG['domain']}/users/#{label}/videos/public"
    html = agent.get("#{url}").content.toutf8
    contents = Nokogiri::HTML(html, nil, 'utf-8')
    contents_search = contents.search("span[@class='totalSpan']")[0]

    @json_h["pub_num"] = contents_search.present? ? contents_search.content : 0

    # get l_sub
    sleep(1)
    url = "#{CONFIG['domain']}/users/#{label}"
    html = agent.get("#{url}").content.toutf8
    contents = Nokogiri::HTML(html, nil, 'utf-8')
    @json_h["l_sub"] = contents.search("div[@class='bottomInfoContainer']").search("span[@class='number']")[0].content.strip

    # get feature
    sleep(1)
    url = "#{CONFIG['domain']}/video/manage?o=mv"
    html = agent.get("#{url}").content.toutf8
    contents = Nokogiri::HTML(html, nil, 'utf-8')
    @json_h["feature"] = contents.content.scan('特集').length - 1

    respond_to do |format|
      format.html
      format.json { render json: @json_h }
    end
  end

  def get_video_list
    require 'mechanize'
    require 'open-uri'
    require 'nokogiri'

    # return json hash
    @json_h = {}

    # get login page
    agent = Mechanize.new
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

    @json_h["view"] = []

    logger.debug params["key"]
    params["key"].split(?,).each do |e|
      if e.present?
        url = "#{CONFIG['domain']}/webmasters/video_by_id?id=#{e}"
        html = agent.get("#{url}").content.toutf8
        contents = Nokogiri::HTML(html, nil, 'utf-8')
        match = contents.content.match(/\"views\":(.+?),\"video/)
        if match.present?
          @json_h["view"] = (@json_h["view"] << match[1])
        else
          @json_h["view"] = (@json_h["view"] << "")
          logger.error contents
        end
        sleep(1)
      else
        @json_h["view"] = (@json_h["view"] << "")
      end
    end
    logger.debug @json_h.inspect

    respond_to do |format|
      format.html
      format.json { render json: @json_h }
    end
  end
end
