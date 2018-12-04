//
//  Platform.swift
//  lianshen
//
//  Created by zatams on 2018/12/1.
//  Copyright © 2018 zatams. All rights reserved.
//

import Foundation
import CryptoSwift
enum Algorithm:Int{
    case md5=0
    case sha1
    case sha224
    case sha256
    case sha384
    case sha512
}
extension Algorithm{
    func string()->String{
        var hashType=""
        switch self {
        case .md5:
            hashType="MD5"
        case .sha1:
            hashType="SHA1"
        case .sha224:
            hashType="SHA-224"
        case .sha256:
            hashType="SHA-256"
        case .sha384:
            hashType="SHA-384"
        case .sha512:
            hashType="SHA-512"
        
        }
        return hashType
    }
}
enum Version:Int{
    case v2=0
    case v3
}
extension Version{
    func string()->String{
        var str=""
        switch self {
        case .v2:
            str="v2"
        case .v3:
            str="v3"
        }
        return str
    }
}
struct DigestEvent {
    var eventType:DigestEventType
    var message:String=""
    var percent:Double=0.0
    init(message:String,error:Bool=false){
        if error{
            self.eventType = .error
        }else{
            self.eventType = .success
        }
        self.message=message
        percent = 0.0
    }
    init(){
        self.init(.open, message: "", percent: 0)
    }
    init(_ eventType:DigestEventType,message:String="",percent:Double=0.0){
        self.eventType=eventType
        self.message=message
        self.percent=percent
    }
    
    init(percent:Double){
        self.init(.processing,message:"",percent:percent)
    }
}
enum DigestEventType{
    case open
    case processing
    case success
    case error
}
protocol DigestDelegate:NSObjectProtocol{
    func handle(_ event:DigestEvent)
}
class Digest:NSObject{
    weak var delegate:DigestDelegate?
    private var buffer:[UInt8]=[]
    private var digest:Updatable?=nil
    private var max:Double=0.0
    private var now:Double=0.0
    let BUFFER_SIZE=1048576 //1mb
    private let global=DispatchQueue(label: "co.stockchain.lianshen")
    private var _running=false
    var running:Bool{
        return _running
    }
    static let shared=Digest()
    func digest(_ path:String,algorithm:Algorithm,version:Version){
        if running{
            return
        }
        _running=true
        let toolkit=Toolkit.shared
        if !toolkit.isFile(path){
            _running=false
            self.delegate?.handle(DigestEvent(message: "IO ERROR: -1",error:true))
            return
        }
        self.now=0.0
        self.max=Toolkit.shared.length(path)
        self.buffer=Array<UInt8>(repeating:0, count:BUFFER_SIZE)
        switch algorithm {
        case .md5:
            self.digest=MD5()
        case .sha1:
            self.digest=SHA1()
        case .sha224:
            if version == .v2{
                self.digest=SHA2(variant: .sha224)
            }else{
                self.digest=SHA3(variant: .sha224)
            }
        case .sha256:
            if version == .v2{
                self.digest=SHA2(variant: .sha256)
            }else{
                self.digest=SHA3(variant: .sha256)
            }
        case .sha384:
            if version == .v2{
                self.digest=SHA2(variant: .sha384)
            }else{
                self.digest=SHA3(variant: .sha384)
            }
        case .sha512:
            if version == .v2{
                self.digest=SHA2(variant: .sha512)
            }else{
                self.digest=SHA3(variant: .sha512)
            }
      
        }
        guard let stream=InputStream(fileAtPath: path) else{
            _running=false
            self.delegate?.handle(DigestEvent(message: "IO ERROR: -2",error:true))
            return
        }
        stream.delegate=self
        stream.schedule(in: RunLoop.current, forMode: .default)
        stream.open()
    }
}



extension Digest:StreamDelegate{
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        guard let aStream=aStream as? InputStream else{
            _running=false
            self.delegate?.handle(DigestEvent(message: "IO ERROR: -3",error:true))
            return
        }
        do{
            switch eventCode {
            case .openCompleted:
                delegate?.handle(DigestEvent())
            case .hasBytesAvailable:
                let len=aStream.read(&buffer, maxLength: BUFFER_SIZE)
                if len<=0{
                    return
                }
                let _ = try digest?.update(withBytes: buffer[0..<len])
                now += Double(len)
                var p=0.0
                if max > 0{
                    p=now/max
                }
                delegate?.handle(DigestEvent(percent: p))
            case .errorOccurred:
                cleanup(aStream)
                delegate?.handle(DigestEvent(message: "IO ERROR: -4",error:true))
            case .endEncountered:
                cleanup(aStream)
                if let result=try digest?.finish(){
                    delegate?.handle(DigestEvent(message:result.toHexString()))
                }
            default:
                break
            }
            
            
        }catch{
            
        }
    }
    
    private func cleanup(_ aStream:Stream){
        aStream.delegate=nil
        aStream.remove(from: RunLoop.current, forMode: .default)
        aStream.close()
        _running=false
    }
}
