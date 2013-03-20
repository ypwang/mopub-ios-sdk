#!/usr/bin/env ruby

#Add to your sudoers file:
#USERNAME ALL=NOPASSWD:/usr/sbin/networksetup
#where USERNAME is the user that will be running this script

require 'webrick/httpproxy'

network = ARGV[0] || 'Wi-Fi'

puts "Starting proxy on #{network}"
`sudo networksetup -setwebproxy #{network} 127.0.0.1 9999 off`
`sudo networksetup -setwebproxystate #{network} on`

$stderr = StringIO.new

file_path = File.join(File.dirname(__FILE__), 'proxy.log')
f = File.open(file_path, 'w')

handler = Proc.new do |req,res|
  path = req.request_uri.to_s
  if path =~ /ads\.mopub\.com\/m\/imp/
    f << path
    f << "\n"
  end
end

s = WEBrick::HTTPProxyServer.new(:Port => 9999, :RequestCallback => handler);
trap("INT") { s.shutdown }
s.start

at_exit do
  puts "Stopping proxy"
  f.close
  `sudo networksetup -setwebproxystate #{network} off`
end