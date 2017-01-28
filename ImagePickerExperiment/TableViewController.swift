//
//  TableViewController.swift
//  ImagePickerExperiment
//
//  Created by iamqjin on 2017. 1. 26..
//  Copyright © 2017년 Udacity. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UITableViewController {
    

    var memes: [Meme]!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate  //공유되는 정보 델리게이트
    
    @IBOutlet weak var infoLabel: UILabel! //설명 라벨
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.memes = appDelegate.memes
        self.tableView.reloadData() //뷰가 다시 보여질때 데이터 리로드
        
        //정보 라벨을 0개 이상일 경우 사라지게함
        if self.memes.count > 0 {
            infoLabel.isHidden = true
        } else {
            infoLabel.isHidden = false
        }
        
    }
    
    //에디트 창 띄우기
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editVC = self.storyboard!.instantiateViewController(withIdentifier: "editVC") as! EditViewController
        
        editVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        editVC.indexNumber = indexPath.row
        self.present(editVC, animated: true, completion: nil)
    }
    
    // 테이블 설정
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.appDelegate.memes.count

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableViewCell") as! MemeTableViewCell
        
//        let meme = self.memes[indexPath.row]
        
        cell.memeImage.image = appDelegate.memes[indexPath.row].memedImage
        cell.memeLabel.text = appDelegate.memes[indexPath.row].topText! + appDelegate.memes[indexPath.row].bottomText!

        return cell
    }
    
    //에디트 모드
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //스와이프로 데이터 삭제
        if editingStyle == .delete {
            appDelegate.memes.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        self.tableView.reloadData()
    }

}
