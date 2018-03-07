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
    var PDFFileList : [String] = []
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    

    // Folder scene 에서 받아오는 테이블 뷰의 헤더
    @IBOutlet weak var folderName: UINavigationItem!
    var FileHeader: String? = ""
    

    override func viewWillAppear(_ animated: Bool) {
        if folderName != nil {
        // 화면 시작 전 file scene의 헤더 호출
            folderName.title = FileHeader
        }
        
        // 화면 시작 전 기존 파일들 리스트 동기화
        self.checkPDFFileList()
   
    }
    
    // 화면 전환 전 appDelegate 로 데이터 동기화
    override func viewWillDisappear(_ animated: Bool) {
        appDelegate.PDFFileList = self.PDFFileList
    }

    // 선택한 pdf 이름 넘기기
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! revealViewController
        let cell = sender as! UITableViewCell
        let indexPath = self.tableView.indexPath(for: cell)!
        let sample1 = PDFFileList[indexPath.row]
        let sample2 = sample1.index(sample1.endIndex, offsetBy: -4)
        let selectedPDF = sample1[..<sample2]
        nextVC.eachPDFName = String(selectedPDF)
        nextVC.eachFolderName = self.FileHeader!
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableview delegate, datasource 사용
        tableView.delegate = self
        tableView.dataSource = self
        
        self.checkPDFFileList()

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
        return 1
    }
    
    // 테이블 뷰 셀 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PDFFileList.count
       
    }
    
    // 테이블 뷰 셀 기본설정 및 타이틀 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell2", for: indexPath)

            cell.imageView?.image = UIImage(named:"pdf")
            cell.textLabel?.text = PDFFileList[indexPath.row]
    
            return cell
    }
    
    // 테이블 뷰 섹션의 헤더 타이틀 설정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return "File List"
    }
    
    // 테이블 뷰 셀 edit 설정
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // 테이블 뷰 edit(Delete) 기능
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = PDFFileList.remove(at: indexPath.row)
            let fileManager = FileManager()
            let documentsDirectory2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let documentsDirectory = documentsDirectory2.appendingPathComponent("FolderList").appendingPathComponent(FileHeader!).appendingPathComponent(FileHeader! + "_pdf")
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
        
   
        let saveChanges = self.PDFFileList[fromIndexPath.row]
        let removeItem = self.PDFFileList.remove(at: fromIndexPath.row)
        self.PDFFileList.insert(saveChanges, at : to.row)
        let fileManager = FileManager()
        let documentsDirectory2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsDirectory = documentsDirectory2.appendingPathComponent("FolderList").appendingPathComponent(FileHeader!).appendingPathComponent(FileHeader! + "_pdf")

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
    
    

    // 테이블 뷰 셀 edit 설정
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // plus 버튼 클릭 시 web browser , url 을 이용한 파일 로드 (하단의 downloadFileFromURL 함수 사용)
    
    @IBAction func webCallBtn(_ sender: UIButton) {
        self.downloadFileFromURL() {
            self.activityIndicatorStop()
            self.checkPDFFileList()
        }
    }
    
    
    // 리스트 체크 후 동기화
    func checkPDFFileList() {
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let PDFFileList = documentsDirectory.appendingPathComponent("FolderList").appendingPathComponent(FileHeader!).appendingPathComponent(FileHeader! + "_pdf")
        var tmpfileList: [String] = []

            do{
                tmpfileList = try fileManager.contentsOfDirectory(atPath: PDFFileList.path)
            } catch {
                print("error")
            }
        
        self.PDFFileList = tmpfileList
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
       
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
    
    // activity controller 시작 설정
    func activityIndicatorStart() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    // activity controller 종료 설정
    func activityIndicatorStop() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
        })
    }
    
    // URL 을 이용한 PDF 파일 다운로드
    func downloadFileFromURL(completion: @escaping () -> ()) {
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
                let filePath = filePath2.appendingPathComponent("FolderList").appendingPathComponent(self.FileHeader!).appendingPathComponent(self.FileHeader! + "_pdf").appendingPathComponent(lastWord!)
                
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
                    completion()
                }
                self.activityIndicatorStart()
                task.resume()
      
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
}
