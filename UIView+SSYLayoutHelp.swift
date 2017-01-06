import UIKit

extension UIView {
    var zeroWidthConstraintsOnSelf : [NSLayoutConstraint] {
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

        return widthConstraints
    }
    
    func removeZeroWidthConstraintsOnSelf() -> Bool {
        let constraints = self.zeroWidthConstraintsOnSelf
        if (constraints.count > 0) {
            NSLayoutConstraint.deactivate(constraints)
            return true
        }
        
        return false
    }
    
    func ensureZeroWidthConstraint() -> Bool {
        if (self.zeroWidthConstraintsOnSelf.count == 0) {
            self.translatesAutoresizingMaskIntoConstraints = false
            var constraints = [NSLayoutConstraint]()
            constraints.append(NSLayoutConstraint(
                item:self,
                attribute:NSLayoutAttribute.width,
                relatedBy:NSLayoutRelation.equal,
                toItem:nil,
                attribute:NSLayoutAttribute.notAnAttribute,
                multiplier:1.0,
                constant:0.0))
            self.addConstraints(constraints)
            
            return true
        }
        
        return false
    }
    
    /**
     "Hides" a view, with animation, by having its width collapse to zero, or
     expands it back to normal
     
     The view must have its frame constrained by Auto Layout, and must have an
     intrinsic content size, and not have a required (priority=1000) width
     constraint.  If I want a "regular" width constraint, I set its priority
     to 900.
     
     If this function returns `true`, you may animate the dis/appearance of
     this subview with code such as this:
     ```
     let systemStandardAnimationDuration = CATransaction.animationDuration()
     UIView.animate(withDuration: systemStandardAnimationDuration) { () -> Void
         in
         self.view.layoutIfNeeded()
     }

     ```
     
     If your animation jerks at the beginning, ensure that you are not calling
     layoutIfNeeded() twice, once without animation and once with animation.
     
     - parameter yes:  Pass `true` to collapse the view to zero width, `false`
     to expand it back to its intrinsic width
     - requires: Swift 3.0
     - returns: `true` if any constraint was added or removed, `false` if the
     function was a no-op because the constraints were already as prescribed
*/
    @discardableResult func collapseWidth(yes: Bool) -> Bool {
        if (yes) {
            return self.ensureZeroWidthConstraint()
        }
        else {
            return self.removeZeroWidthConstraintsOnSelf()
        }
    }

    var zeroHeightConstraintsOnSelf : [NSLayoutConstraint] {
        var heightConstraints = [NSLayoutConstraint]()
        let constraints = self.constraints
        for constraint: NSLayoutConstraint in constraints {
            if constraint.firstItem as! NSObject == self {
                if constraint.firstAttribute == .height {
                    if constraint.constant == 0.0 {
                        heightConstraints.append(constraint)
                    }
                }
            }
        }

        return heightConstraints
    }
    
    func removeZeroHeightConstraintsOnSelf() -> Bool {
        let constraints = self.zeroHeightConstraintsOnSelf
        if (constraints.count > 0) {
            NSLayoutConstraint.deactivate(constraints)
            return true
        }
        
        return false
    }
    
    
    func ensureZeroHeightConstraint() -> Bool {
        if (self.zeroHeightConstraintsOnSelf.count == 0) {
            self.translatesAutoresizingMaskIntoConstraints = false
            var constraints = [NSLayoutConstraint]()
            constraints.append(NSLayoutConstraint(
                item:self,
                attribute:NSLayoutAttribute.height,
                relatedBy:NSLayoutRelation.equal,
                toItem:nil,
                attribute:NSLayoutAttribute.notAnAttribute,
                multiplier:1.0,
                constant:0.0))
            self.addConstraints(constraints)
            return true
        }
        
        return false
    }
    
    /**
     Same as collapseWidth(yes:) except works in vertical instead of
     horizontal direction
     */
    @discardableResult func collapseHeight(yes: Bool) -> Bool {
        if (yes) {
            return self.ensureZeroHeightConstraint()
        }
        else {
            return self.removeZeroHeightConstraintsOnSelf()
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

