require 'rubygems'
require 'sinatra'
require 'pony'

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"
end

get '/about' do
	@error = 'something going wrong'
	erb :about
end

get '/visit' do
	erb :visit
end

get '/contacts' do
	erb :contacts
end

get '/message' do
	erb :message
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
		fileDataInput = File.open './public/users.txt', 'a'
		fileDataInput.write "User: #{@userName}, phone: #{@userPhoneNumber}, date: #{@dateAndTime}, barber: #{@barber}, color: #{@color}\n"
		fileDataInput.close

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
    erb :message
  else
    @message = "<a href='http://www.fuck.off'>go to mommy!</a>"
    @title = "Ooooh, cool xakep!"
    erb :message
  end
end
