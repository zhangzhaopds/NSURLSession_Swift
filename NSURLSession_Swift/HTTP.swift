//
//  HTTP.swift
//  NSURLSession_Swift
//
//  Created by 张昭 on 16/3/9.
//  Copyright © 2016年 张昭. All rights reserved.
//

import UIKit

class HTTP: NSObject {
    
    enum DataType {
        case JPEG
        case PNG
    }

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
                reponse(result: json, response: resp!)
                
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
                print("DownLoadData request failed: \(err?.code)")
                return
            }
            let caches: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
           
            let file: String = caches.stringByAppendingString("/\(resp!.suggestedFilename!)")
            
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

    /**
     普通数据上传
     
     - parameter urlStr:     上传地址
     - parameter uploadData: 字典数据
     - parameter reponse:    上传结果
     */
    func upLoadData(urlStr: String, uploadData: AnyObject, reponse: (result: AnyObject, response: NSURLResponse)->Void)->Void {
        if urlStr.isEmpty {
            print("Request address cannot be empty")
            return
        }
        
        let strEncode: String = urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url: NSURL = NSURL.init(string: strEncode)!
        let request: NSMutableURLRequest = NSMutableURLRequest.init(URL: url)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        request.timeoutInterval = 20
        do {
            let data: NSData =
            try NSJSONSerialization.dataWithJSONObject(uploadData, options: NSJSONWritingOptions.PrettyPrinted)
            let session: NSURLSession = NSURLSession.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let uploadTask: NSURLSessionUploadTask = session.uploadTaskWithRequest(request, fromData: data, completionHandler: { (result, resp, err) -> Void in
                if (err != nil) {
                    print("UpLoadData request failed: \(err?.code)")
                    return
                }

                do {
                    let json: AnyObject =
                    try NSJSONSerialization.JSONObjectWithData(result!, options: NSJSONReadingOptions.MutableContainers)
                    reponse(result: json, response: resp!)
                } catch {
                    
                }
                
            })
            uploadTask.resume()
        } catch {
            
        }
    }
    
    /**
     图片上传
     
     - parameter urlStr:     上传地址
     - parameter uploadData: 图片数据
     - parameter dataType:   图片类型
     - parameter reponse:    上传结果
     */
    func upLoadImage(urlStr: String, image: UIImage, dataType: DataType, reponse: (result: String, response: NSURLResponse)->Void)->Void {
        if urlStr.isEmpty {
            print("Request address cannot be empty")
            return
        }
        
        let strEncode: String = urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url: NSURL = NSURL.init(string: strEncode)!
        let request: NSMutableURLRequest = NSMutableURLRequest.init(URL: url)
        var daa = NSData()
        switch dataType {
        case .JPEG:
            request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            request.addValue("text/html", forHTTPHeaderField: "Accept")
            daa = UIImageJPEGRepresentation(image, 1)!
        case .PNG:
            request.addValue("image/png", forHTTPHeaderField: "Content-Type")
            request.addValue("text/html", forHTTPHeaderField: "Accept")
            daa = UIImagePNGRepresentation(image)!
        }
        
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        request.timeoutInterval = 20
        let session: NSURLSession = NSURLSession.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let uploadTask: NSURLSessionUploadTask = session.uploadTaskWithRequest(request, fromData: daa, completionHandler: { (result, resp, err) -> Void in
            
            if (err != nil) {
                print("UpLoadImage request failed: \(err?.code)")
                return
            }
            let ss: String = String.init(data: result!, encoding: NSUTF8StringEncoding)!
            reponse(result: ss, response: resp!)
        })
        uploadTask.resume()
    }
}
