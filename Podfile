platform :ios, '8.0'
use_frameworks!

target "homework" do
    pod 'Fuzi', '~> 1.0.0'
    pod 'Kanna', git: 'https://github.com/tid-kijyun/Kanna.git', branch: 'swift3.0'
    pod 'SQLite.swift', git: 'https://github.com/stephencelis/SQLite.swift.git', branch: 'swift3-mariotaku'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
