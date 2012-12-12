xml.instruct!
xml.Response do
  xml.Gather(timeout: "60", action: "#{Wopr.twilio_callback_host}/calls/#{sid}/gathered", numDigits: "4")
end
