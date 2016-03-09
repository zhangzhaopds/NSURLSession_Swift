//
//  ViewController.swift
//  NSURLSession_Swift
//
//  Created by 张昭 on 16/3/9.
//  Copyright © 2016年 张昭. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var imageView: UIImageView?
        imageView = UIImageView.init(frame: CGRectMake(0, 0, 100, 100))
        imageView?.center = self.view.center
        imageView?.backgroundColor = UIColor.redColor()
        self.view.addSubview(imageView!)
        
        let postStr = "http://api.hoto.cn/index.php?appid=4&appkey=573bbd2fbd1a6bac082ff4727d952ba3&appsign=cee6710ae48a3945b398702d8702510a&channel=appstore&deviceid=0f607264fc6318a92b9e13c65db7cd3c%7C552EE383-0FAD-4555-9979-AC38A01C5D6D%7C9C579DCC-7C8F-4E53-AEB6-54527C473309&format=json&loguid=&method=Recipe.getFindRecipe&nonce=1443856978&sessionid=1443856790&signmethod=md5&timestamp=1443856978&uuid=02288be08f4b871a69565746255b0de9&v=2&vc=40&vn=v5.1.0"
        let picStr = "http://img4.duitang.com/uploads/item/201207/28/20120728105310_jvAjW.thumb.600_0.jpeg"
        let http = HTTP()
        
        http.get(postStr) { (result, response) -> Void in
            print(result)
        }
        
        http.downLoad(picStr) { (location) -> Void in
            imageView?.image = UIImage.init(contentsOfFile: location)
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

