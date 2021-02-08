
install! 'cocoapods', :deterministic_uuids => false

# Uncomment the next line to define a global platform for your project
platform :ios, '12.1'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

workspace 'AppleWatchProject'

project 'AppleWatchProject/AppleWatchProject.project'

def shared_pods

    inhibit_all_warnings!
    pod 'RxSwift'
    pod 'RxSwiftExt'
    pod 'RxCocoa'
end

# Application

target 'AppleWatchProject' do
    project 'AppleWatchProject.project'
    shared_pods
end

