 Pod::Spec.new do |s|
  s.name             = "EZSwipeController"
  s.version          = "0.5"
  s.summary          = "UIPageViewController like Snapchat/Tinder/iOS Main Pages"
  s.description      = "Easy to use UIPageViewController to create a view navigation like Snapchat/Tinder/iOS Main Pages."
  s.homepage         = "https://github.com/goktugyil/EZSwipeController"
  s.license          = 'MIT'
  s.author           = { "goktugyil" => "gok-2@hotmail.com" }
  s.source           = { :git => "https://github.com/goktugyil/EZSwipeController.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  
  # If more than one source file: https://guides.cocoapods.org/syntax/podspec.html#source_files
  s.source_files = 'EZSwipeController.swift' 
  
  end