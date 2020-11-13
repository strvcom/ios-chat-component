Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.name         = 'STRVChatNetworkingFirestore'
  spec.module_name  = 'ChatNetworkingFirestore'
  spec.version      = '0.0.14'
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
    :tag => 'NetworkingFirestore-' + spec.version.to_s
  }

  spec.static_framework = true

  spec.cocoapods_version = '>= 1.4.0'
  spec.swift_version = '5.3'

  spec.source_files  = 'ChatNetworkingFirestore/*.swift', 'ChatNetworkingFirestore/**/*.swift'

  spec.dependency 'STRVChatCore', '~> 0.0.10'
  spec.dependency 'FirebaseCore', '~> 6.10.3'
  spec.dependency 'FirebaseFirestore', '~> 1.18.0'
  spec.dependency 'FirebaseStorage', '~> 3.9.0'

end
