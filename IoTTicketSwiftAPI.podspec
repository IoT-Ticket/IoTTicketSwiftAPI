Pod::Spec.new do |s|
 s.name = 'IoTTicketSwiftAPI'
 s.version = '0.0.1'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'IoT-Ticket REST client in Swift'
 s.homepage = 'https://www.iot-ticket.com/'
 s.authors = { "Daniel Egerev" => "daniel.egerev@wapice.com" }
 s.source = { :git => "https://github.com/iDanbo/IoTTicketSwiftAPI.git", :tag => "v"+s.version.to_s }
 s.platforms     = { :ios => "8.0", :osx => "10.10", :tvos => "9.0", :watchos => "2.0" }
 s.requires_arc = true

 s.default_subspec = "Core"
 s.subspec "Core" do |ss|
     ss.source_files  = "Sources/*.swift"
     ss.framework  = "Foundation"
 end

end
