Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'top#index'

  get 'scrape/:channel/:label' => 'scrape#index'
  get 'scrape/get_video_list' => 'scrape#get_video_list'

  get 'sct' => 'etc#sct'

end
