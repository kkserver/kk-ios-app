//
//  KKAppViewController.swift
//  KKApp
//
//  Created by zhanghailong on 2016/11/29.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import UIKit
import KKHttp

open class KKAppViewController: UIViewController {

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = self.observer.stringValue(["app","kk-app"],nil)
        let app = self.app
        
        if(app != nil && url != nil) {
        
            let key = KKHttpOptions.cacheKey(url: url!);
            
            do {
                _ = try KKHttp.main.get(url!
                    , nil, KKHttpOptions.TypeJson, { (data:Any?, error:Error?, weakObject:AnyObject?) in
                        
                        if(error != nil) {
                            UIAlertView.init(title: nil, message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "确定").show()
                        }
                        else if(weakObject != nil) {
                            (weakObject as! KKAppViewController?)?.updateApp(url:url!, key: key, info: data as! [String:Any])
                        }
                        
                    }, { (error : Error?, weakObject:AnyObject?) in
                        UIAlertView.init(title: nil, message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "确定").show()
                    }, self);
            }
            catch KKHttpOptionsError.URL {
                UIAlertView.init(title: nil, message: "URL格式错误", delegate: nil, cancelButtonTitle: "确定").show()
            }
            catch KKHttpOptionsError.JSON {
                UIAlertView.init(title: nil, message: "JSON格式错误", delegate: nil, cancelButtonTitle: "确定").show()
            }
            catch{
                UIAlertView.init(title: nil, message: "未知错误", delegate: nil, cancelButtonTitle: "确定").show()
            }
        }
    }

    internal func loadApp(path:String) ->Void {
        
        let app = self.app
        let v = KKApplication.init(bundle: Bundle.init(path: path)!, name: "app")
        
        if app != nil {
            app!.append(v)
        }
        
        let viewController = v.openViewController()
        
        addChildViewController(viewController);
    
    }
    
    internal func download(path:String,url:String,items:[String],index:Int,onload:@escaping KKHttpOptions.OnLoad,onfail:@escaping KKHttpOptions.OnFail) -> Void {
        
        if(index < items.count ) {
            
            let item = items[index]
            let tpath = path + "/" + item
            let fm = FileManager.default
            
            if fm.fileExists(atPath: tpath) {
                download(path: path, url: url, items: items, index: index + 1, onload: onload, onfail: onfail)
            }
            else {
                _ = try? KKHttp.main.get(URL.init(string: item, relativeTo: URL.init(string: url))!.absoluteString , nil, KKHttpOptions.TypeUri, { (data:Any?, error:Error?, weakObject:AnyObject?) in
                    
                    if error == nil {
                        let fm = FileManager.default
                        try? fm.moveItem(atPath: data as! String, toPath: tpath)
                        if( weakObject != nil) {
                            (weakObject as! KKAppViewController?)?.download(path: path, url: url, items: items, index: index + 1, onload: onload, onfail: onfail)
                        }
                    } else {
                        onfail(error,weakObject)
                    }
                    
                }, onfail, self)
            }
        }
        else {
            onload(nil,nil,self)
        }
    }
    
    internal func updateApp(url:String,key:String,info:[String:Any]) -> Void {
        
        let version = info["version"] as! String
        let path = KKHttpOptions.path(uri: "document:///" + key + "/" + version)
        let infoPath = path + "/app.json"
        let fm = FileManager.default
        
        let title = info["title"] as! String?
        
        if title != nil {
            self.title = title
        }
        
        if fm.fileExists(atPath: infoPath) {
            loadApp(path: path)
            return
        }
        
        let items = info["items"] as! [String]
        
        try? fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        
        download(path:path, url: url, items: items, index: 0, onload: { (data : Any?, error: Error?, weakObject:AnyObject?) in
            
            try? JSONSerialization.data(withJSONObject: info, options: .prettyPrinted).write(to: URL.init(fileURLWithPath: infoPath))
            
            if( weakObject != nil) {
                (weakObject as! KKAppViewController?)?.loadApp(path: path)
            }
            
        }) { (error:Error?, weakObject:AnyObject?) in
            UIAlertView.init(title: nil, message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "确定").show()
        }
        
    }
}
