//
//  KafuView.swift
//  kafu
//
//  Created by zatams on 2018/11/27.
//  Copyright © 2018 zatams. All rights reserved.
//

import Foundation
import Cocoa
protocol  LSViewDraggingDelegate:NSObjectProtocol {
    func handle(_ uris:[URL])
}
protocol  LSViewMouseDelegate:NSObjectProtocol {
    func handleMouseUp(_ event:NSEvent)
}
class LSView:NSVisualEffectView{
    
    weak var mouseDelegate:LSViewMouseDelegate?
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        mouseDelegate?.handleMouseUp(event)
    }
}

class DraggableImageView:NSImageView{
    weak var draggingDelegate:LSViewDraggingDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let items=sender.draggingPasteboard.pasteboardItems else{
            return false
        }
        var uris:[URL]=[]
        for index in 0..<items.count{
            let item=items[index]
            if let data=item.data(forType: .fileURL){
                if let string=String(data:data,encoding:.utf8){
                    if let uri=URL(string:string){
                        uris.append(uri)
                    }
                }
            }
        }
        
        if !uris.isEmpty{
            draggingDelegate?.handle(uris)
        }
        return true
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let draggingTypes=sender.draggingPasteboard.types{
            if draggingTypes.contains(.fileURL){
                return sender.draggingSourceOperationMask
            }
        }
        return NSDragOperation(rawValue: 0)
    }
}
