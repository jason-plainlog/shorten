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

		redis.hmset(@key, "url", params['url'], "password", params['password'])
		redis.expire(@key, 2592000)
		puts "#{@key} linked to #{params['url']} with password #{params['password']}"

		erb :index
	end

	get '/:key' do |key|
		halt(404) if redis.exists(key) == false

		redirect redis.hget(key, "url") if redis.hget(key, "password") == ""

		erb :auth
	end

	post '/:key' do |key|
		redirect redis.hget(key, "url") if params['password'] == redis.hget(key, "password")

		erb :wrong_pwd
	end

	not_found do
		status 404
		erb :not_found
	end
end
