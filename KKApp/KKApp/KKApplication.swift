//
//  KKApplication.swift
//  KKApp
//
//  Created by zhanghailong on 2016/11/26.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import UIKit
import KKObserver

public extension Bundle {
    
    public func path(uri:String)->String {
        
        if uri.hasPrefix("document://") {
            return NSHomeDirectory().appending(uri.substring(from: uri.index(uri.startIndex, offsetBy: 11)))
        }
        else if uri.hasPrefix("app://") {
            return Bundle.main.resourcePath!.appending(uri.substring(from: uri.index(uri.startIndex, offsetBy: 6)))
        }
        else if uri.hasPrefix("cache://") {
            return NSHomeDirectory().appendingFormat("/Library/Caches%@", uri.substring(from: uri.index(uri.startIndex, offsetBy: 8)))
        }
        else if uri.hasPrefix("/") {
            return uri
        }
        else {
            return bundlePath.appendingFormat("/%@", uri)
        }
        
    }
    
}

public class KKApplication: KKObserver,XMLParserDelegate {

    private weak var _parent:KKApplication?
    private var _firstChild:KKApplication?
    private var _lastChild:KKApplication?
    private var _nextSibling:KKApplication?
    private weak var _prevSibling:KKApplication?
    private let _bundle:Bundle
    
    public override var parent:KKObserver? {
        get {
            return _parent;
        }
    }
    
    public var firstChild:KKApplication? {
        get {
            return _firstChild;
        }
    }
    
    public var lastChild:KKApplication? {
        get {
            return _lastChild;
        }
    }
    
    public var nextSibling:KKApplication? {
        get {
            return _nextSibling;
        }
    }
    
    public var prevSibling:KKApplication? {
        get {
            return _prevSibling;
        }
    }
    
    public var bundle:Bundle {
        get {
            return _bundle;
        }
    }
    
    public required init(bundle:Bundle) {
        _bundle = bundle
        super.init();
    }
    
    public required init(bundle:Bundle,name:String) {
        _bundle = bundle
        super.init();
        
        let url = bundle.url(forResource: name, withExtension: "xml");
        
        if(url != nil) {
            
            set(["app","url"],url)
            
            let parser = XMLParser.init(contentsOf: url!)
            
            if(parser != nil) {
                parser!.delegate = self
                parser!.parse()
            }
        }
    }
    
    public func append(_ element:KKApplication) -> Void {
        
        let e = element
        
        e.remove()
        
        if _lastChild != nil {
            _lastChild!._nextSibling = e
            e._prevSibling = _lastChild
        } else {
            _firstChild = e
            _lastChild = e
        }
        
        e._parent = self
        
        onAddChildren(element)
        
    }
    
    public func appendTo(_ element:KKApplication) -> Void {
        element.append(self)
    }
    
    public func remove() -> Void {
        
        let p = _parent
        let e = self
        
        if _prevSibling != nil {
            _prevSibling!._nextSibling = _nextSibling
            
            if _nextSibling != nil {
                _nextSibling!._prevSibling = _prevSibling
            } else if _parent != nil {
                _parent!._lastChild = _prevSibling
            }
        } else if _parent != nil {
            _parent!._firstChild = _nextSibling
            if _nextSibling != nil {
                _nextSibling!._prevSibling = nil
            } else {
                _parent!._lastChild = _nextSibling
            }
        }
        
        _parent = nil
        _nextSibling = nil
        _prevSibling = nil
        
        if p != nil {
            p?.onRemoveChildren(e)
        }
        
    }
    
    public func removeAllChildren() -> Void  {
        var p = _firstChild
        while p != nil {
            let n = p!.nextSibling
            p!.remove()
            p = n
        }
    }
    
    public func before(_ element:KKApplication) -> Void {
        
        let e = element
        
        e.remove()
        
        if _parent != nil {
            
            e._parent = _parent
            
            if _prevSibling != nil {
                _prevSibling!._nextSibling = e
                e._prevSibling = _prevSibling
                e._nextSibling = self
                _prevSibling = e
            } else {
                _parent?._firstChild = e
                e._nextSibling = self
                _prevSibling = e
            }
            
            _parent!.onAddChildren(e)
            
        }
    }
    
    public func beforeTo(_ element:KKApplication) -> Void {
        element.before(self)
    }
    
    public func after(_ element:KKApplication) -> Void {
        
        let e = element
        
        e.remove()
        
        if _parent != nil {
            
            e._parent = _parent
            
            if _nextSibling != nil {
                e._nextSibling = _nextSibling
                e._prevSibling = self
                _nextSibling!._prevSibling = e
                _nextSibling = e
            } else {
                _parent?._lastChild = e
                e._prevSibling = self
                _nextSibling = e
            }
            
            _parent!.onAddChildren(e)
            
        }
    }
    
    public func afterTo(_ element:KKApplication) -> Void {
        element.after(self)
    }
    
    public func onRemoveChildren(_ element:KKApplication) -> Void {
        
        element.onRemoveFromParent(self)
        
    }
    
    public func onAddChildren(_ element:KKApplication) -> Void {
        
        element.onAddToParent(self)
        
    }
    
    public func onAddToParent(_ element:KKApplication) -> Void {
        
    }
    
    public func onRemoveFromParent(_ element:KKApplication) -> Void {
        
    }
    
    public var name:String? {
        get {
            return KKObject.stringValue(get(["app","name"]), nil);
        }
    }
    
    public var title:String? {
        get {
            return KKObject.stringValue(get(["app","title"]), nil);
        }
    }
    
    public var url:URL? {
        get {
            return get(["app","url"]) as! URL?
        }
    }
   
    public func clone() -> KKApplication {
        let app = type(of: self).init(bundle: bundle)
        app.set(["app"], get(["app"]))
        var p = firstChild
        while(p != nil) {
            app.append(p!.clone())
            p = p!.nextSibling
        }
        return app
    }
    
    private var _element:KKApplication?
    
    internal func onStartDocument() ->Void {
        
    }
    
    internal func onEndDocument() ->Void {
        
    }
    
    public func parserDidStartDocument(_ parser: XMLParser) {
        _element = nil
        onStartDocument()
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        _element = nil
        onEndDocument()
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        let path = attributeDict["path"];
        var e:KKApplication?
        
        if(_element == nil) {
            _element = self
            e = _element
        }
        else {
            e = KKApplication.init(bundle: path == nil ? _element!.bundle : Bundle.init(path: _element!.bundle.bundlePath+"/"+path!)!)
            e!.appendTo(_element!)
        }
        
        for (key,value) in attributeDict {
            e!.set(["app",key],value)
        }
    
        e!.set(["app","name"],elementName)
        
        print("[KK]",e!.value ?? "")
        
        _element = e
    }
    
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        _element = _element!.parent as! KKApplication?
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        NSLog("[KK][KKApplication] %@", parseError.localizedDescription)
        print(parseError)
    }
    
    
    public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        NSLog("[KK][KKApplication] %@", validationError.localizedDescription)
        print(validationError)
    }
    
    public func open(_ name:String,_ animated:Bool) ->Void {
        set(["action"],["open":name,"animated":animated])
    }
    
    public func obtain() -> KKApplication {
        if booleanValue(["obtain"],false) {
            var p = nextSibling
            if p != nil && name == p!.name {
                return p!.obtain()
            }
            p = clone()
            p!.set(["clone"],true)
            p!.afterTo(self)
            return p!
        }
        set(["obtain"],true)
        return self
    }
    
    public func recycle() -> Void {
        
        if booleanValue(["obtain"],false) {
            
            set(["obtain"],false)
            
            set(["recycle"],true)
            
            if(booleanValue(["clone"], true)) {
                
                remove()
                
            }
        }
        
    }
    
    public func app(_ name:String) -> (KKApplication?,Int) {
        
        var index:Int = 0
        var p = firstChild
        
        while(p != nil) {
            if(p!.name == name) {
                return (p,index)
            }
            index = index + 1
            p = p!.nextSibling
        }
        
        return (nil,0)
    }
    
    private static var _main:KKApplication?
    
    public static var main:KKApplication {
        get {
            if(_main == nil) {
                _main = KKApplication.init(bundle: Bundle.main, name: "app")
            }
            return _main!
        }
    }
    
}

