//
//  FolderViewController.swift
//  RecordApp0124
//
//  Created by cscoi018 on 2018. 1. 27..
//  Copyright © 2018년 seok. All rights reserved.
//

import UIKit

class FolderViewController: UIViewController  , UITableViewDataSource , UITableViewDelegate{
    
    // folderNameList 초기화
    var folderNameList : [String]? = nil
    // AppDelegate를 통한 앱데이터 생성
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableview delegate, datasource 사용
        tableView.delegate = self
        tableView.dataSource = self
        
        let fileManager = FileManager()
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsDirectory2 = documentsDirectory.appendingPathComponent("FolderList")
        let documentsDirectory4 = documentsDirectory.appendingPathComponent("mp3List")
        let documentsDirectory3 = documentsDirectory.appendingPathComponent("FolderList").appendingPathComponent("Human Respiratory")
        
        print("This project path to Docunets or the other Things :\(documentsDirectory2)")
        
        do {
            try fileManager.createDirectory(atPath: documentsDirectory2.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        do {
            try fileManager.createDirectory(atPath: documentsDirectory4.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        do {
            try fileManager.createDirectory(atPath: documentsDirectory3.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        
        // edit 버튼 위치 설정
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // 화면 나타나기 이전 checkFolderList 를 통해 폴더 리스트 동기화
    override func viewWillAppear(_ animated: Bool) {
        if folderNameList == nil {
            checkFolderList()
        }
    }
    
    // 화면 전환 전 appDelegate 로 데이터 동기화
    override func viewWillDisappear(_ animated: Bool) {
        appDelegate.folderList = self.folderNameList!
    }
    
    // 다음 화면인 File scene 의 Header 로 데이터 전달
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! FileViewController
        let cell = sender as! UITableViewCell
        let indexPath = self.tableView.indexPath(for: cell)!
        let selectedFileHeader = folderNameList![indexPath.row]
        nextVC.FileHeader = selectedFileHeader
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // 테이블 뷰 섹션 갯수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 테이블 뷰 셀 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderNameList!.count
    }
    
    // 테이블 뷰 셀 기본설정 및 타이틀 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell1", for: indexPath)
        cell.imageView?.image = UIImage(named:"folder")
        cell.textLabel?.text = folderNameList?[indexPath.row]
        return cell
    }

    // 테이블 뷰 섹션의 헤더 타이틀 설정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Documents Folder"
    }

    // 테이블 뷰 셀 edit 설정
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 테이블 뷰 edit(Delete) 기능
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
             let item = folderNameList!.remove(at: indexPath.row)
             let fileManager = FileManager()
             let documentsDirectory2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
             let documentsDirectory = documentsDirectory2.appendingPathComponent("FolderList")
             let dataPath = documentsDirectory.appendingPathComponent(item)
             do {
             try fileManager.removeItem(at: dataPath)
             } catch let error as NSError {
             print("Error creating directory: \(error.localizedDescription)")
             }
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }

    // 테이블 뷰 셀 이동 기능
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
         let saveChanges = self.folderNameList![fromIndexPath.row]
         let removeItem = self.folderNameList!.remove(at: fromIndexPath.row)
         self.folderNameList!.insert(saveChanges, at : to.row)
         let fileManager = FileManager()
         let documentsDirectory2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
         let documentsDirectory = documentsDirectory2.appendingPathComponent("FolderList")
         let keep = documentsDirectory.appendingPathComponent(saveChanges)
         let temp = documentsDirectory.appendingPathComponent(removeItem)
        
         do {
         try fileManager.removeItem(at: temp)
         } catch let error as NSError {
         print("Error creating directory: \(error.localizedDescription)")
         }
        
         do {
         try fileManager.createDirectory(at: keep, withIntermediateDirectories: false, attributes: nil)
         } catch let error as NSError {
         print("Error creating directory: \(error.localizedDescription)")
         }
        self.tableView.reloadData()
    }
    
    // 테이블 뷰 셀 move 설정
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 테이블 뷰의 edit 버튼 기능
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        let status = navigationItem.rightBarButtonItem?.title
        
        if status == "Edit" {
            tableView.setEditing(true, animated: animated)
            tableView.isEditing = true
            navigationItem.rightBarButtonItem?.title = "Done"
        } else {
            tableView.setEditing(false, animated: animated)
            tableView.isEditing = false
            navigationItem.rightBarButtonItem?.title = "Edit"
        }
    }
    
    // plus 버튼 눌렀을시의 동작
    @IBAction func folderPlusBtn(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "New Folder Name", message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
            let textField = alert.textFields![0] as UITextField
            let folderName = textField.text!
            let fileManager = FileManager()
            let documentsDirectory2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let documentsDirectory = documentsDirectory2.appendingPathComponent("FolderList")
            let dataPath = documentsDirectory.appendingPathComponent(folderName)
            
            do {
                try fileManager.createDirectory(atPath: dataPath.path, withIntermediateDirectories: false, attributes: nil)
                } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
                }
            
            self.folderNameList?.append(folderName)
            self.tableView.reloadData()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
    
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.keyboardType = .default
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated:true , completion: nil)
    }
    

    // 경로에 있는 폴더 리스트들 확인
    func checkFolderList() {
        
        let fileManager = FileManager.default
        let documentsDirectory2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsDirectory = documentsDirectory2.appendingPathComponent("FolderList")
        
        var folderNameList: [String] = []
        
        do{
            folderNameList = try fileManager.contentsOfDirectory(atPath: documentsDirectory.path)
            
            
        } catch {
            print("error")
            
        }
        
        self.folderNameList = folderNameList
        self.tableView.reloadData()
        
        }
    
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }

    
}






