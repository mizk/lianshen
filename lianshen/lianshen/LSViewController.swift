//
//  ViewController.swift
//  lianshen
//
//  Created by zatams on 2018/12/1.
//  Copyright © 2018 zatams. All rights reserved.
//

import Cocoa

class LSViewController: NSViewController {
   
    @IBOutlet weak var errorMsg: NSTextField!
    @IBOutlet weak var logoView: DraggableImageView!
    @IBOutlet weak var layoutBottom: NSLayoutConstraint!
    @IBOutlet weak var flagImage: NSImageView!
    @IBOutlet weak var comparisonValue: NSTextField!
    @IBOutlet weak var algorithmValue: NSTextField!
    @IBOutlet weak var algorithmName: NSTextField!
    @IBOutlet weak var fileNameLabel: NSTextField!
    @IBOutlet weak var resultView: NSVisualEffectView!
    @IBOutlet weak var visualView: NSVisualEffectView!
    @IBOutlet weak var version: NSSegmentedControl!
    @IBOutlet weak var algorithm: NSSegmentedControl!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    let successEffect=Sounds("successs",ofType:"wav")
    let errorEffect=Sounds("error",ofType:"mp3")
    let tickImage=NSImage(named: "tick")
    let warningImage=NSImage(named:"warning")
    private var hashString=""
    private var algorithmType:Algorithm = .md5
    private var filePath=""
    private let digestor=Digest.shared
    private var digestVersion:Version = .v2
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logoView.draggingDelegate=self
        let lsView=self.visualView as? LSView
        lsView?.mouseDelegate=self
        self.progressBar.isHidden=true
        self.digestor.delegate=self
        self.digestVersion=Version(rawValue: version.selectedSegment)!
        self.visualView.material = .sheet
        self.resultView.wantsLayer=true
        self.resultView.layer?.cornerRadius=4.0
        self.errorMsg.alphaValue=0.0
        self.errorMsg.stringValue=""
        self.resultView.blendingMode = .behindWindow
        self.layoutBottom.constant = -150.0
        self.resultView.layoutSubtreeIfNeeded()
    }
 
    
    @IBAction func versionChanged(_ sender: NSSegmentedControl) {
        if let v=Version(rawValue: sender.selectedSegment){
            self.digestVersion=v
        }
    }
    
    @IBAction func algorithmChanged(_ sender: NSSegmentedControl) {
        if let alg=Algorithm(rawValue:sender.selectedSegment){
            self.algorithmType=alg
        }
    }
    @IBAction func compareAlgorithm(_ sender: Any) {
        if self.hashString.isEmpty{
            return
        }
        let r2=self.comparisonValue.stringValue.lowercased()
        if r2.isEmpty{
            return
        }
        let array=r2.components(separatedBy: CharacterSet(charactersIn: "="))
        let r=array.last ?? ""
        var msg=""
        let r1=self.hashString.lowercased()
        if r1==r{
            self.flagImage.image=tickImage
            msg="Hash Sum is same"
        }else{
            self.flagImage.image=warningImage
            msg="Hash Sum mismatch"
        }
        alert(msg)
    }
    
    @IBAction func copyAlgorithm(_ sender: Any) {
        if self.hashString.isEmpty{
            return
        }
        let clipboard=NSPasteboard.general
        let _=clipboard.clearContents()
        let alg=self.algorithmType.string()
        let v=self.digestVersion.string()
        let name=Toolkit.shared.name(self.filePath)
        let constr="\(alg).\(v)(\(name))=\(self.hashString)"
        clipboard.setString(constr, forType: .string)
        alert("copied")
    }
    
    private func updateResultView(){
        fileNameLabel.stringValue=Toolkit.shared.name(filePath)
        let str=self.algorithmType.string()
        algorithmName.stringValue="\(str):"
        algorithmValue.stringValue=self.hashString
        flagImage.image=nil
    }
    private func resetResultView(){
        self.hashString=""
        self.fileNameLabel.stringValue=""
        self.algorithmName.stringValue=""
        self.algorithmValue.stringValue=""
        self.flagImage.image=nil
        self.comparisonValue.stringValue=""
    }
    private func showResultView(){
        if animating{
            return
        }
        if layoutBottom.constant != 0{
            animating=true
            layoutBottom.constant = -150.0
            self.view.layoutSubtreeIfNeeded()
            self.updateResultView()
            weak var weakSelf=self
            NSAnimationContext.runAnimationGroup({
                context in
                context.duration=0.5
                context.allowsImplicitAnimation=true
                weakSelf?.visualView.material = .hudWindow
                weakSelf?.layoutBottom.constant=0
                weakSelf?.view.layoutSubtreeIfNeeded()
            },completionHandler:{
                weakSelf?.animating=false
            })
        }
        
    }
    //is animation playing now?
    //block playing multi animations in the same time
    private  var animating=false
    private func hideResultView(){
        if animating{
            return
        }
        if layoutBottom.constant != -150.0{
            animating=true
            self.updateResultView()
            layoutBottom.constant = 0.0
            self.view.layoutSubtreeIfNeeded()
            weak var weakSelf=self
            NSAnimationContext.runAnimationGroup({
                context in
                context.duration=0.5
                context.allowsImplicitAnimation=true
                weakSelf?.visualView.material = .sheet
                weakSelf?.layoutBottom.constant = -150.0
                weakSelf?.view.layoutSubtreeIfNeeded()
            },completionHandler:{
                weakSelf?.animating=false
            })
        }
        
    }
    //is animation playing now?
    //block playing multi animations in the same time
    private var labelAnimation=false
    func showErrorMessage(_ msg:String){
        if labelAnimation{
            return
        }
        var alphaValue:CGFloat=0.0
        if msg.isEmpty{
            alphaValue=0.0
        }else{
            alphaValue=1.0
        }
        errorMsg.stringValue=msg
        if self.errorMsg.alphaValue != alphaValue{
            labelAnimation=true
            weak var weakSelf=self
            NSAnimationContext.runAnimationGroup({
                context in
                context.duration=0.5
                context.allowsImplicitAnimation=true
                weakSelf?.errorMsg.alphaValue=alphaValue
            },completionHandler:{
                weakSelf?.labelAnimation=false
            })
        }
        
    }
    private func alert(_ message:String){
        let alert=NSAlert()
        alert.messageText=message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "ok")
        alert.informativeText=""
        alert.beginSheetModal(for: self.view.window!,completionHandler:nil)
    }
    
    
    private func caculateHash(_ file:String){
        self.filePath=file
        digestor.digest(file, algorithm: algorithmType,version:digestVersion)
    }
    
    override var representedObject: Any? {
        didSet {
            
        }
    }
    //    click to choose file
    //    private func browse(){
    //        weak var weakSelf=self
    //        let panel=NSOpenPanel()
    //        panel.canChooseFiles=true
    //        panel.allowsMultipleSelection=false
    //        panel.canChooseDirectories=false
    //        panel.beginSheetModal(for: self.view.window!){
    //            response in
    //            if response == .OK{
    //                if let url=panel.url{
    //                    weakSelf?.caculateHash(url.path)
    //                }
    //            }
    //        }
    //    }
    
}
extension LSViewController:LSViewDraggingDelegate{
    func handle(_ uris: [URL]) {
        if digestor.running{
            return
        }
        if let uri=uris.first{
            self.caculateHash(uri.path)
        }
    }
    
    
}
extension LSViewController:DigestDelegate{
    
    func handle(_ event: DigestEvent) {
        switch (event.eventType){
        case .open:
            self.version.isEnabled=false
            self.algorithm.isEnabled=false
            self.progressBar.isHidden=false
            self.progressBar.doubleValue=0.0
            self.resetResultView()
            self.hideResultView()
            self.showErrorMessage("")
        case .error:
            self.hashString=""
            self.version.isEnabled=true
            self.algorithm.isEnabled=true
            self.progressBar.isHidden=true
            self.progressBar.doubleValue=0.0
            self.showErrorMessage(event.message)
            self.errorEffect.play()
        case .processing:
            self.progressBar.doubleValue=100.0*event.percent
        case .success:
            self.hashString=event.message
            self.version.isEnabled=true
            self.algorithm.isEnabled=true
            self.progressBar.isHidden=true
            self.showResultView()
            self.successEffect.play()
        }
        
    }
}

extension LSViewController:LSViewMouseDelegate{
    func handleMouseUp(_ event: NSEvent) {
        if self.hashString.isEmpty{
            return
        }
        if self.layoutBottom.constant == 0{
            self.hideResultView()
        }else{
            self.showResultView()
        }
    }
}


