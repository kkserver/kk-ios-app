//
//  KKApplication_Lua.swift
//  KKApp
//
//  Created by zhanghailong on 2016/11/27.
//  Copyright © 2016年 kkserver.cn. All rights reserved.
//

import KKLua
import KKView
import KKViewLua
import KKLuaHttp

extension KKApplication : KKScriptContext {
    
    public var luaState:KKLuaState {
        
        get {
            
            var v:KKLuaState? = get(["luaState"]) as! KKLuaState?
        
            if parent != nil {
                v = (parent as! KKApplication).luaState
            }
            
            if v == nil {
                v = KKLuaState.init()
                set(["luaState"],v)
            }
            
            return v!
        }
    }
    
    public func useScriptRunnable(type:String) -> KKScriptElementRunnable? {
        
        var v:KKScriptElementRunnable? = get(["script",type]) as! KKScriptElementRunnable?
        
        if parent != nil {
            v = (parent as! KKApplication).useScriptRunnable(type: type)
        }
        
        if v == nil {
            
            if type == "lua" {
                v = KKLuaScriptRunnable.init(state: luaState)
                set(["script",type],v)
            }
            
        }
        
        return v
    }
    
    public func luaOpenlibs() -> Void {
        
        let L = luaState

        L.openlibs()
        L.openhttplibs()
        
        let libs:String? = stringValue(["app","libs"],nil)
        
        if(libs != nil) {
            
            for lib in libs!.components(separatedBy: ";") {
                L.openlibs(bundle.path(uri: lib))
            }
            
        }
    }
    
    public func luaMain(objects:[AnyObject]) ->Void {
        
        let name:String? = stringValue(["app","lua-main"],nil)
        
        if name != nil {
            luaState.callFile(bundle.path(uri: name!), objects: objects)
        }
        
    }
}
