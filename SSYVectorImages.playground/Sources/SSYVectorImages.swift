/* This file is documented with Xcode Markup:
 https://developer.apple.com/library/content/documentation/Xcode/Reference/xcode_markup_formatting_ref/MarkupFunctionality.html#//apple_ref/doc/uid/TP40016497-CH54-SW1
 */

import Foundation
import UIKit

/* This file is only for iOS for now, but here is a start, in case we ever
 want to use this for macOS. */
#if os(iOS)
    typealias OSColor = UIColor
    typealias OSImage = UIImage
    typealias OSFont = UIFont
    typealias OSBezierPath = UIBezierPath
    typealias OSSize = CGSize
    typealias OSRect = CGRect
#else // macOS
    typealias OSColor = NSColor
    typealias OSImage = NSImage
    typealias OSFont = NSFont
    typealias OSBezierPath = NSBezierPath
    typealias OSSize = NSSize
    typealias OSRect = NSRect
#endif


/**
 A struct which provides a multitude of public class functions, each of which
 produces a different vector image.  Many provide line drawings, useful as
 simple *Jonny Ives flat* style icons.  Each such function accepts parameters to
 customize the size, rotation, color, filling, weight, etc. of the returned
 image.
 
 To simplify the writing of new functions to support other shapes, call the
 -bezierPathForNormalizedDrawing().  You draw your shape in this bezier
 path, assuming that canvas is a nice 100 x 100 points, with whatever angular
 orientation makes it easiest to draw, then call func finishNormalizedDrawing()
 which extracts an image from your bezier path.  The func
 -bezierPathForNormalizedDrawing() has done the transformation required to
 return an image of the requested size and rotation.
 
 - todo: Add more shapes by porting from my
 [SSYVectorImages Objective-C class](https://github.com/jerrykrinock/ClassesObjC/blob/master/SSYVectorImages.h).
 
 - requires: Swift 3.0, tested with iOS 10
 */
public struct SSYVectorImages {
    /**
     Returns a bezier path which will draw in a square graphics context which
     has been transformed from a specified size such that you can draw in an
     square of size 100 x 100 points with origin at the center.  After drawing,
     you should call `finishedNormalzedDrawing()` to get your image.
     - important:
     - parameter length:
     - parameter radians:  Amount by which
     - Returns:
     - Throws:
     - Requires:
     */
    static func bezierPathForNormalizedDrawing(
        length: CGFloat,
        radians: CGFloat
        ) -> UIBezierPath {
        
        let path = UIBezierPath()
        
        /* If `length` is nil, UIGraphicsBeginImageContextWithOptions will
         *fail* to create and push a graphics context onto the graphics context
         stack as expected.  It is essentially a no-op.  If, furthermore,
         the graphics context stack is empty (as will be the case if we are
         rendering an image for an IBDesignableView in Interface Builder) the
         subsequent call to UIGraphicsGetCurrentContext will return nil.
         
         In the particular case of IBDesignable, the target will compile and the
         product will work, but the IBDesignable view will not render in
         Interface Builder, and the Issue Navigator will indicate list this
         mysterious error:
         
         "Failed to render and update auto layout status … The agent crashed"
         
         To avoid this and similar issues, we check that length > 0, and
         defensively `if let` the context. */
        if (length > 0.0) {
            UIGraphicsBeginImageContextWithOptions(
                CGSize(
                    width: length,
                    height: length),
                false,
                0)
            
            if let context = UIGraphicsGetCurrentContext() {
                let scale: CGFloat = length / 100.0
                context.scaleBy(x: scale, y: -scale)
                context.translateBy(x: 50.0, y: -50.0)
                context.rotate(by: radians)
            }
        }
        
        return (path)
    }
    
    static func finishNormalizedDrawing() -> UIImage {
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        /* `image` may be nil in some degenerate cases.  See the long comment in
         bezierPathForNormalizedDrawing(). */
        if (image == nil) {
            image = UIImage()
        }
        
        return image!
    }
    
    static func groove(on path: UIBezierPath, midX: CGFloat) {
        let GROOVE_TOP = CGFloat(50.0) - path.lineWidth/2
        let GROOVE_BOTTOM = CGFloat(-50.0) + path.lineWidth/2
        let GROOVE_WIDTH = CGFloat(8.0)
        var rect: CGRect
        var aPath: UIBezierPath?
        let x = midX - CGFloat(GROOVE_WIDTH / 2)
        rect = CGRect(x: x,
                      y: GROOVE_BOTTOM,
                      width: GROOVE_WIDTH,
                      height: GROOVE_TOP - GROOVE_BOTTOM)
        aPath = UIBezierPath(roundedRect: rect,
                             cornerRadius: CGFloat(GROOVE_WIDTH / 2.0))
        path.append(aPath!)
    }
    
    static func handle(on path: UIBezierPath, midX: CGFloat, midY: CGFloat) {
        let HANDLE_HEIGHT = CGFloat(10.0)
        let HANDLE_WIDTH = CGFloat(20.0)
        let rect = CGRect(x: midX - (HANDLE_WIDTH / 2),
                          y: midY - HANDLE_HEIGHT / 1,
                          width: HANDLE_WIDTH,
                          height: HANDLE_HEIGHT)
        let rectPath = UIBezierPath(rect: rect)
        path.append(rectPath)
    }
    
    /**
     Returns an icon containing a line drawing of some sliders, to symbolize
     "Settings"
     - important:
     - parameter length: The width and height of the returned image
     - parameter color:  The color of the lines in the line drawing
     - Returns:
     - Throws:
     - Requires:
     */
    public static func settings(length: CGFloat,
                                color: UIColor) -> UIImage {
        let path = self.bezierPathForNormalizedDrawing(
            length: length,
            radians: 0.0)
        
        path.lineWidth = 2.0
        color.setStroke()
        let countOfSliders = 3
        let sliderPitch = (CGFloat(100.0) / CGFloat(countOfSliders))
        var handlePositions = [CGFloat](repeating: 0.0, count: countOfSliders)
        handlePositions[0] = -20
        handlePositions[1] = +25
        handlePositions[2] = -5
        var xs: CGFloat = CGFloat(sliderPitch) / 2.0 - 50.0
        for i in 0..<countOfSliders {
            self.groove(on: path, midX: xs)
            path.stroke()
            path.removeAllPoints()
            self.handle(on: path, midX: xs, midY: handlePositions[i])
            xs += sliderPitch
        }
        path.stroke()
        
        return self.finishNormalizedDrawing() ;
    }
    
    /**
     Returns an icon containing a line drawing of rectangles arranged to
     symbolize the lines of a "Report"
     - parameter length: The width and height of the returned image
     - parameter color:  The color of the lines in the line drawing
     */
    public static func reports(length: CGFloat,
                               color: UIColor) -> UIImage {
        let path =
            self.bezierPathForNormalizedDrawing(
                length: length,
                radians: 0.0)
        
        path.lineWidth = 2.0
        let TITLE_HEIGHT : CGFloat = 15.0
        let TITLE_WIDTH : CGFloat = 80.0
        let TITLE_EXTRA_VERTICAL_MARGIN : CGFloat = 10.0
        let REPORT_ITEM_HEIGHT : CGFloat = 6.0
        let COUNT_OF_REPORT_ITEMS = 5
        let LINE_PITCH : CGFloat
            = ((100.0 - TITLE_HEIGHT - TITLE_EXTRA_VERTICAL_MARGIN) / CGFloat(COUNT_OF_REPORT_ITEMS))
        var rect: CGRect
        var rectPath: UIBezierPath
        // Make the title rectangle, at the top
        rect = CGRect(x: (100.0 - TITLE_WIDTH) / 2 - 50.0,
                      y: 50.0 - TITLE_HEIGHT - path.lineWidth/2,
                      width: TITLE_WIDTH,
                      height: TITLE_HEIGHT)
        rectPath = UIBezierPath(rect: rect)
        path.append(rectPath)
        for i in 0..<COUNT_OF_REPORT_ITEMS {
            let x = CGFloat(-50.0 + path.lineWidth/2)
            let y = (CGFloat(i) * LINE_PITCH) - 50.0 + (path.lineWidth/2)
            let width = CGFloat(100.0 - path.lineWidth)
            let height = REPORT_ITEM_HEIGHT
            rect = CGRect(x: x,
                          y: y,
                          width: width,
                          height: height)
            rectPath = UIBezierPath(rect: rect)
            path.append(rectPath)
        }
        
        color.setStroke()
        path.stroke()
        
        return self.finishNormalizedDrawing() ;
    }
    
    /**
     Returns an icon containing a line drawing of a pencil oriented at 45 
     degrees to vertical, to symbolize editing
     - parameter length: The width and height of the returned image
     - parameter color:  The color of the lines in the line drawing
     */
    public static func editingPencil(length: CGFloat,
                                     color: UIColor) -> UIImage {
        let path =
            self.bezierPathForNormalizedDrawing(
                length: length,
                radians: -CGFloat.pi/4.0)
        /* Several of the calculations below rely on the tilt being 45 degrees
         (pi/4).  It simplifies the math because cosine = sine. */
        color.setStroke()
        color.setFill()
        
        let lineWidth : CGFloat = 3.0
        let radius : CGFloat = 9.0
        let tipConeHeight : CGFloat = 25.0
        let leadHeight : CGFloat = 10.0
        let eraserHeight : CGFloat = 12.0
        let metalBandHeight : CGFloat = 8.0
        /* offsetY is the percent by which the pencil should be pushed down
         because the top is wider than the bottom (2*radius vs. 0) and thus
         when after it is tilted by 45 degrees (pi/4) the top corner will be
         higher than the bottom corner, and instead we want both the top and
         bottom of the 100x100 rectangle to be touched. */
        let offsetY : CGFloat = radius / 2.0
        let length : CGFloat = 100.0 * sqrt (2.0) - radius - 2 * lineWidth
        let leadTopRadius = radius * leadHeight / tipConeHeight

        let tip = CGPoint(x: 0, y: -length/2 - offsetY)
        
        let leadTopL = CGPoint(x: -leadTopRadius, y: -length/2 - offsetY + leadHeight)
        let leadTopR = CGPoint(x: +leadTopRadius, y: -length/2 - offsetY + leadHeight)
        
        let coneBaseL = CGPoint(x: -radius, y: -length/2 - offsetY + tipConeHeight)
        let coneBaseR = CGPoint(x: +radius, y: -length/2 - offsetY + tipConeHeight)
        
        let metalBandTopY = length/2 - offsetY - eraserHeight
        let metalBandBotY = metalBandTopY - metalBandHeight
        
        let hexEdgeInset = radius * 0.59
        
        let metalBandBotLeft = CGPoint(x: -radius, y:metalBandBotY) ;
        let metalBandBotRigt = CGPoint(x: +radius, y:metalBandBotY) ;
        
        let hexEdgeLeftBot = CGPoint(x: coneBaseL.x + hexEdgeInset, y: coneBaseL.y)
        let hexEdgeLeftTop = CGPoint(x: coneBaseL.x + hexEdgeInset, y: metalBandBotY)
        let hexEdgeRigtBot = CGPoint(x: coneBaseR.x - hexEdgeInset, y: coneBaseR.y)
        let hexEdgeRigtTop = CGPoint(x: coneBaseR.x - hexEdgeInset, y: metalBandBotY)
        
        // Lead tip
        let leadPath = UIBezierPath()
        leadPath.move(to: tip)
        leadPath.addLine(to: leadTopL)
        leadPath.addLine(to: leadTopR)
        leadPath.close()
        leadPath.fill()
        path.append(leadPath)
        
        // Cone including Lead tip
        path.move(to: tip)
        path.addLine(to: coneBaseL)
        path.addLine(to: coneBaseR)
        path.addLine(to: tip)

        // Two outer lines
        path.move(to: coneBaseL)
        path.addLine(to: metalBandBotLeft)
        path.move(to: coneBaseR)
        path.addLine(to: metalBandBotRigt)
        
        // Two inner lines at hexagon edges
        path.move(to: hexEdgeLeftBot)
        path.addLine(to: hexEdgeLeftTop)
        path.move(to: hexEdgeRigtBot)
        path.addLine(to: hexEdgeRigtTop)
        
        // Metal band below the eraser
        let bandRect = CGRect(x: -radius,
                              y: metalBandBotY,
                              width: 2.0 * radius,
                              height: metalBandHeight)
        let metalBandPath = UIBezierPath(rect: bandRect)
        path.append(metalBandPath)
        
        // Eraser
        let eraserRect = CGRect(x: -radius,
                                y: metalBandTopY,
                                width: 2.0 * radius,
                                height: eraserHeight)
        let eraserPath = UIBezierPath(rect: eraserRect)
        path.append(eraserPath)
        
        
        path.lineWidth = lineWidth
        path.stroke()
        
        return self.finishNormalizedDrawing() ;
    }
    
    /**
     Returns an icon containing a line drawing of a pencil oriented at 45
     degrees to vertical, to symbolize editing
     - parameter length: The width and height of the returned image
     - parameter color:  The color of the lines in the line drawing
     */
    public static func dumbbell(length: CGFloat,
                                     color: UIColor) -> UIImage {
        let path =
            self.bezierPathForNormalizedDrawing(
                length: length,
                radians: 0.0)
        /* Several of the calculations below rely on the tilt being 45 degrees
         (pi/4).  It simplifies the math because cosine = sine. */
        color.setStroke()
        color.setFill()
        
        var aRect : CGRect
        var aPath : UIBezierPath
        
        let lineWidth : CGFloat = 3.0
        let barRadius : CGFloat = 5.0
        let bigWeightRadius : CGFloat = 30.0
        let bigWeightThickness : CGFloat = 10.0
        let smallWeightRadius : CGFloat = 15.0
        let smallWeightThickness : CGFloat = 10.0
        let middleHalfGap : CGFloat = 25.0
        
        // Left big weight
        aRect = CGRect(x: -middleHalfGap - bigWeightThickness / 2,
                       y: -bigWeightRadius,
                       width: bigWeightThickness,
                       height: 2 * bigWeightRadius)
        aPath = UIBezierPath(rect: aRect)
        path.append(aPath)
        
        // Right big weight
        aRect = CGRect(x: +middleHalfGap - bigWeightThickness / 2,
                       y: -bigWeightRadius,
                       width: bigWeightThickness,
                       height: 2 * bigWeightRadius)
        aPath = UIBezierPath(rect: aRect)
        path.append(aPath)
        
        // Left little weight
        aRect = CGRect(x: -middleHalfGap - bigWeightThickness - smallWeightThickness / 2,
                       y: -smallWeightRadius,
                       width: smallWeightThickness,
                       height: 2 * smallWeightRadius)
        aPath = UIBezierPath(rect: aRect)
        path.append(aPath)
        
        // Right little weight
        aRect = CGRect(x: +middleHalfGap + bigWeightThickness - smallWeightThickness / 2,
                       y: -smallWeightRadius,
                       width: smallWeightThickness,
                       height: 2 * smallWeightRadius)
        aPath = UIBezierPath(rect: aRect)
        path.append(aPath)
        
        /* We are done with the four "weights".  We want those to be filled. */
        path.fill()
        /* The parts of the "bar", which follow, will not be filled. */
        
        // Middle of bar
        aRect = CGRect(x: -middleHalfGap + bigWeightThickness / 2,
                       y: -barRadius / 2,
                       width: 2 * middleHalfGap - bigWeightThickness,
                       height: 2 * barRadius)
        aPath = UIBezierPath(rect: aRect)
        path.append(aPath)
        
        let halfExcludingEnds = middleHalfGap + bigWeightThickness / 2 + smallWeightThickness
        let endLengths = 50.0 - halfExcludingEnds - lineWidth / 2
            
        // Left end of bar
        aRect = CGRect(x: -50.0 + lineWidth / 2,
                       y: -barRadius / 2,
                       width: endLengths,
                       height: 2 * barRadius)
        aPath = UIBezierPath(rect: aRect)
        path.append(aPath)
        
        // Right end of bar
        aRect = CGRect(x: halfExcludingEnds,
                       y: -barRadius / 2,
                       width: endLengths,
                       height: 2 * barRadius)
        aPath = UIBezierPath(rect: aRect)
        path.append(aPath)
        
        path.lineWidth = lineWidth
        path.stroke()
        
        return self.finishNormalizedDrawing() ;
    }
    
    /**
     Returns an icon containing a either a *plus* or *minus* symbol
     - parameter plus:  Pass `true` if you want plus, `false` for minus
     - parameter length: The width and height of the returned image
     - parameter inset:  Number of points by which the content of the returned
     image should be inset from its frame
     - parameter radians:  Amount by which the return image should be rotated
     counterclockwise
     - parameter color:  The color of the lines in the line drawing
     */
    public static func plusMinus(plus: Bool,
                                 length: CGFloat,
                                 inset: CGFloat,
                                 radians: CGFloat,
                                 color: UIColor) -> UIImage {
        let path = self.bezierPathForNormalizedDrawing(
            length: length,
            radians: radians)
        
        let insetPercent: CGFloat = length > 0 ? inset * 100 / length : 0.0
        path.lineWidth = 10
        // We also use textDrawingLineWidth as a margin
        
        let radius = 50.0 - insetPercent
        // Draw the horizontal line
        path.move(to: CGPoint(x: -radius, y:0.0))
        path.addLine(to: CGPoint(x: radius, y: 0.0))
        color.setStroke()
        path.stroke()
        if (plus) {
            // Draw the vertical line
            path.move(to: CGPoint(x: 0.0, y: -radius))
            path.addLine(to: CGPoint(x: 0.0, y: radius))
            path.stroke()
        }
        
        return self.finishNormalizedDrawing() ;
    }
    
    /**
     Returns a square line drawing consisting of a circle containing one radial
     line pointing upward (unless you pass `radians` != 0.0), representing an
     old-fashioned analog "radio" knob on a potentiometer
     - parameter length: The width and height of the returned image
     - parameter inset:  Number of points by which the content of the returned
     image should be inset from its frame
     - parameter radians:  Amount by which the return image should be rotated
     counterclockwise
     - parameter color:  The color of the lines in the line drawing
     */
    public static func knob(length: CGFloat,
                            inset: CGFloat,
                            radians: CGFloat,
                            color: UIColor) -> UIImage {
        let path = self.bezierPathForNormalizedDrawing(
            length: length,
            radians: radians)
        
        let insetPercent: CGFloat = length > 0 ? inset * 100 / length : 0.0
        
        path.lineWidth = 10.0
        let knobRadius = CGFloat(50.0 - path.lineWidth/2) - insetPercent
        path.addArc(withCenter: CGPoint(x:0.0, y:0.0),
                    radius: knobRadius,
                    startAngle: 0.0,
                    endAngle: 360.0,
                    clockwise: true)
        color.setStroke()
        path.stroke()
        
        let pointerRect = CGRect(x: -path.lineWidth/2,
                                 y: -path.lineWidth/2,
                                 width: path.lineWidth,
                                 height: knobRadius + path.lineWidth/2)
        let pointerPath = UIBezierPath(roundedRect: pointerRect,
                                       cornerRadius: path.lineWidth/2)
        color.setFill()
        pointerPath.fill()
        
        return self.finishNormalizedDrawing() ;
    }
    
    /**
     Returns a filled hexagon in a square image
     - parameter length: The width and height of the returned image
     - parameter flatTop: If you pass `true`, the returned image has one of its
     six lines along the top.  If you pass `false`, it has a vertex at the top.
     - parameter inset:  Number of points by which the content of the returned
     image should be inset from its frame
     - parameter radians:  Amount by which the return image should be rotated
     counterclockwise
     - parameter color:  The color of the lines in the line drawing
     */
    public static func hexagon(length: CGFloat,
                               flatTop: Bool,
                               inset: CGFloat,
                               color: UIColor) -> UIImage {
        let radians = flatTop ? CGFloat.pi/2.0 : 0.0
        let path =
            self.bezierPathForNormalizedDrawing(
                length: length,
                radians: radians)
        let insetPercent: CGFloat = length > 0 ? inset * 100 / length : 0.0
        
        let wholeFrame = CGRect(x: -50.0, y: -50.0, width: 100.0, height: 100.0)
        let frame = wholeFrame.insetBy(dx: insetPercent, dy: insetPercent)
        let insize: CGFloat = 100.0 - 2 * insetPercent
        let A = CGPoint(x:frame.origin.x + insize / 2, y:frame.origin.y + frame.size.height)
        let B = CGPoint(x:frame.origin.x + insize, y:frame.origin.y + frame.size.height - insize / 4)
        let C = CGPoint(x:frame.origin.x + insize, y:frame.origin.y + insize / 4)
        let D = CGPoint(x:frame.origin.x + insize / 2, y:frame.origin.y)
        let E = CGPoint(x:frame.origin.x, y:frame.origin.y + insize / 4)
        let F = CGPoint(x:frame.origin.x, y:frame.origin.y + frame.size.height - insize / 4)
        path.move(to: A)
        path.addLine(to: B)
        path.addLine(to: C)
        path.addLine(to: D)
        path.addLine(to: E)
        path.addLine(to: F)
        path.close()
        color.setFill()
        color.setStroke()
        path.fill()
        
        return self.finishNormalizedDrawing() ;
    }
    
    /**
     Returns a line drawing outlining the glyph of a given character
     - parameter character: The character to appear in the returned image
     - parameter height: The height of the returned image
     - parameter wideness: Factor by which the aspect ratio of the glyph in the
     returned image should be different than the glyph in the font library.
     Pass a number < 1.0 to make it narrower, > 1.0 to make it wider.
     - parameter color:  The desired color of the lines and optional fill
     - Returns:  May return nil if the given fontName does not support the
     given character
     */
    static func imageOfCharacter(
        _ character: UniChar,
        height: CGFloat,
        wideness: CGFloat,
        lineWidth: CGFloat,
        color: OSColor,
        fill: Bool,
        fontName: String?)
        -> OSImage? {
            let arbitraryFontSize = CGFloat(100.0)
            var path : UIBezierPath
            
            let actualFontName = (fontName != nil) ? fontName : OSFont.systemFont(ofSize: arbitraryFontSize).fontName
            var unichars: [UniChar] = [character]
            var glyphs = [CGGlyph](repeating:0, count:1)
            let font = UIFont(name:actualFontName!,
                              size:arbitraryFontSize)!
            /* We passed an arbitrary font size, because we don't know the bounds yet.
             We shall get the bounds and scale it later. */
            let gotGlyphs = CTFontGetGlyphsForCharacters(font,
                                                         &unichars,
                                                         &glyphs,
                                                         unichars.count)
            var image: UIImage?
            if (gotGlyphs) {
                let aGlyph = glyphs[0]
                let cgPath = CTFontCreatePathForGlyph(font, aGlyph, nil)!
                let bounds = cgPath.boundingBox
                let glyphLineWidth = lineWidth * (bounds.height/height)
                
                let glyphWidth = bounds.width + glyphLineWidth
                let glyphHeight = bounds.height + glyphLineWidth
                
                let yScale = height/glyphHeight
                let width = (wideness > 0.0) ? wideness : yScale * bounds.width * -wideness
                
                let xScale = width/glyphWidth
                
                UIGraphicsBeginImageContextWithOptions(CGSize(width: glyphWidth * xScale, height: glyphHeight * yScale), false, 0)
                let context = UIGraphicsGetCurrentContext()!
                context.saveGState()
                
                path = UIBezierPath(cgPath:cgPath)
                path.lineWidth = glyphLineWidth
                color.setFill()
                color.setStroke()
                
                context.scaleBy(x: xScale, y: -yScale)
                context.translateBy(x: -bounds.minX + glyphLineWidth/2, y: -bounds.height - bounds.minY - glyphLineWidth/2)
                
                path.stroke()
                if (fill) {
                    path.fill()
                }
                
                context.restoreGState()
                image = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            }
            
            return image
    }
    
    /**
     Returns an icon of the Roman letter "i", typically used to represent "Info"
     - parameter height:  The height of the returned icon
     - parameter fill:  If `true`, the returned icon is filled with the given
     color; if `false` you get an outline drawing
     - parameter color:  Color of the lines and optional fill in the returned
     icon
     */
    public static func infoIcon(height: CGFloat,
                                fill: Bool,
                                color: UIColor) -> UIImage {
        let targetChar = UInt16(UnicodeScalar("i").value)
        return self.imageOfCharacter(
            targetChar,
            height: height,
            wideness: -2.0,
            lineWidth: height/20.0,
            color: color,
            fill: fill,
            fontName:"Avenir Next")!
    }
    
    /**
     Returns an icon of the character "?", typically used to represent "Help"
     - parameter height:  The height of the returned icon
     - parameter fill:  If `true`, the returned icon is filled with the given
     color; if `false` you get an outline drawing
     - parameter color:  Color of the lines and optional fill in the returned
     icon
     */
    public static func helpIcon(height: CGFloat,
                                fill: Bool,
                                color: UIColor) -> UIImage {
        let targetChar = UInt16(UnicodeScalar("?").value)
        return self.imageOfCharacter(
            targetChar,
            height: height,
            wideness: -2.0,
            lineWidth: height/20.0,
            color: color,
            fill: fill,
            fontName:"Avenir Next")!
    }
    
    /**
     Returns an icon of the exclamation point "!", also referred to as "Bang"
     - parameter height:  The height of the returned icon
     - parameter fill:  If `true`, the returned icon is filled with the given
     color; if `false` you get an outline drawing
     - parameter color:  Color of the lines and optional fill in the returned
     icon
     */
    public static func bangIcon(height: CGFloat,
                                fill: Bool,
                                color: UIColor) -> UIImage {
        let targetChar = UInt16(UnicodeScalar("!").value)
        return self.imageOfCharacter(
            targetChar,
            height: height,
            wideness: -1.3,
            lineWidth: height/20.0,
            color: color,
            fill: fill,
            fontName:"TimesNewRomanPSMT")!
    }
    
}

/* More functions for drawing glyphs that I ended up not using, could not get to work
 
 static func bounds(for character: UniChar,
 font: CTFont) -> CGRect {
 var chars = [UniChar](repeating: UniChar(), count: 1)
 chars[0] = character
 let attrs = [
 NSFontAttributeName : (font as UIFont)
 ]
 
 /* Note on the following mess.  I tried a more direct method, using
 CTFontGetGlyphsForCharacters(), then CTFontGetOpticalBoundsForGlyphs().
 But this gave quite a bit bigger rect.  Apparently, "optical bounds" is
 not the "bounds" I want. */
 let string = CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1)
 let attributedString = CFAttributedStringCreate(kCFAllocatorDefault, string, (attrs as CFDictionary))
 
 let line = CTLineCreateWithAttributedString(attributedString!)
 let runsArray = CTLineGetGlyphRuns(line)
 let run = CFArrayGetValueAtIndex(runsArray, 0)
 return CTRunGetImageBounds(run as! CTRun, nil, CFRangeMake(0, 1))
 }
 
 static func appendGlyph(path: OSBezierPath,
 character: UniChar,
 halfWidth: CGFloat) {
 var font : UIFont
 #if os(iOS)
 font = UIFont.systemFont(ofSize: 100)
 #else // macOS
 font = NSFont.labelFont(ofSize: 100)
 #endif
 var characters = [UniChar](repeating: UniChar(), count: 1)
 characters[0] = character
 let glyph = CGGlyph()
 let glyphs = UnsafeMutablePointer<CGGlyph>.allocate(capacity: MemoryLayout<CGGlyph>.size * 1)
 CTFontGetGlyphsForCharacters(font, characters, glyphs, 1)
 CTFontGetGlyphsForCharacters((font as CTFont), characters, glyphs, 1)
 let glyphRect = self.bounds(for:character, font:font)
 var flip = CGAffineTransform(a:1, b:0, c:0, d:-1, tx:0, ty:100.0);
 let glyphCgPath = CTFontCreatePathForGlyph(font,
 glyph,
 &flip)
 let glyphBezierPath = UIBezierPath(cgPath:glyphCgPath!)
 let offsetX: CGFloat = glyphRect.midX - halfWidth
 let offsetY: CGFloat = glyphRect.midY - 50
 path.move(to: CGPoint(x:-offsetX, y:-offsetY))
 path.append(glyphBezierPath)
 glyphs.deallocate(capacity: 1) ;
 }
 
 static func drawCharacter(path: OSBezierPath,
 character: UniChar,
 size: OSSize,
 color: OSColor,
 fill: Bool) {
 let bezier = OSBezierPath()
 self.appendGlyph(path: bezier,
 character: character,
 halfWidth: size.width / 2)
 bezier.lineWidth = 2
 //Set<AnyHashable>()
 bezier.stroke()
 if fill {
 color.setFill()
 bezier.fill()
 }
 }
 
 */
