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
                _document!.on("", { (name:String, event:KKEvent, weakObject:AnyObject?) in
                    if weakObject != nil {
                        let v = weakObject as! KKViewController?
                        if event is KKElementEvent {
                            let e = event as! KKElementEvent
                            v!.observer.set(["action"], ["name": name , "data" : e.element.get(KKProperty.Data)] )
                        }
                    }
                }, self)
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
            
            document.bundle = app!.bundle
            
            let v = app!.bundle.url(forResource: name, withExtension: "xml")
            
            if v != nil {
                document.loadXML(contentsOf: v!)
                KKScriptElement.runScriptElement(document, app!)
            } else {
                NSLog("[KK] not found view %@", name!)
            }
            
            app!.set(["action","view"], true)
        }
        
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if _document != nil {
            document.layout(self.view.bounds.size)
            if(document.get(KKProperty.Observer) == nil) {
                document.set(KKProperty.Observer,self.observer)
            }
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        let app = self.app
        
        if(app != nil) {
            
            if(self.navigationController != nil) {
                
                let hidden = self.navigationController!.isNavigationBarHidden
                app!.set(["topbar","hidden"], hidden);
                
                if(app!.booleanValue(["app","topbar"], true) != !hidden) {
                    self.navigationController?.setNavigationBarHidden(!hidden, animated: false)
                }
            }
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        let app = self.app
        
        if(app != nil) {
            
            if(self.navigationController != nil) {
                
                let hidden = app!.booleanValue(["topbar","hidden"], false)
                
                if(self.navigationController!.isNavigationBarHidden != hidden) {
                    self.navigationController?.setNavigationBarHidden(hidden, animated: false)
                }
            }
        }
    }
    
}
