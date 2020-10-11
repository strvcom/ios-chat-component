Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.name         = "STRVChatCore"
  spec.module_name  = "ChatCore"
  spec.version      = "0.0.4"
  spec.summary      = "Core framework of Universal Modular Chat Component from STRV"
  spec.description  = <<-DESC
  					Universal Modular Chat Component from STRV. 
  					Core is an universal business logic that you can use with any UI and networking
  					that convorms to respective protocols.
                   DESC
  spec.homepage     = "https://github.com/strvcom/ios-chat-component"
  

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.authors      = { "Jan Schwarz" => "jan.schwarz@strv.com", "Tomáš Čejka" => "tomas.cejka@strv.com", "Daniel Pecher" => "daniel.pecher@strv.com", "Mireya Orta" => "mireya.orta@strv.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.platform     = :ios, "12.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source = { :git => "https://github.com/strvcom/ios-chat-component.git", :tag => spec.version }

  spec.cocoapods_version = '>= 1.4.0'
  spec.swift_version = '5.3'

	spec.source_files  = "ChatCore/*.swift", "ChatCore/**/*.swift"
end
