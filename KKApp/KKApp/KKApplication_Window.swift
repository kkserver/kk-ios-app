//
//  KKApplication_Window.swift
//  KKApp
//
//  Created by zhanghailong on 2016/11/27.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation
import KKView
import KKObserver

public extension KKApplication {

    public func openWindow() -> (UIWindow,KKDocument) {
       
        let v:UIWindow = UIWindow.init(frame: UIScreen.main.bounds)
        let document:KKDocument = KKDocument.init(view: v);
        let name:String? = stringValue(["app","kk-view"],nil)
        
        if(name != nil) {
            document.loadXML(contentsOf: bundle.url(forResource: name, withExtension: "xml")!)
        }
        
        let p = firstChild
        
        if p != nil {
            v.rootViewController = p!.openViewController()
        }
        
        on(["action"], { (observer:KKObserver, changedKey:[String], weakObject:AnyObject?) in
            
            let name = observer.stringValue(["action","name"], "")

            if(weakObject != nil && name == "present") {
                
                var viewController = (weakObject as! UIWindow?)?.rootViewController
                
                while( viewController != nil && viewController?.presentedViewController != nil) {
                    viewController = viewController?.presentedViewController
                }
                
                if viewController != nil {
                    
                    let app = observer.app
                    
                    if app != nil {
                        
                        let (a,_) = app!.app(app!.stringValue(["action","present"],"")!)
                        let animated = app!.booleanValue(["action","animated"],true)
                        
                        if(a != nil) {
                            viewController?.present(a!.openViewController(), animated: animated, completion: nil)
                        }
                        
                    }
                    
                }
            }
            
        }, v)
        
        return (v,document)
        
    }
}
