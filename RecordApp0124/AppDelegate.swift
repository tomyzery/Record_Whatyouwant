//
//  AppDelegate.swift
//  RecordApp0124
//
//  Created by cscoi018 on 2018. 1. 24..
//  Copyright © 2018년 seok. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // folder scene 의 폴더 리스트 정보
    var folderList : [String] = []
    var PDFFileList : [String] = []
    var ButtonToUse : [String : [ButtonInfo]] = [:]
    var audioContents : [String : [audioinfo]] = [:]
    
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        return true
    }
        
    // 처음 켰을떄 , 아예 껐다가 다시
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }
    // 전환이 될때 저장
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    // 사용자가 보이지 않는 상태로 넘어갈때
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        
    }
    // 백그라운드에서 보일려고 할때 , 저장된 데이터를 읽어온다
    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }
    // 화면에 보이는 상태, 입력을 받을수 있는 상태 , 저장된 데이터를 읽어온다
    func applicationDidBecomeActive(_ application: UIApplication) {
       
    }

    func applicationWillTerminate(_ application: UIApplication) {
       
    }


}

