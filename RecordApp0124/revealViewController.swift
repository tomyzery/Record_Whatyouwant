//
//  revealViewController.swift
//  RecordApp0124
//
//  Created by cscoi018 on 2018. 1. 24..
//  Copyright © 2018년 seok. All rights reserved.
//

import UIKit

class revealViewController: UIViewController {

    var contentVC: UIViewController?
    var sideVC: UIViewController?
    
    
    var eachPDFName: String = ""
    var eachFolderName: String = ""
    
    var isSideBarShowing = false
    
    let SLIDE_TIME = 0.3
    let SIDEBAR_WIDTH: CGFloat = 260
    
    func setupView() {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "sw_front") as? UINavigationController {
            self.contentVC = vc
            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
            vc.didMove(toParentViewController: self)
            
            let frontVC = vc.viewControllers[0] as? pdfViewController
            frontVC?.delegate = self

        }
    }
    
    func getSideView() {

        if self.sideVC == nil {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "sw_rear") as? sideBarViewController {
                vc.delegate = self
                vc.delegate2 = (contentVC as! UINavigationController).viewControllers[0] as? pdfViewController
               
                
                
                self.sideVC = vc
                self.addChildViewController(vc)
                self.view.addSubview(vc.view)
                vc.didMove(toParentViewController: self)
                self.view.bringSubview(toFront: (self.contentVC?.view)!)
            }
        }
        
    }
    
    func setShadowEffect( shadow: Bool, offset: CGFloat) {
        if (shadow == true) {
            self.contentVC?.view.layer.cornerRadius = 10
            self.contentVC?.view.layer.shadowOpacity = 0.8
            self.contentVC?.view.layer.shadowColor = UIColor.black.cgColor
            self.contentVC?.view.layer.shadowOffset = CGSize(width: offset, height: offset)
        } else {
            self.contentVC?.view.layer.cornerRadius = 0.0;
            self.contentVC?.view.layer.shadowOffset = CGSize(width:0, height:0);
        }
    }
    
    func openSideBar(_ complete: ( () -> Void)? ) {
        self.getSideView()
        self.setShadowEffect(shadow: true, offset: -2)
        let options = UIViewAnimationOptions([.curveEaseOut, .beginFromCurrentState])
        
        UIView.animate(withDuration: TimeInterval(self.SLIDE_TIME), delay: TimeInterval(0), options: options,
                       animations: { self.contentVC?.view.frame = CGRect(x: self.SIDEBAR_WIDTH, y:0, width: self.view.frame.width
                        , height: self.view.frame.height )
                        
        }, completion: {
            if $0 == true {
                self.isSideBarShowing = true
                complete?()
                }
            }
        )
    }
    
    func closeSideBar(_ complete: ( () -> Void)? ) {
        let options = UIViewAnimationOptions([.curveEaseInOut, .beginFromCurrentState])
        
        UIView.animate(withDuration: TimeInterval(self.SLIDE_TIME), delay: TimeInterval(0) , options: options ,
                       animations: { self.contentVC?.view.frame = CGRect(x:0, y:0, width:self.view.frame.width,
                                    height:self.view.frame.height)
                        
        },
        completion: {
            if $0 == true {
                self.sideVC?.view.removeFromSuperview()
                self.sideVC = nil
                self.isSideBarShowing = false
                self.setShadowEffect(shadow: false, offset: 0)
                complete?()
                }
            }
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        print(" eachPDFName :\(String(describing: eachPDFName))")
        print(" eachFolderName :\(String(describing: eachFolderName))")
        // Do any additional setup after loading the view.
        
        let fileManager = FileManager.default
        let filePath2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let eachMp3 = filePath2.appendingPathComponent("FolderList").appendingPathComponent(self.eachFolderName).appendingPathComponent(self.eachFolderName + "_audio").appendingPathComponent(self.eachPDFName)
        
        do {
            try fileManager.createDirectory(atPath: eachMp3.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
