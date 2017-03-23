//
//  KKApplication_View.swift
//  KKApp
//
//  Created by zhanghailong on 2016/11/27.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import UIKit
import KKView
import KKObserver

class KKAppObserver : KKWithObserver {
    
    deinit {
        let v = app
        if v != nil {
            v!.recycle()
        }
    }
    
}

extension UIViewController {
    
    private static var kObserver = 0
    
    public var observer:KKWithObserver {
        get {
            var v = objc_getAssociatedObject(self, &UIViewController.kObserver) as! KKWithObserver?
            if(v == nil) {
                v = KKAppObserver.init();
                objc_setAssociatedObject(self, &UIViewController.kObserver, v, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                didObserver(observer: v!)
            }
            return v!
        }
    }
    
    public var app:KKApplication? {
        get {
            let v = self.observer.parent
            if v != nil && v is KKApplication {
                return (v as! KKApplication?)!
            }
            return nil
        }
    }
    
    internal func onAction(app:KKApplication) -> Bool {
        
        let name = app.stringValue(["action","name"],"")
        
        if name == "dismiss" {
            
            let animated = app.booleanValue(["action","animated"],true)
            
            self.dismiss(animated: animated, completion: nil)
            
            return true
        }
        
        return false
    }
    
    internal func didObserver(observer:KKWithObserver) -> Void {
        
        observer.on(["app","title"], { (observer:KKObserver, changedKey:[String], weakObject:AnyObject?) in
            
            if(weakObject != nil) {
                (weakObject as! UIViewController?)!.title = observer.stringValue(["app","title"],nil)
            }
            
        }, self)
        
        observer.on(["app","bar-title"], { (observer:KKObserver, changedKey:[String], weakObject:AnyObject?) in
            
            if(weakObject != nil) {
                (weakObject as! UIViewController?)!.tabBarItem.title = observer.stringValue(["app","bar-title"],nil)
            }
            
        }, self)
        
        observer.on(["app","bar-image"], { (observer:KKObserver, changedKey:[String], weakObject:AnyObject?) in
            
            if(weakObject != nil) {
                (weakObject as! UIViewController?)!.tabBarItem.image = UIImage.init(named: observer.stringValue(["app","bar-image"],"")!);
            }
            
        }, self)
        
        observer.on(["app","bottombar"], { (observer:KKObserver, changedKey:[String], weakObject:AnyObject?) in
            
            if(weakObject != nil) {
                (weakObject as! UIViewController?)!.hidesBottomBarWhenPushed = !observer.booleanValue(["app","bottombar"],true);
            }
            
        }, self)

        observer.on(["action"], { (observer:KKObserver, changedKeys:[String], weakObject:AnyObject?) in
            
            if(weakObject != nil) {
                
                let v:UIViewController = weakObject as! UIViewController
                let app = observer.app
                
                if app != nil
                    && observer.get(["action","name"]) != nil
                    && v.isViewLoaded && v.view.window != nil{
                    
                    if !v.onAction(app: app!) {
                        if app!.parent != nil {
                            app!.parent!.set(["action"], observer.get(["action"]))
                        }
                    }
                    
                }
            }
            
        }, self,true)

        
    }
    
    public func obtainApplication(_ app:KKApplication) {
        let v = self.app
        if v != app {
            self.observer.obtain(app, [])
            if v != nil {
                v!.recycle()
            }
        }
    }
    
}

extension UITabBarController {
 
    public override func obtainApplication(_ app:KKApplication) {
        super.obtainApplication(app)
        
        var viewControllers:[UIViewController] = []
        
        var p = app.firstChild
        
        while(p != nil) {
            let n = p!.nextSibling
            viewControllers.append(p!.obtain().openViewController())
            p = n
        }
        
        setViewControllers(viewControllers, animated: false);
        
    }
    
    internal override func onAction(app:KKApplication) -> Bool {
        
        let name = app.stringValue(["action","name"],"")
        
        if name == "open" {
            
            let open = app.stringValue(["action","open"],"")
            
            for viewController in self.viewControllers! {
                if viewController.app?.name == open {
                    self.selectedViewController = viewController
                    break
                }
            }
            
            return true
        }
        
        return super.onAction(app: app)
    }
    
}

extension UINavigationController {
    
    public override func obtainApplication(_ app:KKApplication) {
        super.obtainApplication(app)

        let p = app.firstChild
        
        if(p != nil) {
            pushViewController(p!.openViewController(), animated: false);
        }
        
    }
    
    internal override func onAction(app:KKApplication) -> Bool {
        
        let name = app.stringValue(["action","name"],nil)
        
        if name == "open" {
            
            let a = app.open(app.stringValue(["action","open"],"")!)
            let animated = app.booleanValue(["action","animated"],true)
            
            if(a != nil) {
                self.pushViewController(a!.openViewController(), animated: animated)
            }
            
            return true
            
        } else if name == "pop" {
            
            var names = app.stringValue(["action","pop"],"..")!.components(separatedBy: "/")
            let animated = app.booleanValue(["action","animated"],true)
            
            for i in 0..<names.count  {
                if i + 1 == names.count {
                    if names[i] == ".." {
                        self.popViewController(animated: animated)
                    }
                } else {
                    if names[i] == ".." {
                        self.popViewController(animated: false)
                    }
                }
            }
            
            return true
            
        }
        
        return super.onAction(app: app)
    }
    
}

extension KKObserver {
    
    public var app:KKApplication? {
        get {
            if self is KKApplication {
                return self as? KKApplication
            }
            return self.parent?.app
        }
    }
    
}

extension KKApplication {

    public func storyboard(name:String) -> UIStoryboard {
        var v = get(["storyboard",name]) as! UIStoryboard?
        if( v == nil && self.parent != nil) {
            v = (self.parent as! KKApplication?)!.storyboard(name: name)
        }
        if v == nil {
            v = UIStoryboard.init(name: name, bundle: nil)
            set(["storyboard",name],v)
        }
        return v!
    }
    
    public func openViewController() -> UIViewController {
        
        var v:UIViewController? = nil
        let clazz:String? = stringValue(["app","class"],nil)
        let nib:String? = stringValue(["app","nib"],nil)
        let storyboard:String? = stringValue(["app","storyboard"],nil)
        let identifier:String? = stringValue(["app","identifier"],nil)
        
        if( storyboard != nil ) {
            let s = self.storyboard(name:storyboard!)
            if identifier == nil {
                v = s.instantiateInitialViewController()
            }
            else {
                v = s.instantiateViewController(withIdentifier: identifier!)
            }
        }
        else if( clazz != nil) {
            let cls:AnyClass? = NSClassFromString(clazz!)
            if(cls != nil) {
                v = (cls as! UIViewController.Type).init(nibName: nib, bundle: nil)
            }
        }
        
        if v == nil {
            v = KKViewController.init(nibName: nil, bundle: nil)
        }
        
        v!.obtainApplication(self)
        
        return v!
    }
    
}
