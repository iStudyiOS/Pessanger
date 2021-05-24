//
//  ChatViewModel.swift
//  Pessanger
//
//  Created by 홍경표 on 2021/05/23.
//

import Foundation

final class ChatViewModel {
  let messages: Dynamic<[Message]> = .init([])
  let opponentName: Dynamic<String> = .init("")
  
  init(opponentName: String) {
    self.opponentName.value = opponentName
    fetchMessages()
  }
  
  private func fetchMessages() { // TODO: DB에서 메시지들 가져와야함,,
    DispatchQueue.global().async { [weak self] in
      self?.messages.value = [
        Message(isMe: false, sender: "Elon Musk", content: "Hello", time: nil),
        Message(isMe: false, sender: "Elon Musk", content: "Go DOGE", time: nil),
        Message(isMe: true, sender: "Pio", content: "Hi h i", time: nil),
      ]
    }
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
        time: nil
      )
      self.messages.value.append(randomMessage)
    }
  }
  
}
