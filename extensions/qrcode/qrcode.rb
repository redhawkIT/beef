#
# Copyright (c) 2006-2012 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Qrcode 

  module QrcodeGenerator

    BeEF::API::Registrar.instance.register(BeEF::Extension::Qrcode::QrcodeGenerator, BeEF::API::Server, 'pre_http_start')
    
    def self.pre_http_start(http_hook_server)
      require 'uri'
      
      configuration = BeEF::Core::Configuration.instance
      BeEF::Core::Console::Banners.interfaces.each do |int|
        next if int == "localhost" or int == "127.0.0.1"
        print_success "QRCode images available for interface: #{int}"
        data = ""
        configuration.get("beef.extension.qrcode.target").each do |target|
          url = "http://#{int}:#{configuration.get("beef.http.port")}#{target}"
          url = URI.escape(url,Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          data += "https://chart.googleapis.com/chart?cht=qr&chs=#{configuration.get("beef.extension.qrcode.qrsize")}&chl=#{url}\n"
        end
        print_more data
      end
    end  
    
  end


end
end
end
