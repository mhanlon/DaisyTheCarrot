//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  A source file which is part of the auxiliary module named "BookCore".
//  Provides the implementation of the "always-on" live view.
//

import UIKit
import PlaygroundSupport

@objc(BookCore_LiveViewController)
public class LiveViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    @IBOutlet var speechLabel: UILabel!
    @IBOutlet var daisyImageView: UIImageView!
    public var daisyImage = UIImage(named: "daisy-uncolored")
    /*
    public func liveViewMessageConnectionOpened() {
        // Implement this method to be notified when the live view message connection is opened.
        // The connection will be opened when the process running Contents.swift starts running and listening for messages.
    }
    */
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.speechLabel.text = "" // blank out our speech label when the view is loaded.
        self.daisyImageView.image = self.daisyImage
    }

    /*
    public func liveViewMessageConnectionClosed() {
        // Implement this method to be notified when the live view message connection is closed.
        // The connection will be closed when the process running Contents.swift exits and is no longer listening for messages.
        // This happens when the user's code naturally finishes running, if the user presses Stop, or if there is a crash.
    }
    */

    public func receive(_ message: PlaygroundValue) {
        // Implement this method to receive messages sent from the process running Contents.swift.
        // This method is *required* by the PlaygroundLiveViewMessageHandler protocol.
        // Use this method to decode any messages sent as PlaygroundValue values and respond accordingly.
        guard case .dictionary(let dictionary) = message else {
            return
        }

        if case .string(let message) = dictionary[kMessageKey] {
            speechLabel.text = message
            daisyImageView.image = UIImage(named:"daisy-colored")
        }
    }

    @IBAction func greetButtonTapped(_ sender: Any) {
        print("Hello!")
    }
}
