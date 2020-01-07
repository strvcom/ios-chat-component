# STRVChatKit

<p align="center">
   <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">
   </a>
</p>


## Universal Chat Component

This repository contains an universal chat framework that can be easily scaled to be used in any project that contains standard in-app chat component.

## Description

The solution should be as modular and as scalable as possible. In the first phase a conversation can be created just for two users, but the framework should account with a future multichat support. Because chat is a realtime feature it should support realtime communication and animated UI updates.

The framework shouldn't be dependent on any 3rd party library including frameworks for reactive programming. A reactive wrapper can be created during a future development.

The framework should have at least 3 separate modules:

1. Interchangeable UI layer
2. Universal business logic layer (can be split into more modules)
3. Interchangeable networking layer

The interfaces between layers should be designed as universal as possible. Please bear in mind that the networking layer should be interchangeable so it shouldn't matter if it is connected to REST API or a Firebase instance. A similar statement holds for the first layer; it shouldn't matter if the UI layer uses a table view or collection view for showing messages.

## Modules

Each modules is a standalone framework target, so we can hide implementation details from each others with **internal** modifier

### STRVChatKit - Essential models and protocols

### STRVChatKitFirestore - Firestore operation adapter for codables
 
## Example

[Example](Example/)

## Features

### Conversation

- [X] Open a public one-to-many conversation
- [X] List of conversations
- [ ] Open a private conversation
- [ ] Open a private one-to-one conversation
- [ ] Get notified when conversations updated
- [ ] Implemenet background fetch for retry mechanism
- [ ] Online status indicator

### Message

- [X] Get notified when create/update messages
- [ ] Read receipts - show a flag with a time and date next to a last message the other user read
- [ ] Cache messages that failed to be sent
- [ ] Retry mechanism for sending messages
- [ ] Continue with sending a message even if user sends an app to background

### User

- [ ] Name
- [ ] Avatar
  
### Supported Message Types

- [X] Text
- [ ] Photo
- [ ] Video
- [ ] Location
 
## Future features

**These features will be added in later stages of development but the framework must be developed with bearing them in mind.**

- [ ] Persistence
- [ ] Moderation
- [ ] Extensions - RxSwift, PromiseKit...etc
- [ ] Typing indicator
- [ ] Notifications

## References

### Exist Product

- Sendbird [doc](https://docs.sendbird.com/)
- Layer [doc](https://docs.layer.com/)

### Open Source UI Components

- [MessageKit](https://github.com/MessageKit/MessageKit)
- [JSQMessagesViewController](https://github.com/jessesquires/JSQMessagesViewController)