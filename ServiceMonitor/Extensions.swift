//
//  Extensions.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 16.01.2022.
//

import SwiftUI

extension Color {
    
    init(customColorId: Int) {
        var uiColor: UIColor {
            switch customColorId {
            case 1: return UIColor(displayP3Red: 97/255, green: 195/255, blue: 83/255, alpha: 1.0)
            case 2: return UIColor(displayP3Red: 237/255, green: 106/255, blue: 94/255, alpha: 1.0)
            default: return UIColor(displayP3Red: 244/255, green: 191/255, blue: 79/255, alpha: 1.0)
            
            }
        }
        self.init(uiColor)
    }
    
    public static var customGreen: Color {
        return Color(UIColor (displayP3Red: 97/255, green: 195/255, blue: 83/255, alpha: 1.0))
    }
    
    public static var customYellow: Color {
        return Color(UIColor(displayP3Red: 244/255, green: 191/255, blue: 79/255, alpha: 1.0))
    }
    
    public static var customRed: Color {
        return Color(UIColor(displayP3Red: 237/255, green: 106/255, blue: 94/255, alpha: 1.0))
    }
}

extension NSPredicate {
    static var all = NSPredicate(format: "TRUEPREDICATE")
    static var none = NSPredicate(format: "FALSEPREDICATE")
}
