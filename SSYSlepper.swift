/*
 This file is a modification of the GMStepper class published by
 Gunay Mert Karadogan, which has the following license:
 
 The MIT License (MIT)
 
 Copyright (c) 2015 Gunay Mert Karadogan
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, modelObject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

/* This file is documented with Xcode Markup:
 https://developer.apple.com/library/content/documentation/Xcode/Reference/xcode_markup_formatting_ref/MarkupFunctionality.html#//apple_ref/doc/uid/TP40016497-CH54-SW1
 */

/**
 A control which is a combination *slider* (as in UISlidr) and *stepper* (as
 in `UIStepper`).  It is typically 200 points wide and 30 points high.  The user
 may change the value of the control either by swiping to a desried x position,
 wherein the left edge produces the minimum value and the right edge produces
 the maximum value, or by clicking the stepper "buttons" which are on the left
 and right edges.
 
 This is a modification of the [GMStepper](https://github.com/gmertk/GMStepper)
 class published by Gunay Mert Karadogan.  GMStepper lacks the *slider*
 response.  Conversely, SSYSlepper lacks the animations of GMStepper because,
 especially with the slider action, I thought it made it too confusing to the
 user, and also I wanted to simplify the code.
 
 - requires: Swift 3.0, Auto Layout, tested with ios 10
*/

@IBDesignable public class SSYSlepper: UIControl {
    
    /// Returns `true` if the instance is displaying items, `false` if numbers
    public func isItemized() -> Bool {
        return (stepValue == 1.0) && (items.count > 0)
    }
    
    /// Current value of the slepper. Defaults to 0.
    @IBInspectable public var value: Double = 0 {
        didSet {
            
            if self.isItemized() {
                label.text = items[Int(value)]
            }
            else {
                /* We "round" the given value as required, by converting it to
                 a string with our defining floatFormat, then converting
                 back to a Double. */
                value = min(maximumValue, max(minimumValue, value))
                let format = String("%\(self.floatFormat)f")!
                let stringValue = String(format:format, self.value)
                value = Double(stringValue)!

                label.text = stringValue
            }
            
            /* oldValue is a parameter to this function, built in by Swift. */
            if oldValue != value {
                sendActions(for: .valueChanged)
            }
            
            self.updateButtonColors()
        }
    }
    
    /// Minimum value of the slepper. Must be less than maximumValue. Defaults to 0.
    @IBInspectable public var minimumValue: Double = 0 {
        didSet {
            value = min(maximumValue, max(minimumValue, value))
        }
    }
    
    /// Maximum value of the slepper. Must be more than minimumValue. Defaults to 100.
    @IBInspectable public var maximumValue: Double = 100 {
        didSet {
            value = min(maximumValue, max(minimumValue, value))
        }
    }
    
    /// Step/Increment value of the slepper, same as in UIStepper. Defaults to 1.
    @IBInspectable public var stepValue: Double = 1
    
    /// The same as UIStepper's autorepeat. If true, holding on the buttons or keeping the pan gesture alters the value repeatedly. Defaults to true.
    @IBInspectable public var autorepeat: Bool = true
    
    /// The floating point format used to display the value of the slepper in the user interface.  Relative to the floating point string format "%XX.XXf", this is the part "XX.XX".  Defaults to "0.0", which means a simple integer with no leading spaces, no leading zeros, no decimal point.
    @IBInspectable public var floatFormat: String = "0.0"
    
    /// Text color of the *+* and *-* buttons on the left and right. Defaults to white.
    @IBInspectable public var buttonsTextColor: UIColor = UIColor.white {
        didSet {
            for button in [leftButton, rightButton] {
                button.setTitleColor(buttonsTextColor, for: .normal)
            }
        }
    }
    
    /// Background color of the *+* and *-* buttons on the left and right. Defaults to dark blue.
    @IBInspectable public var buttonsBackgroundColor: UIColor = UIColor(red:0.21, green:0.5, blue:0.74, alpha:1) {
        didSet {
            for button in [leftButton, rightButton] {
                button.backgroundColor = buttonsBackgroundColor
            }
            backgroundColor = buttonsBackgroundColor
        }
    }
    
    /// Text color of the number displayed in the user interface. Defaults to white.
    @IBInspectable public var labelTextColor: UIColor = UIColor.white {
        didSet {
            label.textColor = labelTextColor
        }
    }
    
    /// Background color of the number displayed in the user interface. Defaults to a lighter blue.
    @IBInspectable public var labelBackgroundColor: UIColor = UIColor(red:0.26, green:0.6, blue:0.87, alpha:1) {
        didSet {
            label.backgroundColor = labelBackgroundColor
        }
    }
    
    /// Font of the number displayed in the user interface. Defaults to system font, 25.0 points in size.
    public var labelFont = UIFont.systemFont(ofSize: 25.0) {
        didSet {
            label.font = labelFont
        }
    }
    
    /// Corner radius of the slepper's layer. Defaults to 4.0.
    @IBInspectable public var cornerRadius: CGFloat = 4.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
        }
    }
    
    /// Border width of the slepper. Defaults to 0.0.
    @IBInspectable public var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
            label.layer.borderWidth = borderWidth
        }
    }
    
    /// Color of the border of the slepper. Defaults to clear color.
    @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            label.layer.borderColor = borderColor.cgColor
        }
    }
    
    /// Fraction of the slepper's width allocated to the middle part which shows the number. Must be between 0 and 1. Defaults to 0.5.
    @IBInspectable public var labelWidthWeight: CGFloat = 0.5 {
        didSet {
            labelWidthWeight = min(1, max(0, labelWidthWeight))
            setNeedsLayout()
        }
    }
    
    /// Color of the *+* or *-* buttons on the right and left if the value equals their respective limit
    @IBInspectable public var buttonBackgroundColorAtLimit: UIColor = UIColor(red:0.26,
                                                                              green:0.6,
                                                                              blue:0.87,
                                                                              alpha:1)
    
    lazy var leftButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = self.buttonsBackgroundColor
        button.addTarget(self, action: #selector(SSYSlepper.leftButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(SSYSlepper.buttonTouchUp), for: .touchUpInside)
        button.addTarget(self, action: #selector(SSYSlepper.buttonTouchUp), for: .touchUpOutside)

        let length = self.frame.height
        let image = SSYVectorImages.plusMinus(plus: false,
                                              length: length,
                                              inset: length/4,
                                              radians: 0.0,
                                              color: self.buttonsTextColor)
        button.setImage(image,
                        for: UIControlState.normal)
        /* The following three lines should not be necessary, according to
         UIButton.setImage:for:() documentation.  But in iOS 10.1, they are
         necessary.  Is this a bug in ios 10.1? */
        button.setImage(image, for: UIControlState.focused)
        button.setImage(image, for: UIControlState.highlighted)
        button.setImage(image, for: UIControlState.disabled)

        return button
    }()
    
    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = self.buttonsBackgroundColor
        button.addTarget(self, action: #selector(SSYSlepper.rightButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(SSYSlepper.buttonTouchUp), for: .touchUpInside)
        button.addTarget(self, action: #selector(SSYSlepper.buttonTouchUp), for: .touchUpOutside)

        let length = self.frame.height
        let image = SSYVectorImages.plusMinus(plus: true,
                                              length: length,
                                              inset: length/4,
                                              radians: 0.0,
                                              color: self.buttonsTextColor)
        button.setImage(image, for: UIControlState.normal)
        /* The following three lines should not be necessary, according to
         UIButton.setImage:for:() documentation.  But in iOS 10.1, they are
         necessary.  Is this a bug in ios 10.1? */
        button.setImage(image, for: UIControlState.focused)
        button.setImage(image, for: UIControlState.highlighted)
        button.setImage(image,for: UIControlState.disabled)

        return button
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        let format = String("%\(self.floatFormat)f")!
        label.text = String(format:format, self.value)
        label.textColor = self.labelTextColor
        label.backgroundColor = self.labelBackgroundColor
        label.font = self.labelFont
        label.isUserInteractionEnabled = true
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SSYSlepper.handlePan))
        panRecognizer.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panRecognizer)
        return label
    }()
    
    var labelOriginalCenter: CGPoint!
    var labelMaximumCenterX: CGFloat!
    var labelMinimumCenterX: CGFloat!
    
    enum StepperState {
        case stable, increasing, decreasing
    }
    
    var stepperState = StepperState.stable {
        didSet {
            if stepperState != .stable {
                updateValueFromStepper()
                if autorepeat {
                    scheduleAutorepeatTimer()
                }
            }
        }
    }
    
    /**
    Apparently you set this if you want the instance to display a selected
    string instead of a number, in other words, behave like an enumeration.
    */
    public var items : [String] = [] {
        didSet {
            // If we have items, we will display them as steps
            
            if stepValue == 1.0 && items.count > 0 {
                
                var value = Int(self.value)
                
                if value >= items.count {
                    value = items.count - 1
                    self.value = Double(value)
                }
                else {
                    label.text = items[value]
                }
            }
        }
    }
    
    var autorepeatTimer: Timer?
    
    let autorepeatInterval = TimeInterval(0.5)
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(label)
        
        backgroundColor = buttonsBackgroundColor
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SSYSlepper.reset),
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: nil)
    }
    
    public override func layoutSubviews() {
        let buttonWidth = bounds.size.width * ((1 - labelWidthWeight) / 2)
        let labelWidth = bounds.size.width * labelWidthWeight
        
        leftButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: bounds.size.height)
        label.frame = CGRect(x: buttonWidth, y: 0, width: labelWidth, height: bounds.size.height)
        rightButton.frame = CGRect(x: labelWidth + buttonWidth, y: 0, width: buttonWidth, height: bounds.size.height)
    }
    
    /* Seems overly pedantic to use this function instead of just setting the
     value directly in stepperState.didSet(), but it makes sense because this
     function is also called by the autorepeat timer. */
    func updateValueFromStepper() {
        if stepperState == .increasing {
            value += stepValue
        }
        else if stepperState == .decreasing {
            value -= stepValue
        }
    }
    
    deinit {
        resetAutorepeatTimer()
        NotificationCenter.default.removeObserver(self)
    }
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            leftButton.isEnabled = false
            rightButton.isEnabled = false
        case .changed:
            gesture.setTranslation(CGPoint.zero, in: label)
            
            let newLocation = gesture.location(in: self).x
            let fractionOfAPoint = CGFloat(0.1)
            
            value = minimumValue + Double((newLocation/self.frame.width)) * (maximumValue - minimumValue) + 1
            
            if (newLocation > fractionOfAPoint) && (newLocation > self.frame.width - fractionOfAPoint) {
                stepperState = .stable
                resetAutorepeatTimer()
                
            }
        case .ended, .cancelled, .failed:
            reset()
        default:
            break
        }
    }
    
    func reset() {
        stepperState = .stable
        resetAutorepeatTimer()
        
        leftButton.isEnabled = true
        rightButton.isEnabled = true
        label.isUserInteractionEnabled = true
    }
    
    func updateButtonColors() {
        if value == minimumValue {
            leftButton.backgroundColor = self.buttonBackgroundColorAtLimit
            rightButton.backgroundColor = buttonsBackgroundColor
        }
        else if value == maximumValue {
            leftButton.backgroundColor = buttonsBackgroundColor
            rightButton.backgroundColor = self.buttonBackgroundColorAtLimit
        }
        else {
            leftButton.backgroundColor = buttonsBackgroundColor
            rightButton.backgroundColor = buttonsBackgroundColor
        }
    }
    
    func scheduleAutorepeatTimer() {
        autorepeatTimer = Timer.scheduledTimer(timeInterval: autorepeatInterval,
                                               target: self,
                                               selector: #selector(SSYSlepper.updateValueFromStepper),
                                               userInfo: nil,
                                               repeats: true)
    }
    
    func resetAutorepeatTimer() {
        if let timer = autorepeatTimer {
            timer.invalidate()
            self.autorepeatTimer = nil
        }
    }
    
    func leftButtonTouchDown(button: UIButton) {
        rightButton.isEnabled = false
        label.isUserInteractionEnabled = false
        resetAutorepeatTimer()
        
        if value != minimumValue {
            stepperState = .decreasing
        }
        
    }
    
    func rightButtonTouchDown(button: UIButton) {
        leftButton.isEnabled = false
        label.isUserInteractionEnabled = false
        resetAutorepeatTimer()
        
        if value != maximumValue {
            stepperState = .increasing
        }
    }
    
    func buttonTouchUp(button: UIButton) {
        reset()
    }
}

