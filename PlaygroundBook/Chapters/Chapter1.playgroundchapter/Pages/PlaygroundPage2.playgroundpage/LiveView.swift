//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Instantiates a live view and passes it to the PlaygroundSupport framework.
//

import UIKit
import BookCore
import PlaygroundSupport

// Instantiate a new instance of the live view from BookCore and pass it to PlaygroundSupport, but only if it's a LiveViewController (which it will be).
if let liveView = instantiateLiveView() as? LiveViewController {
    liveView.daisyImage = UIImage(named:"daisy-colored")
    PlaygroundPage.current.liveView = liveView
}
