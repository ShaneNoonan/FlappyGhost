//
//  RandomFunction.swift
//  FlappyGhost
//
//  Created by Sheene Noonan on 15/03/2016.
//  Copyright © 2016 ShaneNoonan. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat{
    
    public static func Random() -> CGFloat {
        
        return CGFloat(Float(arc4random()) / 0xffffffff)
    }
    
    public static func Random(min : CGFloat, max : CGFloat) -> CGFloat {
        
        return CGFloat.Random() * (max - min) + min
    }
}
