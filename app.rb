require 'rubygems'
require 'sinatra'
require 'pony'
require "sqlite3"

def get_db
	db = SQLite3::Database.new 'barbershop.db'
	db.results_as_hash = true
	return db
end

#db = get_db

configure do

	get_db.execute 'CREATE TABLE IF NOT EXISTS
		"users"
			 (
			 "id" INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
    	 "name" TEXT,
			 "phone" TEXT,
			 "datestamp" TEXT,
			 "barber" TEXT,
			 "color" TEXT
			 )'

	get_db.execute 'CREATE TABLE IF NOT EXISTS
  	"barbers"
  		 (
  		 "id" INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,
  		 "barber" TEXT UNIQUE
  		 )'

	get_db.execute 'insert or ignore into barbers (barber) values (?)',
									['Walter White']
	get_db.execute 'insert or ignore into barbers (barber) values (?)',
									['Jessie Pinkman']
	get_db.execute 'insert or ignore into barbers (barber) values (?)',
									['Gus Fring']

	$barber1 = get_db.execute 'select barber from barbers where id = 1'
	$barber2 = get_db.execute 'select barber from barbers where id = 2'
	$barber3 = get_db.execute 'select barber from barbers where id = 3'

end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"
end

get '/about' do
	@error = 'something going wrong'
	erb :about
end

get '/visit' do
#	@barber1 = get_db.execute 'select barber from barbers where id = 1'
#	@barber2 = get_db.execute 'select barber from barbers where id = 2'
#	@barber3 = get_db.execute 'select barber from barbers where id = 3'
	erb :visit
end

get '/contacts' do
	erb :contacts
end

get '/message2' do
	erb :message2
end

post '/visit' do
	@userName = params[:userName]
  @userPhoneNumber = params[:userPhone]
  @dateAndTime = params[:userDate]
	@barber = params[:barber]
	@color = params['colorpicker-shortlist']


	hash = {:userName => 'Enter your name',
					:userPhone => 'Enter your phone number',
					:userDate => 'Enter valid date'}

	@error = hash.select{|k,_| params[k] == ""}.values.join(", ")

	if @error == ''
		get_db.execute 'insert into users (name, phone, datestamp, barber, color)
		 values (?, ?, ?, ?, ?)', [@userName, @userPhoneNumber, @dateAndTime, @barber, @color]
		@message = "Hello #{@userName}, you are welcome!! Your phone number #{@userPhoneNumber} is correct? We are waitnig for you at #{@dateAndTime} You want to color your hair in #{@color}"
		erb :message
	else
		erb :visit
	end
end

post '/contacts' do
	@emailFeedback = params[:emailFeedback]
  @textFeedback = params[:textFeedback]

  @title = "Thank you!"
  @message = "Your feedback is very important for us"

  fileDataInput = File.open './public/feedback.txt', 'a'
  fileDataInput.write "User: #{@emailFeedback}, text: #{@textFeedback}\n"
  fileDataInput.close

	@text = params[:textFeedback]
	@name = params[:emailFeedback]

	Pony.options = {
									:from => 'website@myfirstdomain.website',
									:via => :smtp,
									:body => "#{@text}",
									:subject => "order for barber from #{@name}",
  									:via_options => {
											:address              => 'mail.gandi.net',
    								 	:port                 => '587',
    								 	:enable_starttls_auto => true,
    								 	:user_name            => 'website@myfirstdomain.website',
    								 	:password             => 'ghbdfnbpfwbZ1!',
    								 	:authentication       => :plain,
    								 	:domain               => "myfirstdomain.website"
																		}
									}
	Pony.mail(:to => 'shtangech@mail.ru')

	erb :message
end

get '/admin' do
  erb :admin
end

post '/admin' do
  @adminPassword = params[:adminPassword]

  if @adminPassword.strip == "zzz"
		@title = "Secret place"
		@message = "Orders are <a href='/users.txt'>here</a> and feedback is <a href='/feedback.txt'>here</a>"

		@message2 = get_db.execute 'select * from users order by id desc'

		erb :message2
  else
    @message = "<a href='http://www.fuck.off'>go to mommy!</a>"
    @title = "Ooooh, cool xakep!"
    erb :message
  end
end
