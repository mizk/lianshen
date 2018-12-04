//
//  Commons.swift
//  kafu
//
//  Created by zatams on 2018/11/25.
//  Copyright © 2018 zatams. All rights reserved.
//

import Cocoa

class Toolkit {
    
    static let shared = Toolkit()

    func matches(_ regexp:String,match:String)->Bool{
        do{
        let reg=try NSRegularExpression(pattern: regexp, options: .allowCommentsAndWhitespace)
            return reg.numberOfMatches(in: match, options: .anchored, range: NSRange(location: 0, length: match.count)) > 0
        }catch{
            
        }
        return false
    }
    
    func isFile(_ path: String) -> Bool {
        let manager = FileManager.default
        return manager.fileExists(atPath: path)
    }

    func isDirectory(_ path: String) -> Bool {
        var dir: ObjCBool = false
        let success = FileManager.default.fileExists(atPath: path, isDirectory: &dir)
        return success && dir.boolValue
    }

    func name(_ path: String) -> String {
        let url = NSString(string: path)
        return url.lastPathComponent
    }
    
    func length(_ path:String)->Double
    {
        
        do{
            let attr=try FileManager.default.attributesOfItem(atPath: path)
            if let size=attr[.size] as? NSNumber{
                return  size.doubleValue
            }
        }catch{
            
        }
        return 0.0
    }

}
