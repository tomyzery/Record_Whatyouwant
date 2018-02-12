//
//  FileViewController.swift
//  RecordApp0124
//
//  Created by cscoi018 on 2018. 1. 27..
//  Copyright © 2018년 seok. All rights reserved.
//


import UIKit


class FileViewController: UIViewController  ,UITableViewDataSource, UITableViewDelegate {

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // RecordedList , NonRecordedList 초기화
    var fileRecordedList : [String] = []
    var fileNonRecordedList : [String] = []
    

    // Folder scene 에서 받아오는 테이블 뷰의 헤더
    @IBOutlet weak var folderName: UINavigationItem!
    var FileHeader: String = ""
    

    override func viewWillAppear(_ animated: Bool) {
        if folderName != nil {
        // 화면 시작 전 file scene의 헤더 호출
            folderName.title = FileHeader
        }
        
        // 화면 시작 전 checkFileRecordedList , checkFileNonRecroded 즉 기존 파일들 리스트 동기화
        checkFileRecordedList()
        checkFileNonRecordedList()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableview delegate, datasource 사용
        tableView.delegate = self
        tableView.dataSource = self
     
        let fileManager = FileManager()
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsDirectory2 = documentsDirectory.appendingPathComponent("FolderList").appendingPathComponent(FileHeader)
        let fileRecorded = documentsDirectory2.appendingPathComponent("Recorded")
        let fileNonRecorded = documentsDirectory2.appendingPathComponent("Non Recorded")
        let samplePDF1 = documentsDirectory2.appendingPathComponent("Recorded").appendingPathComponent("Human Respiratory 2017.06.14")
        let samplePDF3 = documentsDirectory2.appendingPathComponent("Non Recorded").appendingPathComponent("Human Respiratory 2017.06.21")
      
        
        // file scene 에 기본적으로 record section 과 nonrecorded section 을 위한 경로 생성
        do {
            try fileManager.createDirectory(atPath: fileRecorded.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        do {
            try fileManager.createDirectory(atPath: fileNonRecorded.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
        do {
            try fileManager.createDirectory(atPath: samplePDF1.path, withIntermediateDirectories: false, attributes: nil)
        } catch {

        }
        do {
            try fileManager.createDirectory(atPath: samplePDF3.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            
        }
     
        
        checkFileRecordedList()
        checkFileNonRecordedList()

        // edit 버튼 추가
            self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    

    @IBOutlet weak var tableView: UITableView!
    
    // 테이블 뷰 섹션 갯수
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    // 테이블 뷰 셀 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return fileRecordedList.count
        } else {
            return fileNonRecordedList.count
        }
    }
    
    // 테이블 뷰 셀 기본설정 및 타이틀 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell2", for: indexPath)
        
        if indexPath.section == 0 {
            cell.imageView?.image = UIImage(named:"pdf")
            cell.textLabel?.text = fileRecordedList[indexPath.row]
        } else {
            cell.imageView?.image = UIImage(named:"pdf")
            cell.textLabel?.text = fileNonRecordedList[indexPath.row]
        }
        return cell
    }
    
    // 테이블 뷰 섹션의 헤더 타이틀 설정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Recorded"
        } else {
            return "Non Recorded"
        }
    }
    
    // 테이블 뷰 셀 edit 설정
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // 테이블 뷰 edit(Delete) 기능
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                fileRecordedList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                fileNonRecordedList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
           
        }
    }
    
    // 테이블 뷰 셀 이동 기능
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        if tableView.numberOfSections == 0 {
            let saveChanges = fileRecordedList[fromIndexPath.row]
            fileRecordedList.remove(at: fromIndexPath.row)
            fileNonRecordedList.insert(saveChanges, at : to.row)
        } else  {
            let saveChanges = fileNonRecordedList[fromIndexPath.row]
            fileRecordedList.remove(at: fromIndexPath.row)
            fileNonRecordedList.insert(saveChanges, at : to.row)
        }
    }

    // 테이블 뷰 셀 edit 설정
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // plus 버튼 클릭 시 web browser , url 을 이용한 파일 로드
    @IBAction func webCallBtn(_ sender: UIButton) {
    
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: "Open by Web browser", style: .default) { action -> Void in
            if let url = URL(string: "https://www.google.com") {
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        let secondAction: UIAlertAction = UIAlertAction(title: "Open by URL", style: .default){ action -> Void in
            let alert = UIAlertController(title: " Type URL ", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            let okAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
                let textField = alert.textFields![0] as UITextField
                let urlName = textField.text!
                
                // urlName 마지막 문자열, 파일 이름 출력
                
                let urlString = urlName.components(separatedBy: "/")
                let lastWord = urlString.last
                
                let fileManager = FileManager.default
                let filePath2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let filePath = filePath2.appendingPathComponent("FolderList").appendingPathComponent(self.FileHeader)
                    .appendingPathComponent("Non Recorded").appendingPathComponent(lastWord!)
       
                //Create URL to the source file you want to download
                let fileURL = URL(string: urlName)
                
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)
                
                let request = URLRequest(url:fileURL!)
                
                let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                    if let tempLocalUrl = tempLocalUrl, error == nil {
                        // Success
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            print("Successfully downloaded. Status code: \(statusCode)")
                        }
                        
                        do {
                            try FileManager.default.copyItem(at: tempLocalUrl, to: filePath)
                        } catch (let writeError) {
                            print("Error creating a file \(filePath) : \(writeError)")
                        }
                        
                    } else {
                        print("Error took place while downloading a file. Error description: %@", error?.localizedDescription as Any);
                    }
                }
                self.activityIndicatorStart()
                task.resume()
                
                if fileManager.fileExists(atPath: filePath.path) == true {
                    self.activityIndicatorStop()
                    self.checkFileNonRecordedList()
                }
            }
            
            alert.addTextField()
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated:false)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        // add actions
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
        
        // present an actionSheet...
        present(actionSheetController, animated: true, completion: nil)
    }
    
    // 리스트 체크 후 동기화
    func checkFileRecordedList() {
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsDirectory2 = documentsDirectory.appendingPathComponent("FolderList").appendingPathComponent(FileHeader)
        let fileRecorded = documentsDirectory2.appendingPathComponent("Recorded")
        var tmpfileRecordedList: [String] = []
        
        do{
            tmpfileRecordedList = try fileManager.contentsOfDirectory(atPath: fileRecorded.path)
        } catch {
            print("error")
        }
        self.fileRecordedList = tmpfileRecordedList
        self.tableView.reloadData()
    }
    
    // 리스트 체크 후 동기화
    func checkFileNonRecordedList() {
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsDirectory2 = documentsDirectory.appendingPathComponent("FolderList").appendingPathComponent(FileHeader)
        let fileNonRecorded = documentsDirectory2.appendingPathComponent("Non Recorded")
        var tmpfileNonRecordedList: [String] = []

            do{
                tmpfileNonRecordedList = try fileManager.contentsOfDirectory(atPath: fileNonRecorded.path)
            } catch {
                print("error")
            }
        
        self.fileNonRecordedList = tmpfileNonRecordedList
        self.tableView.reloadData()
       
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
    
    // activity controller 설정
    func activityIndicatorStart() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func activityIndicatorStop() {
        activityIndicator.stopAnimating()
    }
    
}
