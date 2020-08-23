Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'top#index'

  get 'scrape/:channel/:label' => 'scrape#get_channel_data'

  get 'scrape/get_video_list' => 'scrape#get_video_data_by_key'
  get 'scrape/get_video_keys' => 'scrape#get_video_keys_by_channel'
  get 'scrape/get_all_video_list' => 'scrape#get_video_data_by_channel'

  get 'scrape/list_channels' => 'scrape#select_channels'
  get 'scrape/list_videos'   => 'scrape#select_videos'


  get 'sct' => 'etc#sct'

end
