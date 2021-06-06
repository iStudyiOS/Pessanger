//
//  ChatViewModel.swift
//  Pessanger
//
//  Created by 홍경표 on 2021/05/23.
//

import Foundation
import Combine

final class ChatViewModel: ObservableObject {
	
	var messages: Dynamic<[Message]> = .init([])
	var lastMessage: Message = .init(isMe: true, sender: "", content: "", time: Date())  {
		didSet {
			unReadMessageCount += 1
			objectWillChange.send()
		}
	}
	var unReadMessageCount = -1
	private(set) var opponentName: Dynamic<String>
	private let chatRoom: ChatController.ChatRoomController
	private var observeLastMessageCancellable: AnyCancellable?
	private var observeNewMessagesCancellable: AnyCancellable?
	var uid: String {
		chatRoom.uid
	}
	init(opponentName: String, chatRoom: ChatController.ChatRoomController) {
		self.opponentName = .init(opponentName)
		self.chatRoom = chatRoom
		startPeeking()
  }
	
	func leaveChatRoom() {
		chatRoom.disregardMessages()
		observeNewMessagesCancellable = nil
		messages.value = []
	}
	
	func enterToChatRoom() {
		guard let bucket = chatRoom.lastBucket else {
			return
		}
		chatRoom.stareMessages(bucket: bucket)
		observeNewMessagesCancellable = chatRoom.$newMessage.sink { [weak self] in
			guard let strongSelf = self,
						let data = $0 else{
				return
			}
			strongSelf.messages.value.append(strongSelf.convert(data: data))
		}
	}
	
	private func startPeeking() {
		observeLastMessageCancellable =
			chatRoom.$lastMessage.sink(receiveValue: { [weak self] data in
				guard let strongSelf = self else {
					return
				}
				strongSelf.lastMessage = strongSelf.convert(data: data)
			})
	}
	
	func sendMessage(content: String, url: URL? = nil) {
		_ = chatRoom.sendMessage(content, url: url)
	}
	
	private func convert(data: MessageData) -> Message {
		Message(isMe: data.senderUid == chatRoom.user.uid,
						sender: chatRoom.findUser(uid: data.senderUid).nickname,
						content: data.content,
						time: data.date)
	}
  
  func addMessage(_ newMessage: Message) {
    messages.value.append(newMessage)
  }
  
  func receiveMessage() { // TODO: Firebase 연동 후 메시지 수신했을 때,,
    DispatchQueue.global().asyncAfter(deadline: .now()+1) { [weak self] in
      guard let self = self else { return }
      var randomContent = (1...Int.random(in: 1...3)).map { _ in
        String(repeating: "\(Int.random(in: 0...9))", count: Int.random(in: 1...10)) + "\n"
      }.reduce("", +)
      randomContent.removeLast() // 마지막 \n 제거
      let randomMessage = Message(
        isMe: false,
        sender: self.opponentName.value,
        content: randomContent,
        time: Date()
      )
      self.messages.value.append(randomMessage)
    }
  }
}

extension ChatViewModel: Hashable {
	
	static func == (lhs: ChatViewModel, rhs: ChatViewModel) -> Bool {
		lhs.chatRoom.uid  == rhs.chatRoom.uid
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(chatRoom.uid)
	}
}
