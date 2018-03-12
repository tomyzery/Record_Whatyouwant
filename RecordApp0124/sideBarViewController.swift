//
//  sideBarViewController.swift
//  RecordApp0124
//
//  Created by cscoi018 on 2018. 1. 24..
//  Copyright © 2018년 seok. All rights reserved.
//

import UIKit

class sideBarViewController: UITableViewController {
    
    
    var delegate: revealViewController?
    var delegate2: pdfViewController?
    var selectedMp3Name : String = ""

    var takeTime : String = ""
    
    var listAll : [String] = []
    var listBookmark : [String] = []

    var tmp_listBookmark : [String] = []
    var tmp_buttontitle : [String] = []
    var listBookmarkFinal : [String] = []
    var buttontitleFinal : [String] = []
 
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            func sideToPage() {
                if indexPath.section == 1 {
                /*
                var temp = ([String](delegate2!.BookmarkPage.keys)).sorted()
                let temp2 = delegate2?.BookmarkPage[temp[indexPath.row]]
                */
                
                    if delegate2?.buttonArr == nil {
                        return
                    }else{
                        let want_page = delegate2?.buttonArr[indexPath.row].pageNum
                        var cur_page = Int((delegate2?.pdfView2.currentPage?.label)!)!
                        while cur_page != want_page {
                            if cur_page > want_page! {
                                delegate2?.pdfView2.goToPreviousPage(delegate2?.pdfView2)
                                cur_page -= 1
                            } else if cur_page < want_page!{
                                delegate2?.pdfView2.goToNextPage(delegate2?.pdfView2)
                                cur_page += 1
                            }
                        }
                    }
                
                    delegate2?.pageNumberLabel.text = (delegate2?.pdfView2.currentPage?.label)! + "/" + "\(delegate2?.checkTotalPage() ?? 34)"
            }
                ////////////////////////////////////////////
        
                ////////////////////////////////////////////
            
        }
       
        if indexPath.section == 1 {
            self.takeTime = (delegate2?.buttonArr[indexPath.row].time)!
        } else {
        self.takeTime = "00:00"
        }
        
        print("sidebar 페이지에서 받은 takeTime:\(self.takeTime)")
        
        self.delegate?.closeSideBar(nil)
        
        //buttonStatus = true
        
        self.delegate2?.showItems()
        
        self.delegate2?.buttonStatus.isHidden = true
        
        sideToPage()
        
        if indexPath.section == 0 {
            let testtest = delegate2!.mp3List[indexPath.row]
            self.selectedMp3Name = testtest
            print(self.selectedMp3Name)
            audioinfo.selected = self.selectedMp3Name
            delegate2?.initToolbar()
            delegate2?.initPlay()
            delegate2!.playTimeFromBookmark = "00:00"
        } else {
            
            delegate2?.initPlayBookmark(bookmark_number: indexPath.row)
            delegate2!.playTimeFromBookmark = self.takeTime
        }
        
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //titles.append(String(describing: delegate2?.numberofBookmark))
        
        let bookMarkLIst = UILabel()
        bookMarkLIst.frame = CGRect(x:10, y:30, width: self.view.frame.width, height: 30)
        bookMarkLIst.text = "Audio & Bookmark List"
        bookMarkLIst.textColor = UIColor.white
        bookMarkLIst.font = UIFont.boldSystemFont(ofSize: 20)
        
        let v = UIView()
        v.frame = CGRect(x:0 , y:0 , width:self.view.frame.width, height: 70)
        v.backgroundColor = UIColor.init(red: 54/255, green: 156/255, blue: 255/255, alpha: 1.0)
        v.addSubview(bookMarkLIst)
        
        self.tableView.tableHeaderView = v
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // buttontitleFinal 은 viewdidload에 올리자
        for i in 0 ..< delegate2!.buttonArr.count {
            self.tmp_buttontitle.append(delegate2!.buttonArr[i].mp3title)
            self.tmp_buttontitle[i].removeLast(4)
        }
        buttontitleFinal = tmp_buttontitle

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return delegate2!.mp3List.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return delegate2!.mp3List.count         // mp3 파일에 맞게 수정해라!!!!!!
        } else {
            return delegate2!.buttonArr.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let id = "menucell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default , reuseIdentifier: id)
        
        
        if indexPath.section == 0 {
            cell.textLabel?.text = delegate2!.mp3List[indexPath.row]
            cell.detailTextLabel?.text = delegate2!.currentTime
            cell.imageView?.image = #imageLiteral(resourceName: "mp3")
            
      
            
        } else {
            
       
            self.tmp_listBookmark = self.listBookmark
            
            
            for i in 0 ..< self.tmp_listBookmark.count {
                tmp_listBookmark[i].removeLast(14)
                self.listBookmarkFinal.append(tmp_listBookmark[i])
            }
            listBookmarkFinal = tmp_listBookmark    // 여기까지 해결
            
            
            /*
            for i in 0 ..< self.tmp_buttontitle.count {
                //tmp_buttontitle[i].removeLast(4)
                self.buttontitleFinal.append(tmp_buttontitle[i])
            }
            */
            
            // buttontitleFinal = [111, 222, 222, 333, 333, 333] // button 이 찍힌 음원 파일의 리스트
            // listBookmarkFinal = [333, DS_S, 111, 222]    // list Header
            
            //override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
            
            for i in 0 ..< self.buttontitleFinal.count {
                for j in 0 ..< self.listBookmarkFinal.count {
                    if self.buttontitleFinal[i] == self.listBookmarkFinal[j] {
            
            
                        
            cell.textLabel?.text = String(describing: delegate2!.buttonArr[indexPath.row].mark_number)
            cell.detailTextLabel?.text = "page :" + String(describing: delegate2!.buttonArr[indexPath.row].pageNum)
                + "   at : " + (delegate2?.buttonArr[indexPath.row].time)!
            cell.imageView?.image = UIImage(named: "sidebarBookmarkIcon")
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
            
                        }
                    }
                }
            
        }
            
        return cell
    
    }
        
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .delete
        {
            /*
            let tempBook = [String](delegate2!.BookmarkPage.keys) // 위 함수랑 동일하게 변수 생성하고 진행했습니다.
            var tempBookKey = tempBook.sorted()
            */
            
            // tempBookKey.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
  
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "Audio List"
        } else {
            for i in 1 ..< delegate2!.mp3List.count {
                if section == i {
                    if listAll.contains((delegate2?.mp3List[i - 1])! + " Bookmark List") == false {
                        listAll.append((delegate2?.mp3List[i - 1])! + " Bookmark List")
                    }
                    listAll.append((delegate2?.mp3List[i - 1])! + " Bookmark List")
                    return (delegate2?.mp3List[i - 1])! + " Bookmark List"
                }
            }
        }
        
        listAll.append(delegate2!.mp3List[delegate2!.mp3List.count - 1] + " Bookmark List")

        // 중복 원소 제거 code
        var listBookmark : [String] = []
        for i in 0 ..< listAll.count {
            if listBookmark.contains(listAll[i]) == false {
                listBookmark.append(listAll[i])
            }
        }
        self.listBookmark = listBookmark
        
        return delegate2!.mp3List[delegate2!.mp3List.count - 1] + " Bookmark List"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("리스트는 뭐냐 :\(listAll)")
        print("리스트는 뭐냐 :\(listBookmark)")
        print("tmp_listBookmark : \(tmp_listBookmark)")
        print("listBookmarkFinal : \(listBookmarkFinal)")
        print("tmp_buttontitle : \(tmp_buttontitle)")
        print("buttontitleFinal : \(buttontitleFinal)")
        print("buttonArr : \(delegate2!.buttonArr)")
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
 

}
