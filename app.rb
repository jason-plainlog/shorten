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

		redis.hmset(@key, "url", params['url'], "password", params['password'])
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
