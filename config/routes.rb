Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'top#index'

  get 'scrape/:channel/:label' => 'scrape#index'

  get 'scrape/get_video_list' => 'scrape#get_video_list'
  get 'scrape/get_video_keys' => 'scrape#get_video_keys'
  get 'scrape/get_all_video_list' => 'scrape#get_all_video_list'

  get 'scrape/list_channels' => 'scrape#list_channels'
  get 'scrape/list_videos'   => 'scrape#list_videos'


  get 'sct' => 'etc#sct'

end
