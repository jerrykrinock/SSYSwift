import UIKit
import PlaygroundSupport

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

func caShapeLayersDemo(view: UIView) {
    let lineWidth = CGFloat(4.0)
    let glyphHeight = view.frame.height - lineWidth
    var chars : [UniChar] = []
    for character in "∫Egads!".unicodeScalars {
        chars.append(UniChar(character.value))
    }
    var glyphs = [CGGlyph](repeating:0, count:chars.count)
    let font = UIFont(name:"HelveticaNeue",
                      size:glyphHeight)!
    
    let gotGlyphs = CTFontGetGlyphsForCharacters(font,
                                                 &chars,
                                                 &glyphs,
                                                 chars.count)
    if gotGlyphs {
        var i = 0
        var previousCharacterMaxX: CGFloat = 0.0
        for aGlyph in glyphs {
            var flipAndAdvance = CGAffineTransform(
                a:1.0,
                b:0.0,
                c:0.0,
                d:-1.0,                      // flip
                tx:previousCharacterMaxX,    // advance
                ty:glyphHeight);  // flip
            let cgPath = CTFontCreatePathForGlyph(font,
                                                  aGlyph,
                                                  &flipAndAdvance)!
            let path = UIBezierPath(cgPath:cgPath)
            previousCharacterMaxX += cgPath.boundingBox.width
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.lineWidth = lineWidth
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = UIColor.green.cgColor
            shapeLayer.strokeColor = UIColor.black.cgColor
            view.layer.addSublayer(shapeLayer)
            i += 1
        }
    }
}


func animatedView(frame: CGRect) -> UIImageView {
    let image = SSYVectorImages.knob(length: frame.size.width,
                                     inset: 0.0,
                                     radians: CGFloat.pi/4,
                                     color: UIColor.red)
    
    let imageView = UIImageView(image: image)
    
    // Animate a continuous spin, using CABasicAnimation
    let spin = CABasicAnimation(keyPath: "transform.rotation")
    spin.fromValue = CGFloat(0)
    spin.toValue = 2*CGFloat.pi
    spin.duration = CFTimeInterval(7.0)
    spin.repeatCount = Float.infinity
    imageView.layer.add(spin, forKey: "Spin Me!")
    
    // Animate background color change, using UIView.animate()
    imageView.backgroundColor = UIColor.purple
    UIView.animate(withDuration: 5.0, animations: {
        imageView.backgroundColor = UIColor.clear
    })
    
    return imageView
}

let viewSize = CGSize(width: 400.0, height: 800.0)
let playgroundView = UIView(frame: CGRect(origin: CGPoint(x:0,y:0), size: viewSize))
PlaygroundPage.current.liveView = playgroundView
playgroundView.backgroundColor = UIColor.white

var aHeight : CGFloat
var x = CGFloat(0)
var y = CGFloat(0)

let topView = UIView(frame: CGRect(x:x,
                                   y:y,
                                   width:playgroundView.frame.width,
                                   height:playgroundView.frame.width/3))
caShapeLayersDemo(view:topView)
playgroundView.addSubview(topView)

y += topView.frame.height

aHeight = playgroundView.frame.width/3
let aAnimatedView = animatedView(frame: CGRect(x: x,
                                               y: y,
                                               width: aHeight,
                                               height: aHeight))
aAnimatedView.frame.origin.y = y
playgroundView.addSubview(aAnimatedView)

x += aAnimatedView.frame.width

var image : UIImage
var imageView : UIImageView

image = SSYVectorImages.hexagon(length: aHeight,
                                flatTop: false,
                                inset: 0.0,//aHeight/8,
                                color: UIColor.green)
imageView = UIImageView(image: image)
imageView.frame.origin = CGPoint(x: x, y: y)
playgroundView.addSubview(imageView)

x += imageView.frame.width

image = SSYVectorImages.hexagon(length: aHeight,
                                flatTop: true,
                                inset: 0.0,
                                color: UIColor.orange)
imageView = UIImageView(image: image)
imageView.frame.origin = CGPoint(x: x, y: y)
playgroundView.addSubview(imageView)

x = 0.0
y += imageView.frame.height

aHeight = 65.0
image = SSYVectorImages.infoIcon(height: aHeight,
                                 fill: false,
                                 color: UIColor.blue)
imageView = UIImageView(image: image)
imageView.frame.origin = CGPoint(x: x, y: y)
playgroundView.addSubview(imageView)

x += imageView.frame.width

image = SSYVectorImages.infoIcon(height: aHeight,
                                 fill: true,
                                 color: UIColor.blue)
imageView = UIImageView(image: image)
imageView.frame.origin = CGPoint(x: x, y: y)
playgroundView.addSubview(imageView)

x += imageView.frame.width

image = SSYVectorImages.helpIcon(height: aHeight,
                                 fill: false,
                                 color: UIColor.blue)
imageView = UIImageView(image: image)
imageView.frame.origin = CGPoint(x: x, y: y)
playgroundView.addSubview(imageView)

x += imageView.frame.width

image = SSYVectorImages.bangIcon(height: aHeight,
                                 fill: true,
                                 color: UIColor.blue)
imageView = UIImageView(image: image)
imageView.frame.origin = CGPoint(x: x, y: y)
playgroundView.addSubview(imageView)

x = 0.0
y += imageView.frame.height

image = SSYVectorImages.editingPencil(length: playgroundView.frame.width/3,
                                 color: UIColor.red)
imageView = UIImageView(image: image)
imageView.frame.origin = CGPoint(x: x, y: y)
playgroundView.addSubview(imageView)

x += imageView.frame.width

image = SSYVectorImages.settings(length: playgroundView.frame.width/3,
                                color: UIColor.orange)
imageView = UIImageView(image: image)
imageView.frame.origin = CGPoint(x: x, y: y)
playgroundView.addSubview(imageView)

x += imageView.frame.width

image = SSYVectorImages.reports(length: playgroundView.frame.width/3,
                                color: UIColor.darkGray)
imageView = UIImageView(image: image)
imageView.frame.origin = CGPoint(x: x, y: y)
playgroundView.addSubview(imageView)

x = 0.0
y += imageView.frame.height

image = SSYVectorImages.plusMinus(plus: true,
                                  length: viewSize.width/2,
                                  inset: viewSize.width/20,
                                  radians: CGFloat.pi/12,
                                  color: UIColor.black)
imageView = UIImageView(image: image)
imageView.frame.origin = CGPoint(x: x, y: y)
playgroundView.addSubview(imageView)

x += imageView.frame.width

image = SSYVectorImages.plusMinus(plus: false,
                                  length: viewSize.width/2,
                                  inset: viewSize.width/20,
                                  radians: -CGFloat.pi/12,
                                  color: UIColor.black)
imageView = UIImageView(image: image)
imageView.frame.origin = CGPoint(x: x, y: y)
playgroundView.addSubview(imageView)
