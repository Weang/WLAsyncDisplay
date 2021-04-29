//
//  WLFlag.swift
//  WLAsyncDisplay
//
//  Created by Mr.Wang on 2020/12/2.
//

import UIKit

// 自增标示符
class WLFlag {
    
    var value: Int32 = 0
    
    @discardableResult
    func increment() -> Int32 {
        return OSAtomicIncrement32(&value)
    }
    
}
