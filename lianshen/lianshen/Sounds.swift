//
//  Sounds.swift
//  lianshen
//
//  Created by zatams on 2018/12/4.
//  Copyright © 2018 zatams. All rights reserved.
//

import Foundation
import AVFoundation
class Sounds{
    private var audio:AVAudioPlayer?=nil
    init(_ media:String,ofType:String){
        if let path=Bundle.main.path(forResource: "success", ofType: ofType){
            if let uri=URL(string:"file://\(path)"){
                do{
                    audio = try AVAudioPlayer(contentsOf: uri, fileTypeHint: "mp3")
                    audio?.prepareToPlay()
                }catch{
                    
                }
            }
        }
    }
    func play(){
        audio?.play()
    }
}
