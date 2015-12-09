Pod::Spec.new do |s|
  s.name         = "SwiftyBeaver"
  s.version      = "0.2.2"
  s.summary      = "Colorful, lightweight & fast logging in Swift 2"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
  SwiftyBeaver is a new, fast & very lightweight logger, with a unique combination of great features.
  It is written in Swift 2 and was released on November 28, 2015 by Sebastian Kreutzberger (Twitter: @skreutzb).
                   DESC

  s.homepage     = "https://github.com/skreutzberger/SwiftyBeaver"
  s.screenshots  = "https://cloud.githubusercontent.com/assets/564725/11452558/17fd5f04-95ec-11e5-96d2-427f62ed4f05.jpg", "https://cloud.githubusercontent.com/assets/564725/11452560/33225d16-95ec-11e5-8461-78f50b9e8da7.jpg"
  s.license      = "MIT"
  s.author       = { "Sebastian Kreutzberger" => "s.kreutzberger@googlemail.com" }
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.source       = { :git => "https://github.com/skreutzberger/SwiftyBeaver.git", :tag => "v0.2.2" }
  s.source_files  = "SwiftyBeaver", "SwiftyBeaver/Destinations"
end
