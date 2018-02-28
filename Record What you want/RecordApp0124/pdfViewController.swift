//
//  pdfViewController.swift
//  asasasa11
//
//  Created by cscoi018 on 2018. 1. 22..
//  Copyright © 2018년 LTH. All rights reserved.
//

import UIKit
import PDFKit
import AVFoundation

class pdfViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate,
    SearchViewControllerDelegate, ThumbnailGridViewControllerDelegate{
    /* thumbNail */
    func thumbnailGridViewController(_ thumbnailGridViewController: ThumbnailGridViewController, didSelectPage page: PDFPage) {
        _ = navigationController?.popViewController(animated: false)
        pdfView2.go(to: page)
        // bookmark_show_or_hide()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController = segue.destination as? ThumbnailGridViewController {
            viewController.pdfDocument = pdfView2.document
            viewController.delegate = self
        }
    }
    ////////////////////////////////////////////////////////////
    
    // Search
    ////////////////////////////////////////////////////////////
 

    func searchViewController(_ searchViewController: SearchViewController, didSelectSearchResult selection: PDFSelection) {
        selection.color = .yellow
        pdfView2.currentSelection = selection
        pdfView2.go(to: selection)
        //bookmark_show_or_hide()
    }
    

    var searchNavigationController: UINavigationController?
    let pdfViewGestureRecognizer = PDFViewGestureRecognizer()
    
    
    @objc func showSearchView(_ sender: UIBarButtonItem) {
        if let searchNavigationController = self.searchNavigationController {
            present(searchNavigationController, animated: true, completion: nil)
        } else if let navigationController = storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? UINavigationController,
            let searchViewController = navigationController.topViewController as? SearchViewController {
            searchViewController.pdfDocument = pdfView2.document
            searchViewController.delegate = self
            present(navigationController, animated: true, completion: nil)
            
            searchNavigationController = navigationController
        }
    }
    ////////////////////////////////////////////////////////////
    
    
    
    // delegate (다른 클래스에 있는 변수들을 가져다 쓰기 위해 사용)
    // var delegate3: sideBarViewController?
    var delegate: revealViewController?
    
    // Outlet 변수들
    
    @IBOutlet weak var cur_page: UILabel!
    @IBOutlet weak var pdfView2: PDFView!
    @IBOutlet weak var thumbNail: PDFThumbnailView!
    @IBOutlet weak var recording: UIButton!
    @IBOutlet weak var lblRecordTime: UILabel!
    @IBOutlet weak var buttonStatus: UIButton!

    
    // 북마크, 녹음 시 음원 파일의 정보 담고 있는 변수들
    
    var playTimeFromBookmark: String = "INITIAL"
    var playTimeFromBookmarkforMP3: String = "00:00"

    var currentTime : String = ""
    
    var mp3List : [String] = [] // 녹음 후 생성되는 mp3 파일 리스트, sidebar에 Bookmark 추가할 때 사용!
    var mp3Name : String = ""
    
    var takeTimeList : [String] = []
    var usePageNumber : String = "" // pdf의 현재 페이지 받는 변수, BookmarkPage의 value 값
    var numberofBookmark : Int = 0

    var BookmarkPage : [String: String] = [:] // Arrays receive bookmark's positions , sidebar 에서 특정 북마크 누를 때, 북마크가 있던 페이지로 이동하게 해주는 sideToPage() 함수에서 사용

    var buttonArr : [ButtonInfo] = [] // buttonInfo 구조체 변수들을 담는 배열,
    
    // Record Variables

    var recordFile : URL!
    var audioRecorder : AVAudioRecorder!
    var recordCheck : Bool = false  // false : not recoring status
    let timeRecordSelector : Selector = #selector(pdfViewController.updateRecordTime)
    
    // Audio Variables
    
    var audioPlayer : AVAudioPlayer!
    var audioFile : URL?
    let MAX_VOLUME : Float = 10.0
    var progressTimer : Timer!
    let timePlayerSelector: Selector = #selector(pdfViewController.updatePlayTime)
    

    
    // toolbar Variables (툴바 UI 수정하자!)
    
    let toolbar: Toolbar = Toolbar()
    
    lazy var play: ToolbarItem = {
        let item: ToolbarItem = ToolbarItem(image:#imageLiteral(resourceName: "play"), target: self, action: #selector(playAudio))
        return item
    }()
    lazy var pause: ToolbarItem = {
        let item: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "pause"), target: self, action: #selector(pauseAudio))
        return item
    }()
    lazy var stop: ToolbarItem = {
        let item: ToolbarItem = ToolbarItem(image: #imageLiteral(resourceName: "stop"), target: self, action: #selector(stopAudio))
        return item
    }()
    lazy var lBlCurrentTime : ToolbarItem = {
        let item : ToolbarItem = ToolbarItem(title : "CurrentTime", target : nil, action : nil)
        return item
    }()
    lazy var lBlEndTime : ToolbarItem = {
        let item : ToolbarItem = ToolbarItem(title : "EndTime", target : nil, action : nil)
        return item
    }()
    
    var toolbarBottomConstraint: NSLayoutConstraint?

    
/********************************************************************************************************************/
    
    override func loadView() {
        hideItems()
        super.loadView()
        self.view.addSubview(toolbar)
        self.toolbarBottomConstraint = self.toolbar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        self.toolbarBottomConstraint?.isActive = true
        self.toolbar.alpha = 1.0
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // thumbNail 이동시 페이지 숫자 바뀌게 하는 코드
        NotificationCenter.default.addObserver(self, selector: #selector(pdfViewPageChanged(_:)), name: .PDFViewPageChanged, object: nil)
        pdfView2.addGestureRecognizer(pdfViewGestureRecognizer)
        // 18.2.27 추가
        
        makeDefaultFile()
        checkmp3List()
        initNav()
        initSideGesture()
        initPdfGesture()
        // init_thumbnail_gesture()
        
        setupPdfView() // extension
        

        let pdfName = "Human Respiratory"
        navigationItem.title = pdfName
        showPDF(pdfName: pdfName)

        checkPage()
        // var label : String? = pdfView2.currentPage
        
    }
    
    //***** Initialize Functions *****//
    
    func makeDefaultFile(){
        
        let fileManager = FileManager.default
        let documentsDirectory2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsDirectory3 = documentsDirectory2.appendingPathComponent("mp3List")
        recordFile = documentsDirectory3.appendingPathComponent("\(self.mp3Name).m4a")
        checkmp3List()
        
    }
    
    func checkmp3List() {
        let fileManager = FileManager.default
        let documentsDirectory2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let documentsDirectory = documentsDirectory2.appendingPathComponent("mp3List")
        
        var mp3: [String] = []
        
        do{
            mp3 = try fileManager.contentsOfDirectory(atPath: documentsDirectory.path)

        } catch {
            print("error")
        }
        self.mp3List = mp3
    }
    
    /////
    
    @IBOutlet weak var tableOfContentsButton: UIBarButtonItem!
    func initNav(){
        
        let backbutton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(sceneBack))
        
        let sharebutton = UIBarButtonItem(barButtonSystemItem: .action ,
                                          target: self,
                                          action: #selector(showShare) )
        
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Search"), style: .plain, target: self, action: #selector(showSearchView(_:)))
        /*
        let tableOfContentsButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Grid"), style : .plain, target: self,
                                                    action: #selector(showThumbNailGridView))
        */
        self.navigationItem.leftBarButtonItems = [backbutton, tableOfContentsButton]
        self.navigationItem.rightBarButtonItems = [sharebutton, searchButton]
    }
    /////
    
    @objc func showThumbNailGridView(/*_sender: UIBarButtonItem*/){
        
            }
    
    /////
    func initSideGesture(){
        let dragLeft = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(moveSide(_:)))
        dragLeft.edges = UIRectEdge.left
        self.view.addGestureRecognizer(dragLeft)
        
        let dragRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(moveSide))
        dragRight.direction = .left
        self.view.addGestureRecognizer(dragRight)
        
    }
    
    

    func initPdfGesture(){
        let SlideGestureDown = UISwipeGestureRecognizer(target: self, action:#selector(go_previous_page(_:)))
        let SlideGestureUp = UISwipeGestureRecognizer(target: self, action: #selector(go_next_page(_:)))
        
        //pdfView2.addGestureRecognizer(tapGesture)
        pdfView2.addGestureRecognizer(SlideGestureDown)
        pdfView2.addGestureRecognizer(SlideGestureUp)
        
        SlideGestureDown.direction = .down
        SlideGestureUp.direction = .up
       
        // initialize Touch Gesture
        pdfView2.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(make_bookmark(_:)))
       
        pdfView2.addGestureRecognizer(tapGesture)
        tapGesture.location(in: pdfView2)
    }
    

    
    
 
    
    //****************************************************************************************************//
    
    //***** Record Functions *****//
    
    func takeBookmarkTime () {
        let tmp = lblRecordTime.text
        self.takeTimeList.append(tmp!)
        print(self.takeTimeList)
    }
    

    @objc func updateRecordTime(){
        lblRecordTime.text = convertNSTimeInterval2String(audioRecorder.currentTime)
    }


    @IBAction func recordButton(_ sender: UIButton) {
        
        self.lblRecordTime.isHidden = false
        if recordCheck == false {
            do{
                let audioname = getDocumentsDirectory().appendingPathComponent("recording.m4a")
                
                let recordSettings = [
                    AVFormatIDKey : NSNumber(value: kAudioFormatAppleLossless as UInt32),
                    AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                    AVEncoderBitRateKey : 320000,
                    AVNumberOfChannelsKey : 2,
                    AVSampleRateKey : 44100.0] as [String : Any]
                
                //
                audioRecorder = try AVAudioRecorder(url : audioname, settings : recordSettings)
            } catch let error as NSError {
                print("Error-initRecord : \(error)")
            }
            
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            
            sender.setImage(#imageLiteral(resourceName: "recordAfter"), for: UIControlState())
            progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timeRecordSelector, userInfo: nil, repeats: true)
            recordCheck = true
        }else{
            audioRecorder.stop()
            progressTimer.invalidate()
            sender.setImage(#imageLiteral(resourceName: "recordBefore"), for: UIControlState())
            recordFinish(sender)
            recordCheck = false
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0].appendingPathComponent("mp3List")
        return documentsDirectory
    }
    
    @objc func recordFinish(_ sender: UIButton){
        let alert = UIAlertController(title: "Save Audio File as", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let okAction = UIAlertAction(title: "OK", style: .default){
            action -> Void in
            
            let textField = alert.textFields![0] as UITextField
            
            let mp3tmp = textField.text!
            self.mp3Name = mp3tmp
            
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let documentsDirectory2 = documentsDirectory.appendingPathComponent("mp3List")
            
            do {
                let originPath = documentsDirectory2.appendingPathComponent("recording.m4a")
                let destinationPath = documentsDirectory2.appendingPathComponent(self.mp3Name+".m4a")
                try FileManager.default.moveItem(at: originPath, to: destinationPath)
            } catch {
                print(error)
            }
            let timeStamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
            self.currentTime = String(describing: timeStamp)
            self.makeDefaultFile()
            self.initToolbar()
            self.initPlay()
            self.lblRecordTime.isHidden = true
        }
      
        
        alert.addTextField()
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated:false)
        self.lblRecordTime.isHidden = true
    }
    
    func initToolbar(){
        self.toolbar.maximumHeight = 150
        self.toolbar.setItems([self.play, self.pause, self.stop, self.lBlCurrentTime, self.lBlEndTime], animated: true)
        
        let fileManager = FileManager.default
        let documentsDirectory2 = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsDirectory = documentsDirectory2.appendingPathComponent("mp3List")
        audioFile = documentsDirectory.appendingPathComponent(self.mp3Name+".m4a")
        
    }
    
    // thumbNail 이동시 페이지 숫자 바뀌게 하는 코드
    @objc func pdfViewPageChanged(_ notification: Notification) {
        checkPage()
        bookmark_show_or_hide()
    }
 

    func checkPage(){
        
        if let currentPage = pdfView2.currentPage, let index = pdfView2.document?.index(for: currentPage)
            {
                cur_page.text = "Page " + "\(index + 1) " + " of " + "\(checkTotalPage())"
                cur_page.backgroundColor = UIColor.white
                cur_page.textAlignment = .right
                cur_page.textColor = UIColor.black
                self.usePageNumber = currentPage.label!
        } else {
            cur_page.text = nil
        }
    }
    
    func checkTotalPage () -> Int {
        return (pdfView2.document?.pageCount)!
    }
    // ***** Audio Functions ***** //
    
    func initPlay(){
        do{
            audioPlayer = try AVAudioPlayer(contentsOf : audioFile!)
        } catch let error as NSError {
            print("Error-initPlay : \(error)" )
        }
        
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        
        lBlEndTime.title = convertNSTimeInterval2String(audioPlayer.duration)
        lBlCurrentTime.title? = "00:00"
        
        self.pause.isEnabled = false
        self.stop.isEnabled = false

    }
    
    func initPlayBookmark(bookmark_number : Int){
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf : audioFile!)
        } catch let error as NSError {
            print("Error-initPlay : \(error)" )
        }
        
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
    
        lBlEndTime.title = convertNSTimeInterval2String(audioPlayer.duration)
        lBlCurrentTime.title? = self.takeTimeList[bookmark_number]
        
        self.pause.isEnabled = false
        self.stop.isEnabled = false
        
    }
    
    func parseDuration(timeString:String) -> TimeInterval {
        guard !timeString.isEmpty else {
            return 0
        }
        var interval:Double = 0
    
        let parts = timeString.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }
        return interval
    }
    
    func convertNSTimeInterval2String(_ time:TimeInterval) -> String {
        let min = Int(time/60)
        let sec = Int(time.truncatingRemainder(dividingBy : 60))
        let strTime = String(format: "%02d:%02d", min, sec)
        return strTime
        
    }

    @objc func updatePlayTime() {
        lBlCurrentTime.title = convertNSTimeInterval2String(audioPlayer.currentTime)
    }
    
    func setPlayButtons(_ play: Bool, pause : Bool , stop : Bool){
        self.play.isEnabled = play
        self.pause.isEnabled = pause
        self.stop.isEnabled = stop
    }
    
    
    @objc func playAudio(){
        
        //self.delegate3 = self.storyboard!.instantiateViewController(withIdentifier: "sw_rear") as? sideBarViewController
        audioPlayer.currentTime = parseDuration(timeString: self.playTimeFromBookmark)
        audioPlayer.delegate = self
        audioPlayer.play()
        setPlayButtons(false, pause: true, stop: true)
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timePlayerSelector, userInfo: nil, repeats: true)
    }
    
    @objc func pauseAudio(){
        audioPlayer.pause()
        setPlayButtons(true, pause: false, stop: true)
        
        
    }
    
    @objc func stopAudio() {
        audioPlayer.stop()
        audioPlayer.currentTime  = 0
        lBlCurrentTime.title = convertNSTimeInterval2String(0)
        setPlayButtons(true, pause: false, stop: false)
        progressTimer.invalidate()
        hideItems()
        self.buttonStatus.isHidden = false
        
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        progressTimer.invalidate()
        setPlayButtons(true, pause: false, stop: false)
        hideItems()
        self.buttonStatus.isHidden = false
    }
    
    // ***** toolbar functions ***** //
    
    func hideItems() {self.toolbar.isHidden = true}
    
    func showItems() {self.toolbar.isHidden = false}
    
    /********************************************************/
 
    
    
    /********************************************************/
    
   // ***** sidebar Functions ***** //

    @objc func moveSide(_ sender: Any) {
        if sender is UIScreenEdgePanGestureRecognizer {
            self.delegate?.openSideBar(nil)
        } else if sender is UISwipeGestureRecognizer {
            self.delegate?.closeSideBar(nil)
        }
    }
    
    @objc func sceneBack(_ sender: Any) {
        self.navigationController?.parent?.dismiss(animated: true, completion: nil)
    }
    
    @objc func showShare(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: ["text",#imageLiteral(resourceName: "camera")], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
   

    //***** make_bookmark, go_next_page, go_previous_page : Button gesture Action ***** //
    
    @objc func make_bookmark(_ gesture: UITapGestureRecognizer) {
        
        if self.buttonStatus.image(for: UIControlState()) == #imageLiteral(resourceName: "recordBefore"){
            return
        }else{
            let position = gesture.location(in: pdfView2)
            let nx = Int(position.x)
            let ny = Int(position.y)
            let button = UIButton()
            
            
            button.frame = CGRect(x: nx, y: ny + 50 , width: 20 , height: 20 )
            button.backgroundColor = UIColor.red.withAlphaComponent(0)
            button.setImage(UIImage(named : "bookmark2"), for: .normal)
            self.view.addSubview(button)

            self.numberofBookmark += 1
            let bookmark : String = "Bookmark " + "\(String(describing: numberofBookmark))"
            
            
            button.addTarget(self, action: #selector(bookmark_to_AudioPlayer), for : .touchUpInside)
            self.BookmarkPage[bookmark] = self.usePageNumber
            print("numberofBookmark : \(numberofBookmark)")
            print("Button : \(button)")
            
            
            let bookMarkButton = ButtonInfo(button: button, xpos : nx, ypos : ny, mark_number : numberofBookmark,  pageNum: Int((pdfView2.currentPage?.label)!)!)
            
            
            buttonArr.append(bookMarkButton)
            
            // 18.02.03 19:26 배열에 잘 저장되는 점 확인(문제 : 터치 통해 page 변경할 때만 pageNumber 가 배열에 올바르게 저장됨, thumbNail 통해 페이지 변경할 때도 pageNumber가 잘 바뀌어야 함!)
            takeBookmarkTime()
        }
       
    }
    @objc func bookmark_to_AudioPlayer(_ sender: UIButton){
        for component in buttonArr {
            if component.button == sender {
        
                playTimeFromBookmark = takeTimeList[component.mark_number - 1]
                lBlCurrentTime.title = playTimeFromBookmark
                showItems()
            }
        }

    }
    
    func bookmark_show_or_hide(){
        for component in buttonArr {
            if component.pageNum == Int((pdfView2.currentPage?.label)!){
                component.button.isHidden = false
            } else {
                component.button.isHidden = true
            }
        }
    }
    
    @objc func go_next_page(_ gesture: UISwipeGestureRecognizer) {
        
        gesture.direction = .up
        
        self.pdfView2.goToNextPage(gesture)
        pdfView2.canGoToNextPage()
        // bookmark_show_or_hide()
       
        checkPage()
    }
    
    @objc func go_previous_page(_ gesture: UISwipeGestureRecognizer) {
        
        
        gesture.direction = .down
        
        self.pdfView2.goToPreviousPage(gesture)
        pdfView2.canGoToPreviousPage()
        // bookmark_show_or_hide()
        
        checkPage()
       
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     // MARK: - Navigation
     
     
     */
    
}

extension pdfViewController {
    
    // MARK: - show
    
    func showPDF(pdfData: Data, usePageViewController: Bool = false) {
        pdfView2.usePageViewController(usePageViewController)
        pdfView2.document = PDFDocument(data: pdfData)
    }
    
    func showPDF(pdfUrl: URL, usePageViewController: Bool = false) {
        
        pdfView2.usePageViewController(usePageViewController)
        pdfView2.document = PDFDocument(url: pdfUrl)
    }
    
    /// PDFファイルのPATHを指定して、画面に表示する
    ///
    /// - Parameter pdfPath: PDFファイルのPATH
    func showPDF(pdfPath: String, usePageViewController: Bool = false) {
        pdfView2.backgroundColor = UIColor.gray
        if let fileHandle = FileHandle(forReadingAtPath: pdfPath) {
            let pdfData = fileHandle.readDataToEndOfFile()
            showPDF(pdfData: pdfData,
                    usePageViewController: usePageViewController)
        }
    }
    
    /// ResourcesのPDFファイル名を指定して、画面に表示する
    ///
    /// - Parameter pdfName: foo.pdfの場合 -> foo
    func showPDF(pdfName: String, usePageViewController: Bool = false) {
        pdfView2.backgroundColor = UIColor.gray
        if let pdfPath = Bundle.main.path(forResource: pdfName, ofType: "pdf") {
            showPDF(pdfPath: pdfPath,
                    usePageViewController: usePageViewController)
        }
    }
    
    // MARK: - configuration
    
    /// PDFViewの初期処理をする
    func setupPdfView() {
        
        
        // 初期表示が画面サイズにピッタリ収まるようにする
        pdfView2.autoScales = true
        
        
        // サムネイルのセットアップ
        setupPdfThumbnailView(layoutMode: .horizontal,
                            thumbnailSize: CGSize(width: 20, height: 28))
        
        // 余白を消す
        pdfView2.displaysPageBreaks = true
        
        // 余白を設定する
        pageBreakMargins(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        
        // 背景色を設定
        pdfView2.backgroundColor = UIColor.gray
        
        // スクロール方向に横向きを設定
        // pdfView.autoScalesがtrueで、スクロール方向を横向きにすると、
        // 小さく表示されてしまう
        
        displayDirection(direction: .horizontal)
        displayMode(mode: .singlePage)
        displaysAsBook(false)
    }
    
    /// 任意の余白を設定する
    func pageBreakMargins(top: CGFloat,
                          left: CGFloat,
                          bottom: CGFloat,
                          right: CGFloat) {
        pdfView2.displaysPageBreaks = true
        pdfView2.pageBreakMargins = UIEdgeInsetsMake(top, left, bottom, right)
    }
    
    /// スクロールの方向を設定する
    ///
    /// - Parameter direction: PDFDisplayDirection
    func displayDirection(direction: PDFDisplayDirection) {
        pdfView2.displayDirection = direction
    }
    
    /// 表示モードを設定する
    ///
    /// - Parameter mode: PDFDisplayMode
    func displayMode(mode: PDFDisplayMode = .singlePage) {
        pdfView2.displayMode = mode
    }
    
    /// 見開きの時に最初のページを表紙として使用する
    ///
    /// 見開き（.twoUpContinuousまたは.twoUp）の場合のみ有効
    ///
    /// - Parameter asBook: true: 1ページ目を表紙とする, false: 表紙としない
    func displaysAsBook(_ asBook: Bool) {
        pdfView2.displaysAsBook = asBook
    }
    
    // MARK: - thumbnail
    /// PDFViewの初期処理をする
    func setupPdfThumbnailView(layoutMode: PDFThumbnailLayoutMode = .horizontal,
                               backgroundColor: UIColor = .lightGray,
                               thumbnailSize: CGSize = CGSize(width: 2.0, height: 2.0)) {
        
        thumbNail.pdfView = pdfView2
        thumbNail.layoutMode = layoutMode
        thumbNail.backgroundColor = backgroundColor
        thumbNail.thumbnailSize = thumbnailSize
        
        
    }
 
    // MARK: - password
    
    func unlockPassword(password: String, document: PDFDocument) {
        let unlocked = document.unlock(withPassword: password)
        if unlocked {
            pdfView2.document = document
        }
    }
    
    // MARK: - file operation
    
    /// ページ入れ替え
    func exchangePage(thePage: Int, otherPage: Int, document: PDFDocument) {
        document.exchangePage(at: thePage, withPageAt: otherPage)
        pdfView2.document = document
    }
    

    /// ページ削除
    func removePage(thePage: Int, document: PDFDocument) {
        document.removePage(at: thePage)
    }
    
    /// PATHを指定して、ファイル保存
    func saveDocument(to path: String, document: PDFDocument) {
        document.write(toFile: path)
    }
    
    /// URLを指定して、ファイル保存
    func saveDocument(to url: URL, document: PDFDocument) {
        document.write(to: url)
    }
    
    // MARK: - search
    func find(text: String, document: PDFDocument, delegate: PDFDocumentDelegate) {
        document.delegate = delegate
        document.beginFindString(text, withOptions: .caseInsensitive)
        pdfView2.document = document
      
    }
}

extension pdfViewController: PDFDocumentDelegate {
    func didMatchString(_ instance: PDFSelection) {
        
        instance.color = .blue
        
                //let marker = UIView(frame: instance.bounds(for: pdfView2.currentPage!))
                //marker.backgroundColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
                //marker.alpha = 0.5
                //pdfView2.addSubview(marker)
    }
}


class PDFViewGestureRecognizer: UIGestureRecognizer {
    var isTracking = false
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = true
    }
    
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = false
    }
    
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = false
    }
}








