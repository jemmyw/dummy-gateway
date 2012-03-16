require 'sinatra'
require 'couchrest'

module JavascriptHelper
  def escape_javascript(html_content)
    return '' unless html_content
    javascript_mapping = { '\\' => '\\\\', '</' => '<\/', "\r\n" => '\n', "\n" => '\n' }
    javascript_mapping.merge("\r" => '\n', '"' => '\\"', "'" => "\\'")
    escaped_string = html_content.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { javascript_mapping[$1] }
    "\"#{escaped_string}\""
  end
end

use Rack::Auth::Basic do |username, password|
  username == 'api' && password == 'zwUx8HAk4NmfhaheqQ'
end

before do
  @db = CouchRest.database!("http://127.0.0.1:5984/dummy_sms")
end

helpers do
  include JavascriptHelper
end

post '/send_sms' do
  begin
    response = @db.save_doc({:number => params[:number], :message => params[:message], :url => params[:url], :received_at => Time.now.to_i})
    @id = response["id"].strip
    erb :send_sms
  rescue => @error
    erb :error
  end
end

get '/send_sms' do
  erb :send_sms_instructions
end
