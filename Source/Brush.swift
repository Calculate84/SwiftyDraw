//
//  Brush.swift
//  Sketch
//
//  Created by Linus Geffarth on 02.05.18.
//  Copyright © 2018 Linus Geffarth. All rights reserved.
//

import UIKit

fileprivate enum ColorCodingKeys: String, CodingKey {
    case red
    case green
    case blue
    case alpha
}

extension Encodable where Self: UIColor {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ColorCodingKeys.self)
        
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(alpha, forKey: .alpha)
    }
}

extension Decodable where Self: UIColor {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodingKeys.self)
        
        let red = try container.decode(CGFloat.self, forKey: .red)
        let green = try container.decode(CGFloat.self, forKey: .green)
        let blue = try container.decode(CGFloat.self, forKey: .blue)
        let alpha = try container.decode(CGFloat.self, forKey: .alpha)
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIColor: Codable {}

public enum BlendMode: String, Codable {
    case normal = "normal"
    case clear = "clear"
    
    var cgBlendMode: CGBlendMode {
        switch self {
        case .normal:
            return .normal
        case .clear:
            return .clear
        }
    }
}

public struct Brush: Codable {
    public var color: UIColor
    /// Original brush width set when initializing the brush. Not affected by updating the brush width. Used to determine adjusted width
    private(set) var originalWidth: CGFloat
    public var width: CGFloat
    public var opacity: CGFloat
    
    public var adjustedWidthFactor: CGFloat
    
    /// Allows for actually erasing content, by setting it to `.clear`. Default is `.normal`
    public var blendMode: BlendMode
    
    public var borderColor: UIColor
    public var borderWidthAsPercentage: CGFloat
    
    public var shadowOffset: CGSize
    public var shadowColor: UIColor
    public var shadowRadius: CGFloat
    
    public init(color: UIColor = .black, originalWidth: CGFloat = 3, width: CGFloat = 3, opacity: CGFloat = 1, adjustedWidthFactor: CGFloat = 1, blendMode: BlendMode = .normal, borderColor: UIColor = .clear, borderWidthAsPercentage: CGFloat = 0, shadowOffset: CGSize = .zero, shadowColor: UIColor = .clear, shadowRadius: CGFloat = 0) {
        self.color = color
        self.originalWidth = originalWidth
        self.width = width
        self.opacity = opacity
        self.adjustedWidthFactor = adjustedWidthFactor
        self.blendMode = blendMode
        self.borderColor = borderColor
        self.borderWidthAsPercentage = borderWidthAsPercentage
        self.shadowOffset = shadowOffset
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
    }
    
    private func adjustedWidth(for touch: UITouch) -> CGFloat {
        guard #available(iOS 9.1, *), touch.type == .pencil else { return originalWidth }
        return (originalWidth*(1-adjustedWidthFactor/10*2)) + (adjustedWidthFactor/touch.altitudeAngle)
    }
    
    public mutating func adjustWidth(for touch: UITouch) {
        width = adjustedWidth(for: touch)
    }
}

extension Brush: Equatable, Comparable, CustomStringConvertible {
    public static func ==(lhs: Brush, rhs: Brush) -> Bool {
        lhs.color == rhs.color &&
        lhs.originalWidth == rhs.originalWidth &&
        lhs.opacity == rhs.opacity
    }
    
    public static func <(lhs: Brush, rhs: Brush) -> Bool {
        return (
            lhs.width < rhs.width
        )
    }
    
    public var description: String {
        return "<Brush: color: \(color), width: (original: \(originalWidth), current: \(width)), opacity: \(opacity)>"
    }
}

// MARK: - Static brushes
extension Brush {
    public static var `default`: Brush {
        return Brush(color: .black, width: 3, opacity: 1)
    }
    
    public static var thin: Brush {
        return Brush(color: .black, width: 2, opacity: 1)
    }
    
    public static var medium: Brush {
        return Brush(color: .black, width: 7, opacity: 1)
    }
    
    public static var thick: Brush {
        return Brush(color: .black, width: 12, opacity: 1)
    }
    
    public static var marker: Brush {
        return Brush(color: #colorLiteral(red: 0.920953393, green: 0.447560966, blue: 0.4741248488, alpha: 1), width: 10, opacity: 0.3)
    }
    
    public static var eraser: Brush {
        return Brush(adjustedWidthFactor: 5, blendMode: .clear)
    }
    
    public static var selection: Brush {
        return Brush(color: .clear, width: 1, opacity: 1)
    }
}
