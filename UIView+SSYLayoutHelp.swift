import UIKit

extension UIView {
    func removeZeroWidthConstraintsOnSelf() {
        var widthConstraints = [NSLayoutConstraint]()
        let constraints = self.constraints
        for constraint: NSLayoutConstraint in constraints {
            if constraint.firstItem as! NSObject == self {
                if constraint.firstAttribute == .width {
                    if constraint.constant == 0.0 {
                        widthConstraints.append(constraint)
                    }
                }
            }
        }

        NSLayoutConstraint.deactivate(widthConstraints)
    }
    
    func addWidthConstraint(_ width: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(
            item:self,
            attribute:NSLayoutAttribute.width,
            relatedBy:NSLayoutRelation.equal,
            toItem:nil,
            attribute:NSLayoutAttribute.notAnAttribute,
            multiplier:1.0,
            constant:width))
        self.addConstraints(constraints)
    }
    
    /**
     "Hides" a view, with animaion, by having its width collapse to zero, or
     expands it back to normal
     
     The view must have its frame constrained by Auto Layout, and must have an
     intrinsic content size, and not have a required (priority=1000) width
     constraint.
     
     - parameter yes:  Pass `true` to collapse the view to zero width, `false`
     to expand it back to its intrinsic width
     - requires: Swift 3.0
     */

    func collapseWidth(yes: Bool) {
        if (yes) {
            self.addWidthConstraint(0.0)
        }
        else {
            self.removeZeroWidthConstraintsOnSelf()
        }
        
        let systemStandardAnimationDuration = CATransaction.animationDuration()
        UIView.animate(withDuration: systemStandardAnimationDuration) { () -> Void
            in
            self.superview?.layoutIfNeeded()
        }
    }
}

public extension Notification {
    public class UIView {
        /* Sadly, even in iOS 10, UIViewController.isEditing seems to be not
         KVO compliant.  (I tried KVO and it "just didn't work".)  So, we make
         one… */
        public static let ToggledIsEditing = Notification.Name("toggledIsEditing")
    }
}

