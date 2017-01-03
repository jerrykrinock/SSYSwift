import UIKit

extension UIView {
    func removeWidthConstraints() {
        var widthConstraints = [NSLayoutConstraint]()
        var constraints: [NSLayoutConstraint]
        // See Note 1 below
        constraints = self.constraints
        for constraint: NSLayoutConstraint in constraints {
            if constraint.firstItem as! NSObject == self {
                if constraint.firstAttribute == .width {
                    widthConstraints.append(constraint)
                }
            }
        }
        constraints = self.superview!.constraints
        for constraint: NSLayoutConstraint in constraints {
            if constraint.firstItem as! NSObject == self {
                if constraint.firstAttribute == .width {
                    widthConstraints.append(constraint)
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
    
    func collapseWidth(yes: Bool) {
        if (yes) {
            self.addWidthConstraint(0.0)
        }
        else {
            self.removeWidthConstraints()
        }
        
        let systemStandardAnimationDuration = CATransaction.animationDuration()
        UIView.animate(withDuration: systemStandardAnimationDuration) { () -> Void
            in
            self.superview?.layoutIfNeeded()
        }
    }
}

/* Note 1
 
 From -[NSView addConstraint:] documentation:
 
 “The constraint must involve only views that are within scope of the receiving view. Specifically, any views involved must be either the receiving view itself, or a subview of the receiving view. Constraints that are added to a view are said to be held by that view…”
 
 The fact that constraints may be “held” by either of *two* views makes it a little ambiguous to replace constraints, which is necessary to rearrange views while running.  Prior to adding new constraints, you need to remove conflicting old constraints.  To find them, you need to consider the -constraints of *two* views.
 */

public extension Notification {
    public class UIView {
        /* Sadly, even in iOS 10, UIViewController.isEditing seems to be not
         KVO compliant.  (I tried KVO and it "just didn't work".)  So, we make
         one… */
        public static let ToggledIsEditing = Notification.Name("toggledIsEditing")
    }
}

