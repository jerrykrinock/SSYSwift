import Foundation
import AppKit

@objc public final class SSYTransformDataToColor: ValueTransformer {
    /* Use this name used to register the transformer using
     `ValueTransformer.setValueTrandformer(_"forName:)` */
    static let name = NSValueTransformerName(rawValue: String(describing: SSYTransformDataToColor.self))

    /* Registers the value transformer with `ValueTransformer` */
    @objc public class func register() {
        let transformer = SSYTransformDataToColor()
        ValueTransformer.setValueTransformer(transformer, forName: self.name)
    }

    override public class func transformedValueClass() -> AnyClass {
        return NSColor.self
    }

    override public class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override public func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data as Data)
            return color
        } catch {
            assertionFailure("Failed transform Data to NSColor")
            return nil
        }
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let color = value as? NSColor else { return nil }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
            return data
        } catch {
            assertionFailure("Failed transform NSColor to Data")
            return nil
        }
    }
}
