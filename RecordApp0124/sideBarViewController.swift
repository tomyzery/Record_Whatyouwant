//
//  sideBarViewController.swift
//  RecordApp0124
//
//  Created by cscoi018 on 2018. 1. 24..
//  Copyright © 2018년 seok. All rights reserved.
//

// 북마크 섹션별로 분류하는 방법 참고 URL---------------------------------------------------------------------------------
// https://stackoverflow.com/questions/38520771/how-to-add-rows-to-specific-section-in-tableview-with-dictionary
// https://stackoverflow.com/questions/29579554/how-do-i-append-a-tableviewcell-to-a-specific-section-in-swift
// --------------------------------------------------------------------------------------------------------------

import UIKit

class sideBarViewController: UITableViewController {
    
    
    var delegate: revealViewController?
    var delegate2: pdfViewController?
    var selectedMp3Name : String = ""

    var takeTime : String = ""
    /////
    var listAll : [String] = []
    var listBookmark : [String] = []
    /////

    var tmp_buttontitle : [String] = []
    var buttontitleFinal : [String] = []
    
    //
    var mp3name_buttontitle : Dictionary<String, [String]> = [:]
    var mp3name_startTime : Dictionary<String, [String]> = [:]
    var mp3name_pageNum : Dictionary<String, [Int]> = [:]
    var mp3name_markNumber : Dictionary<String, [Int]> = [:]
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var sectionString_startTIme : [[String]] = []
        var sectionString_pageNum : [[Int]] = []
        
        
        
        for component in mp3name_startTime.keys.sorted() { // key는 mp3name_startTIme, mp3name_pageNum 모두 동일
            sectionString_pageNum.append(mp3name_pageNum[component]!)
            sectionString_startTIme.append(mp3name_startTime[component]!)
        }
        
        
            func sideToPage() {
                if indexPath.section != 0 {
        
                    if delegate2?.buttonArr != nil {
                        let want_page = sectionString_pageNum[indexPath.section - 1][indexPath.row]
                        var cur_page = Int((delegate2?.pdfView2.currentPage?.label)!)!
                        while cur_page != want_page {
                            if cur_page > want_page {
                                delegate2?.pdfView2.goToPreviousPage(delegate2?.pdfView2)
                                cur_page -= 1
                            } else if cur_page < want_page{
                                delegate2?.pdfView2.goToNextPage(delegate2?.pdfView2)
                                cur_page += 1
                            }
                        }
                    }
                    delegate2?.pageNumberLabel.text = (delegate2?.pdfView2.currentPage?.label)! + "/" + "\(delegate2?.checkTotalPage() ?? 34)"
            }
     
        }
       
        if indexPath.section != 0 {
            self.takeTime = sectionString_startTIme[indexPath.section - 1][indexPath.row]
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
            audioinfo.selected = self.selectedMp3Name
            delegate2?.initToolbar()
            delegate2?.initPlay()
            delegate2!.playTimeFromBookmark = "00:00"
        } else {
            let sectionString = Array(mp3name_buttontitle.keys).sorted()[indexPath.section - 1]
           
            audioinfo.selected = sectionString
            delegate2?.initToolbar()
            delegate2?.initPlayBookmark(bookmark_number: indexPath.row)
            delegate2?.lBlCurrentTime.title = sectionString_startTIme[indexPath.section - 1][indexPath.row]
            delegate2!.playTimeFromBookmark = self.takeTime
            
        }
        
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0 ..< delegate2!.buttonArr.count {
            self.tmp_buttontitle.append(delegate2!.buttonArr[i].mp3title)
            self.tmp_buttontitle[i].removeLast(4)
        }
        
        buttontitleFinal = tmp_buttontitle
        
        // mp3List의 첫번째 원소가 ".DS_S" 이므로 제거
        //if delegate2?.mp3List.count != 0 {
        //   delegate2?.mp3List.remove(at: 0)
        //}
        
        // print("엠피쓰리 리스트는 뭘까요 :  \(delegate2?.mp3List)")
        
        // Dictionary 만들기
        for mp3name in (delegate2?.mp3List)! {
            var values : [String] = []
            for buttontitle in buttontitleFinal {
                if buttontitle == mp3name {
                    // 이름 같을 때마다 values에 값 추가
                    values.append(buttontitle)
                }
                mp3name_buttontitle[mp3name] = values
            }
        }
        // 추가 이유 : mp3_buttontitle에 의미없는 이 값을 추가해야, numnberofSection를 mp3 파일 갯수로 지정할 수 있음
        // (파일이름이 영어일때) zzzzzzzzz : sectionString을 sorting했을 때 무조건 마지막으로 들어감 -> 화면에서는 짤림 -> ok
        mp3name_buttontitle["zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"] = [""]

        for mp3name in (delegate2?.mp3List)! {
            var values : [String] = []
            var values2 : [Int] = []
            var values3 : [Int] = []
            for component in (delegate2?.buttonArr)! {
                if mp3name + ".m4a" == component.mp3title {
                    values.append(component.time)
                    values2.append(component.pageNum)
                    values3.append(component.mark_number)
                }
                mp3name_startTime[mp3name] = values
                mp3name_pageNum[mp3name] = values2
                mp3name_markNumber[mp3name] = values3
            }
        }
        //mp3name_startTime["zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"] = [""]
        //mp3name_pageNum["zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"] = [9999999999]
        
        print("엠피쓰리이름 - 시작 시간 : \(mp3name_startTime)")
        print("엠피쓰리이름 - 페이지 숫자 : \(mp3name_pageNum)")
        print("엠피쓰리이름 - 마크 넘버 : \(mp3name_markNumber)")
        
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

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return mp3name_buttontitle.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("엠피쓰리,버튼이름 : \(mp3name_buttontitle)")
        print("섹션스트링은 : \(Array(mp3name_buttontitle.keys))")

        if section == 0 {
            return delegate2!.mp3List.count      // mp3 파일에 맞게 수정해라!!!!!!
        } else {
            
            let sectionString = Array(mp3name_buttontitle.keys).sorted()[section - 1]
            
            return mp3name_buttontitle[sectionString]!.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let id = "menucell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default , reuseIdentifier: id)
        
        var sectionString_startTIme : [[String]] = []
        var sectionString_pageNum : [[Int]] = []
        var sectionString_markNum : [[Int]] = []
        
        
        for component in mp3name_startTime.keys.sorted() { // key는 mp3name_startTIme, mp3name_pageNum 모두 동일
            sectionString_startTIme.append(mp3name_startTime[component]!)
            sectionString_pageNum.append(mp3name_pageNum[component]!)
            sectionString_markNum.append(mp3name_markNumber[component]!)
        }
        
        
    
        //let sectionString_startTIme = Array(mp3name_startTime.values)
        //let sectionString_pageNum = Array(mp3name_pageNum.values)

        if indexPath.section == 0 {
            cell.textLabel?.text = delegate2!.mp3List[indexPath.row]
            cell.detailTextLabel?.text = delegate2!.currentTime
            cell.imageView?.image = #imageLiteral(resourceName: "mp3")

        } else {
            //
                cell.textLabel?.text = String(describing: sectionString_markNum[indexPath.section - 1][indexPath.row])
                cell.detailTextLabel?.text = "page :" + String(sectionString_pageNum[indexPath.section - 1][indexPath.row]) + "   at : "  + sectionString_startTIme[indexPath.section - 1][indexPath.row]
                cell.imageView?.image = UIImage(named: "sidebarBookmarkIcon")
                cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
            }
            
            
  
        print("buttonArr 의 갯수 : \(delegate2!.buttonArr.count)")
        
        
        print("sectionString_startTIme :\(sectionString_startTIme)")
        print("sectionString_pageNum :\(sectionString_pageNum)")
        
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
        
        var header_title : String?

        if section == 0 {
            header_title = "Audio List"
        } else {
            
            let tmp2_sectionString = Array(mp3name_buttontitle.keys)
            var tmp1_sectionString = tmp2_sectionString.sorted {$0 < $1}

            let sectionString = tmp1_sectionString[section - 1]
       
            header_title = sectionString + " Bookmark List"
            
        }
        
        print("헤더 타이틀은 :  \(header_title)")
        return header_title
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("리스트는 뭐냐 :\(listAll)")
        print("리스트는 뭐냐 :\(listBookmark)")
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
