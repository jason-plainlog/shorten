require 'sinatra/base'

class MyApp < Sinatra::Application
  get '/' do
    "Hello, Jason!"
  end
end
