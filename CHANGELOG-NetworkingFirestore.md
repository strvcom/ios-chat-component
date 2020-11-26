# ChatNetworkingFirestore framework Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)

__Sections__

 - `Added` for new features.
 - `Changed` for changes in existing functionality.
 - `Deprecated` for once-stable features removed in upcoming releases.
 - `Removed` for deprecated features removed in this release.
 - `Fixed` for any bug fixes.

 ## [0.0.15]

 #### Fixed
 - Fix duplicaton of cached messages in Core
 - Fix default date decoding

 ## [0.0.14]

 #### Changed
 - When updating seen messages, update only current user's data instead of updating the whole `seen` map.

 ## [0.0.13]

 #### Changed
 - Added ability to include custom data in seen object

 ## [0.0.12]

 #### Fixed
 - Fixed podspec syntax

 ## [0.0.11]

 #### Changed
 - Updated version tagging

 ## [0.0.10]

 #### Changed
 - Move `typingUsers` variable to conversation object instead of using a subcollection. Client app can now just listen to conversation and read `typingUsers` from there.
 - Make providing a `UserManager` to networking optional

 ## [0.0.9]

 #### Changed
 - Add public init to ChatFirestoreUserManager to allow creating custom user managers outside of the component
 - Add updateLastMessage variable to Firestore config

 ## [0.0.8]

 #### Changed
 - Order conversations based on last message timestamp descending
