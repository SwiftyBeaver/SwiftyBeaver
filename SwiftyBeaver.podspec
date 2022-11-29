Pod::Spec.new do |s|
  s.name         = "SwiftyBeaver-SVMK"
  s.version      = "1.9.6"
  s.summary      = "Convenient logging during development & release in Swift 4 & 5."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
Easy-to-use, extensible & powerful logging & analytics for Swift 4 and Swift 5.
Great for development & release due to its support for many logging destinations & platforms.
                   DESC

  s.homepage     = "https://github.com/SurveyMonkey-Mobile/SwiftyBeaver"
  s.license      = "MIT"
  s.author       = { "Sebastian Kreutzberger" => "s.kreutzberger@googlemail.com" }
  s.ios.deployment_target = "13.4"
  s.watchos.deployment_target = "6.2"
  s.tvos.deployment_target = "13.4"
  s.osx.deployment_target = "10.15.4"
  s.source       = { :git => "https://github.com/SurveyMonkey-Mobile/SwiftyBeaver.git", :tag => "1.9.6-svmk" }
  s.source_files  = "Sources"
  s.swift_versions = ['4.0', '4.2', '5.0', '5.1']
end
