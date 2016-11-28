//
//  KKViewController.swift
//  KKApp
//
//  Created by zhanghailong on 2016/11/27.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import UIKit
import KKObserver
import KKView
import KKLua

open class KKViewController: UIViewController {
    
    private var _document:KKDocument?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public var document:KKDocument {
        get {
            if(_document == nil) {
                _document = KKDocument.init(view: self.view)
            }
            return _document!
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = self.observer.stringValue(["app","kk-view"],nil)
        let app = self.app
        
        if(app != nil) {
            app!.luaMain(objects: [app!,KKLuaWeakObject.init(object: self.observer)])
        }
        
        if(app != nil && name != nil) {
            document.loadXML(contentsOf: app!.bundle.url(forResource: name, withExtension: "xml")!)
            app!.set(["action","view"], true)
        }
        
    }
    
    
}
