//
//  checkUpdate.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

// TODO: NSURLSessionでの書き直し
// NSURLConnection.sendAsynchronousRequestはdeprecatedだが
// NSURLSessionを使うと実行時にalert.runModal()でエラーが出たため
// NSURLConnectionで代用中

import Cocoa

func checkUpdate(_ callback: ((_ isNewVer: Bool?) -> Void)? = nil) {
    let url = URL(string: "https://ei-kana.appspot.com/update.json")!
    let request = URLRequest(url: url)
    
    let handler = { (res:URLResponse?,data:Data?,error:Error?) -> Void in
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        var newVersion = ""
        var description = ""
        
        do {
            if let data = data {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                newVersion = json["version"] as! String
                description = json["description"] as! String
            }
        } catch let error as NSError {
            print(error.debugDescription)
            return;
        }
        
        let isAbleUpdate: Bool? = (newVersion == "") ? nil : newVersion != version
        
        if isAbleUpdate == true {
            let alert = NSAlert()
            alert.messageText = "⌘英かな ver.\(newVersion) が利用可能です"
            alert.informativeText = description
            alert.addButton(withTitle: "DLページへ")
            alert.addButton(withTitle: "キャンセル")
            // alert.showsSuppressionButton = true;
            let ret = alert.runModal()
            
            if (ret == NSAlertFirstButtonReturn) {
                NSWorkspace.shared().open(URL(string: "https://ei-kana.appspot.com")!)
            }
        }
        
        if let callback = callback {
            callback(isAbleUpdate)
        }
    }
    
    NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: handler)
}
