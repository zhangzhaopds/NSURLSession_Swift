//
//  HTTP.swift
//  NSURLSession_Swift
//
//  Created by 张昭 on 16/3/9.
//  Copyright © 2016年 张昭. All rights reserved.
//

import UIKit

class HTTP: NSObject {

    /**
     数据请求
     
     - parameter urlStr:  请求地址
     - parameter reponse: 请求结果
     */
    func get(urlStr: String, reponse: (result: AnyObject, response: NSURLResponse)->Void)->Void  {
        
        if urlStr.isEmpty {
            print("Request address cannot be empty")
            return
        }
        let strEncode: String = urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url: NSURL = NSURL.init(string: strEncode)!
        let request: NSMutableURLRequest = NSMutableURLRequest.init(URL: url)
        
        let session: NSURLSession = NSURLSession.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, resp, err) -> Void in
            if (err != nil) {
                print("Data request failed: \(err?.code)")
                return
            }
            do {
                let json =
                try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                if (err == nil) {
                    reponse(result: json, response: resp!)
                }
            } catch {
            }
        }
        task.resume()
    }
    
    /**
     数据下载
     
     - parameter urlStr:  请求地址
     - parameter reponse: 数据本地保存地址
     */
    func downLoad(urlStr: String, reponse:(location: String)->Void)->Void {
        if urlStr.isEmpty {
            print("Request address cannot be empty")
            return
        }
        let strEncode: String = urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url: NSURL = NSURL.init(string: strEncode)!
        let request: NSMutableURLRequest = NSMutableURLRequest.init(URL: url)
        let session: NSURLSession = NSURLSession.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let downLoadTask: NSURLSessionDownloadTask = session.downloadTaskWithRequest(request) { (location, resp, err) -> Void in
            if (err != nil) {
                print("Data request failed: \(err?.code)")
                return
            }
            let caches: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
            let file: String = caches.stringByAppendingString("/\(resp!.suggestedFilename)")
            
            if NSFileManager.defaultManager().fileExistsAtPath(file) {
                if NSThread.isMainThread() {
                    reponse(location: file)
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        reponse(location: file)
                    })
                }
            } else {
                do {
                    try NSFileManager.defaultManager().moveItemAtPath(location!.path!, toPath: file)
                    if NSThread.isMainThread() {
                        reponse(location: file)
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            reponse(location: file)
                        })
                    }
                } catch {
                    
                }
            }
        }
        downLoadTask.resume()
    }

}
