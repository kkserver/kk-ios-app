//
//  KKApplication_Window.swift
//  KKApp
//
//  Created by zhanghailong on 2016/11/27.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import Foundation
import KKView

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
        
        return (v,document)
        
    }
}
