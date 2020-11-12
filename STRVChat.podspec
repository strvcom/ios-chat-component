Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.name         = 'STRVChat'
  spec.module_name  = 'Chat'
  spec.version      = '0.0.8'
  spec.summary      = 'Universal Modular Chat Component from STRV'
  spec.description  = <<-DESC
  					Universal Modular Chat Component from STRV. 
  					Core is an universal business logic that you can use with any UI and networking
  					that convorms to respective protocols.
                   DESC
  spec.homepage     = 'https://github.com/strvcom/ios-chat-component'
  

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.license      = { :type => 'MIT', :file => 'LICENSE' }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.authors      = { 'Jan Schwarz' => 'jan.schwarz@strv.com', 'Tomáš Čejka' => 'tomas.cejka@strv.com', 'Daniel Pecher' => 'daniel.pecher@strv.com', 'Mireya Orta' => 'mireya.orta@strv.com' }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.platform     = :ios, '12.0'

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source = { 
    :git => 'https://github.com/strvcom/ios-chat-component.git',
    :tag => 'Chat-' + spec.version.to_s
  }

  spec.static_framework = true
    
  spec.default_subspec = 'ChatMessageKitFirestore'
  spec.cocoapods_version = '>= 1.4.0'
  spec.swift_version = '5.3'

  # ――― Core ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.subspec 'Core' do |subspec|
	  subspec.dependency 'STRVChatCore', '~> 0.0.10'
  end

  # ――― MessageKitUI ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.subspec 'UI' do |subspec|
	  subspec.dependency 'STRVChat/Core'
	  subspec.dependency 'STRVChatUI', '~> 0.0.7'
  end

  # ――― NetworkingFirestore ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.subspec 'NetworkingFirestore' do |subspec|
	  subspec.dependency 'STRVChat/Core'
	  subspec.dependency 'STRVChatNetworkingFirestore', '~> 0.0.12'
  end

  spec.subspec 'ChatMessageKitFirestore' do |subspec|
    subspec.source_files  = 'Chat/*.swift', 'Chat/**/*.swift'

    subspec.dependency 'STRVChat/UI'
    subspec.dependency 'STRVChat/NetworkingFirestore'
  end

end
