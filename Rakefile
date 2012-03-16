require 'couchrest'
require 'rest_client'

def send_reply(url, number, content)
  puts "Sending reply to #{url}"
  RestClient.post(url, :params => {:from => number, :type => "reply", :message => content})
end

namespace :dummy do
  task :replies do
    $running = true

    trap("TERM") { $running = false }

    @db = CouchRest.database!("http://127.0.0.1:5984/dummy_sms")

    doc = @db.get("_design/first") rescue CouchRest::Design.new
    doc.name = "first"
    doc[:views] ||= {}
    doc[:views][:unsent] = {
      :map => %Q^
        function(doc) {
          if(!doc.sent_at && doc.number && doc.url) {
            emit(null, doc);
          }
        }
      ^
    }
    doc.database = @db
    doc.save

    while $running
      incoming = @db.view('first/unsent')['rows']

      incoming.each do |sms|
        sms = sms["value"]
        time = Time.at(sms['received_at'])

        if sms['received_at'].to_i > (Time.now.to_i - (60 + rand(4)*60))
          sms['sent_at'] = Time.now.to_i
          @db.save_doc(sms)
          send_reply(sms['url'], sms['number'], 'YES') rescue nil
        end
      end

      sleep 1
    end
  end
end
