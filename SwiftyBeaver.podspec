Pod::Spec.new do |s|
  s.name         = "SwiftyBeaver"
  s.version      = "1.0.3"
  s.summary      = "Convenient logging during development & release in Swift 2 & 3"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
Easy-to-use, extensible & powerful logging & analytics for Swift 2 & 3.
Great for development & release due to its support for many logging destinations & platforms.
                   DESC

  s.homepage     = "https://github.com/SwiftyBeaver/SwiftyBeaver"
  s.screenshots  = "https://cloud.githubusercontent.com/assets/564725/11452558/17fd5f04-95ec-11e5-96d2-427f62ed4f05.jpg", "https://cloud.githubusercontent.com/assets/564725/11452560/33225d16-95ec-11e5-8461-78f50b9e8da7.jpg"
  s.license      = "MIT"
  s.author       = { "Sebastian Kreutzberger" => "s.kreutzberger@googlemail.com" }
  s.ios.deployment_target = "8.0"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/SwiftyBeaver/SwiftyBeaver.git", :tag => "1.0.3" }
  s.source_files  = "sources"
end
