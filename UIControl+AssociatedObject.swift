import Foundation
import UIKit
import ObjectiveC

/**
 This extension adds a `modelObject` property to UIControl objects.
 
 The trick for adding such properties to the UIControl (or any object for that
 matter) is to wrap around Objective-C Associated Objects.  The idea may have
 multiple inventors:
 
 http://stackoverflow.com/questions/24133058/is-there-a-way-to-set-associated-objects-in-swift
 http://nshipster.com/swift-objc-runtime/
 */
extension UIControl {
    private struct AssociatedKeys {
        static var modelObject = "ssy_modelObject"
    }
    
    /**
     I use this, for example, to extend the buttons in custom table cells which
     support more than one action, each one triggered by a button.  In
     prepare(for segue:sender:), the model object associated with the buttons'
     row is typically needed by the destination, so I want to assign this model
     object to the segue destination's detail item.  The sender is the button
     that was clicked.  With this extension, the button now has this property,
     which we have set after creating the cell, in configureCell().
     */
    var modelObject: Any? {
        get {
            let got = objc_getAssociatedObject(self, &AssociatedKeys.modelObject) as Any
            return got
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.modelObject,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
}
