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

	before do
		@key = ""
		@dbsize = redis.dbsize
	end

	get '/' do
		erb :index
	end

	post '/' do
		halt erb(:not_url) if params['url'][0..7] != "https://" and params['url'][0..6] != "http://"
		halt erb(:too_short) if params['url'][0..(url.length-1)] == url

		@key = hash(4)
		@key = hash(4) while redis.exists(@key)

		redis.hmset(@key, "url", params['url'], "password", params['password'], "views", 0)
		redis.expire(@key, 2592000)

		erb :index
	end

	get '/:key' do |key|
		halt(404) if redis.exists(key) == false

		if redis.hget(key, "password") == ""
			redis.hincrby(key, "views", 1)
			redis.hincrby(key, Time.now().strftime("%-m/%-d"), 1)

			redirect redis.hget(key, "url")
		end

		erb :auth
	end

	post '/:key' do |key|
		if params['password'] == redis.hget(key, "password")
			redis.hincrby(key, "views", 1)
			redis.hincrby(key, Time.now().strftime("%-m/%-d"), 1)

			redirect redis.hget(key, "url")
		end

		erb :wrong_pwd
	end

	get '/logs/:key' do |key|
		halt(404) if redis.exists(key) == false

		@key = key
		@keys = redis.hkeys(key)
		@vals = redis.hvals(key)
		
		erb :log
	end

	not_found do
		status 404
		erb :not_found
	end
end
