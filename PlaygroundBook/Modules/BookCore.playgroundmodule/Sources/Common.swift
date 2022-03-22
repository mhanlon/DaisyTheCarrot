//
//  Common.swift
//  BookCore
//
//  Created by Matthew Hanlon on 19/03/2022.
//

import Foundation
import PlaygroundSupport

public let DEBUG = false

/// Common keys for our messages
public let kCommandKey = "command"
public let kArgumentsKey = "arguments"
public let kMessageKey = "message"
public let kResultKey = "result"
public let kDidFinishKey = "didFinishProcessingCommands"
public let kSolutionKey = "solution"

/// Common commands
public let kInitCommand = "init"
public let kFinishedCommand = "finished"

/// A convenient way to get ahold of the live view as a message handler, something we do *all* the time.
public var liveViewMessageHandler: PlaygroundLiveViewMessageHandler? {
    let liveView = PlaygroundPage.current.liveView
    return liveView as? PlaygroundLiveViewMessageHandler
}

/// A convenient way to get ahold of the live view to send it messages, which is also something we'll be doing a lot.
public var liveViewProxy: PlaygroundRemoteLiveViewProxy? {
    let liveView = PlaygroundPage.current.liveView
    return liveView as? PlaygroundRemoteLiveViewProxy

}

// This will allow us to receive messages from the 'app space' back to the Swift Playground.
private var userSpaceDelegate: MainMessageHandler?

/// To be called in each main.swift at the start of each page in #hidden-code
/// **Note** that your `receive(_:)` method on your view controller will get called with an `init` command to kick things off, so you need to make sure your code handles that.
public func loadExperience() {
    userSpaceDelegate = MainMessageHandler()

    let page = PlaygroundPage.current
    let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
    proxy?.delegate = userSpaceDelegate
    
    // Mark the page as needing indefinite execution to wait for assessment results.
    page.needsIndefiniteExecution = true
    let command: [String: PlaygroundValue] = [kCommandKey: .string(kInitCommand)]
    send(message: .dictionary(command))
}

/// To be called in each main.swift at the end of the page in #hidden-code
/// **Note** that your `receive(_:)` method on your view controller will get called with an `finished` command to close things down, so you need to make sure your code handles that.
public func finishExperience() {
    let command: [String: PlaygroundValue] = [kCommandKey: .string(kFinishedCommand)]
    send(message: .dictionary(command))
}

/// A convenience method for sending messages to the 'app space' LiveViewController.
public func send(message: String) {
    liveViewProxy?.send(.dictionary([kMessageKey: .string(message)]))
}

/// Another, slightly less convenient method for sending messages to the 'app space' LiveViewController.
public func send(message: PlaygroundValue) {
    liveViewProxy?.send(message)
}

/// Our class for handling messages from the 'app space' back to the Swift Playground
/// **Note**: the expected format of the message looks like this (use the keys above to let the compiler help you a bit):
/// [
///   "result": true/false,
///   "message": "Some message...",  (optional)
///   "solution": "Some solution...",  (optional)
///   "didFinishProcessingCommands": true/false (optional)
/// ]
class MainMessageHandler: PlaygroundRemoteLiveViewProxyDelegate {
    var messages: [String] = []
    func remoteLiveViewProxy(
        _ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy,
        received message: PlaygroundValue
    ) {
        print("Received a message from the always-on live view", message)
        if case let .dictionary(response) = message {
            print(response)
            guard case let .boolean(result) = response[kResultKey] else {
                return
            }
            var solution: String? = nil
            if case let .string(unwrappedSolution) = response[kSolutionKey] {
                solution = unwrappedSolution
            }
            
            if case let .string(hint) = response[kMessageKey] {
                if !result {
                    self.messages.append(hint)
                    PlaygroundPage.current.assessmentStatus = .fail(hints: messages, solution: solution)
                } else if result {
                    // Clear the old messages out...
                    if !DEBUG {
                        self.messages.removeAll()
                    }
                    PlaygroundPage.current.assessmentStatus = .pass(message: hint)
                }
            }
            if case .boolean(_) = response[kDidFinishKey] {
                PlaygroundPage.current.finishExecution()
            }
        }
    }

    func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {}
}
