require 'sinatra'
require 'redis'

class MyApp < Sinatra::Application
	redis = Redis.new

	def hash(length)
		map = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		string = ""

		for i in 1..length
			string += map[rand(0..61)]
		end

		return string
	end

	get '/' do
		@key = ""

		erb :index
	end

	post '/' do
		@key = hash(4)
		@key = hash(4) while redis.exists(@key)

		redis.set(@key, params['url'], {:ex => 2592000})
		puts "#{@key} linked to #{params['url']}"

		erb :index
	end

	get '/:key' do |key|
		halt(404) if redis.exists(key) == false

		redirect redis.get(key)
	end

	not_found do
		status 404
		erb :not_found
	end
end
