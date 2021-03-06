# -*- coding: utf-8 -*-
require 'sinatra'
enable :sessions

# Load our dependencies and configuration settings
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
require "evernote_config.rb"

##
# Verify that you have obtained an Evernote API key
##
before do
  if OAUTH_CONSUMER_KEY.empty? || OAUTH_CONSUMER_SECRET.empty?
    halt '<span style="color:red">Before using this sample code you must edit evernote_config.rb and replace OAUTH_CONSUMER_KEY and OAUTH_CONSUMER_SECRET with the values that you received from Evernote. If you do not have an API key, you can request one from <a href="http://dev.evernote.com/documentation/cloud/">dev.evernote.com/documentation/cloud/</a>.</span>'
  end
end

helpers do
  def auth_token
    session[:access_token].token if session[:access_token]
  end

  def client
    @client ||= EvernoteOAuth::Client.new(token: auth_token, consumer_key:OAUTH_CONSUMER_KEY, consumer_secret:OAUTH_CONSUMER_SECRET, sandbox: SANDBOX)
  end

  def user_store
    @user_store ||= client.user_store
  end

  def note_store
    @note_store ||= client.note_store
  end

  def en_user
    user_store.getUser(auth_token)
  end

  def notebooks
    @notebooks ||= note_store.listNotebooks(auth_token)
  end

  def titles
    filter = Evernote::EDAM::NoteStore::NoteFilter.new
    filter.words = "resource:image/*"
    spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new
    spec.includeTitle = true
    note_store.findNotesMetadata(auth_token, filter, 0, 9, spec).notes.map(&:title)
  end
end

##
# Index page
##
get '/' do
  erb :index
end

##
# Reset the session
##
get '/reset' do
  session.clear
  redirect '/'
end

##
# Obtain temporary credentials
##
get '/requesttoken' do
  callback_url = request.url.chomp("requesttoken").concat("callback")
  begin
    session[:request_token] = client.request_token(:oauth_callback => callback_url)
    redirect '/authorize'
  rescue => e
    @last_error = "Error obtaining temporary credentials: #{e.message}"
    erb :error
  end
end

##
# Redirect the user to Evernote for authoriation
##
get '/authorize' do
  if session[:request_token]
    redirect session[:request_token].authorize_url
  else
    # You shouldn't be invoking this if you don't have a request token
    @last_error = "Request token not set."
    erb :error
  end
end

##
# Receive callback from the Evernote authorization page
##
get '/callback' do
  unless params['oauth_verifier'] || session['request_token']
    @last_error = "Content owner did not authorize the temporary credentials"
    halt erb :error
  end
  session[:oauth_verifier] = params['oauth_verifier']
  begin
    session[:access_token] = session[:request_token].get_access_token(:oauth_verifier => session[:oauth_verifier])
    redirect '/list'
  rescue => e
    @last_error = 'Error extracting access token'
    erb :error
  end
end


##
# Access the user's Evernote account and display account data
##
get '/list' do
  begin
    # Get notebooks
    session[:notebooks] = notebooks.map(&:name)
    # Get username
    session[:username] = en_user.username
    # Get total note count
    session[:titles] = titles
    erb :index
  rescue => e
    @last_error = "Error listing notebooks: #{e.message}"
    erb :error
  end
end


__END__

@@ error
<html>
<head>
<title>Evernote Ruby Example App &mdash; Error</title>
</head>
<body>
<p>An error occurred: <%= @last_error %></p>
<p>Please <a href="/reset">start over</a>.</p>
</body>
</html>
