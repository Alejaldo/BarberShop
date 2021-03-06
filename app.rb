#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

def is_barber_exists? db, name
	db.execute('select * from Barbers where username=?', [name]).size > 0
end

def seed_db db, barbers
	barbers.each do |barber|
		if !is_barber_exists? db, barber
			db.execute 'insert into Barbers (username) values (?)', [barber]
		end
	end
end

def get_db
	db = SQLite3::Database.new 'barb.db'
	db.results_as_hash = true
	return db
end

def save_db
	db = get_db
	db.execute 'INSERT INTO Users (username, phone, date, fcker, color)
	VALUES (?, ?, ?, ?, ?)', [@username, @phone, @date, @fcker, @color]
	db.close 
end

before do
	db = get_db
	@barbers = db.execute 'select * from Barbers'
end

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS "Users" (
		"id"	INTEGER,
		"username"	TEXT,
		"phone"	TEXT,
		"date"	TEXT,
		"fcker"	TEXT,
		"color"	TEXT,
		PRIMARY KEY("Id" AUTOINCREMENT)
	)'
	db.execute 'CREATE TABLE IF NOT EXISTS "Barbers" (
		"id"	INTEGER,
		"username"	TEXT,
		PRIMARY KEY("Id" AUTOINCREMENT)
	)'

	seed_db db, ['Big Joe', 'Tricky Ricky', 'Sissy Pososi']


end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do 
	#@error = 'something wrong epta'
	erb :about
end

get '/visit' do
	erb :visit
end

post '/visit' do
	@username = params[:username]
	@phone = params[:phone]
	@date = params[:date]
	@fcker = params[:fcker]
	@color = params[:color]

	@title = 'Good!'
	@message = "<h2>Tfck you, you are confirmed epta!</h2>"
	
	guestlist = File.open './public/guestlist.txt', 'a'
	guestlist.write "Guest #{@username} (phone: #{@phone}) has made appointment on #{@date} with Mr. #{@fcker} and #{@color} color \n"
	guestlist.close

	hh = {
		:username => 'Enter correct name',
		:phone => 'Enter correct phone',
		:date => 'Enter correct date',
		:time => 'Enter correct time'
	}

	#hh.each do |k, v|
	#	if params[k] == ''
	#		@error = hh[k]
	#		return erb :visit
	#	end
	#end
	
	@error = hh.select { |k,_| params[k] == '' }.values.join(", ")
	if @error != ''
		return erb :visit
	end

	save_db

	erb :message
end

get '/admin' do
	erb :admin
end 

post '/admin' do 
	@login = params[:login]
	@pas = params[:password]

	if @login == 'admin' && @pas == 'obana'
        @openlist = File.open './public/guestlist.txt', 'r'
		@zaebisto = '<p>You are axyeNNy chuvak!</p>'
		erb :admin
    else
        @warning = '<p>Wrong login or password!</p>'
        erb :admin
    end
end

get '/contacts' do
	erb :contacts
end

post '/contacts' do
	@name = params[:name]
	@mail = params[:mail]
	@body = params[:body]

	Pony.options = {
		:subject => "Message from #{@name}",
		:body => "#{@body}",
		:via => :smtp,
		:via_options => { 
			:address              => 'smtp.gmail.com', 
			:port                 => '587', 
			:enable_starttls_auto => true, 
			:user_name            => '__@gmail.com',
    		:password             => '__',
			:authentication       => :plain,
		}
	}
	
	Pony.mail(:to => '__@__')

	@obana = "Hey #{@name} your message has succesfully been sent to us!"

	erb :ura
end

get '/showusers' do
	db = get_db
	@results = db.execute 'select * from Users order by id desc'
	erb :showusers
end