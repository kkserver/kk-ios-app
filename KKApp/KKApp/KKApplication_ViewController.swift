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
    
    internal func didObserver(observer:KKWithObserver) -> Void {
        
        observer.on(["app","title"], { (observer:KKObserver, changedKey:[String], weakObject:AnyObject?) in
            
            if(weakObject != nil) {
                (weakObject as! UIViewController?)!.title = observer.stringValue(["app","title"],nil)
            }
            
        }, self)
        
    }
    
    public func obtainApplication(_ app:KKApplication) {
        let v = self.app
        if v != app {
            self.observer.obtain(app.obtain(), [])
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
            viewControllers.append(p!.openViewController())
            p = n
        }
        
        setViewControllers(viewControllers, animated: false);
        
    }
    
    internal override func didObserver(observer:KKWithObserver) -> Void {
        super.didObserver(observer: observer)
        
        observer.on(["action","open"], { (observer:KKObserver, changedKeys:[String], weakObject:AnyObject?) in
            
            if( weakObject != nil) {
                
                let v:UITabBarController = weakObject as! UITabBarController
                let app = observer.app
                
                if app != nil {
                    
                    let (a,index) = app!.app(app!.stringValue(["action","open"],"")!)
                    
                    if(a != nil) {
                        v.selectedIndex = index
                    }
                    
                }
                
            }
            
            }, self)
        
        
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
    
    internal override func didObserver(observer:KKWithObserver) -> Void {
        super.didObserver(observer: observer)
        
        observer.on(["action","open"], { (observer:KKObserver, changedKeys:[String], weakObject:AnyObject?) in
            
            if( weakObject != nil) {
                
                let v:UINavigationController = weakObject as! UINavigationController
                let app = observer.app
                
                if app != nil {
                    
                    let (a,_) = app!.app(app!.stringValue(["action","open"],"")!)
                    let animated = app!.booleanValue(["action","animated"],true)
                    
                    if(a != nil) {
                        v.pushViewController(a!.openViewController(), animated: animated)
                    }
                    
                }
            }
            
            }, self)
        
        
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
