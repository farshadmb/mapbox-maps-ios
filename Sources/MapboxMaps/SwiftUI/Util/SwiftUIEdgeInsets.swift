import SwiftUI
import UIKit

@available(iOS 13.0, *)
extension SwiftUI.EdgeInsets {
    init(uiInsets: UIEdgeInsets, layoutDirection: LayoutDirection) {
        let top = uiInsets.top
        let bottom = uiInsets.bottom
        let leading: CGFloat
        let trailing: CGFloat
        switch layoutDirection {
        case .rightToLeft:
            leading = uiInsets.right
            trailing = uiInsets.left
        default:
            leading = uiInsets.left
            trailing = uiInsets.right
        }
        self.init(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
}

@available(iOS 13.0, *)
extension UIEdgeInsets {
    init(insets: SwiftUI.EdgeInsets, layoutDirection: LayoutDirection) {
        let top = insets.top
        let bottom = insets.bottom
        let left: CGFloat
        let right: CGFloat
        switch layoutDirection {
        case .rightToLeft:
            left = insets.trailing
            right = insets.leading
        default:
            left = insets.leading
            right = insets.trailing
        }
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
}

@available(iOS 13.0, *)
let edgeToInsetMapping: [(Edge.Set, WritableKeyPath<SwiftUI.EdgeInsets, CGFloat>)] = [
    (.top, \.top),
    (.bottom, \.bottom),
    (.leading, \.leading),
    (.trailing, \.trailing),
]
