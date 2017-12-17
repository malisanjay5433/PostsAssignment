//
//  FirstViewController.swift
//  FollowChats
//
//  Created by Sanjay Mali on 16/12/17.
//  Copyright © 2017 Sanjay Mali. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KRProgressHUD
class PostsTableViewController: UITableViewController,UISearchBarDelegate {
    var post_Arr = [Posts_new]()
    var userinfo:LoginModel?
    var videoUrl:String?
    @IBOutlet var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        DispatchQueue.main.async(execute: { () -> Void in
            self.downloadJSON()
        })
    }
    private func downloadJSON(){
        KRProgressHUD.show()
        let jsonDict = ["body": ["email":"clicktesting4@gmail.com", "password":"1234567"]]
        let api = "http://dev.followchats.com/api/authenticate/"
        DataManager.getJSON(api,param:jsonDict) { (data,error) in
            guard let data = data else { return
            }
            let decoder = JSONDecoder()
            do {
                let json = try decoder.decode(LoginModel.self, from: data)
                self.userinfo = json
                self.downloadPosts()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    private func downloadPosts(){
        let jsonDict = ["body": ["x-access-token":userinfo?.token]]
        let api = "http://dev.followchats.com/api/user/post/get"
        DataManager.getJSON(api,param:jsonDict as! [String : [String : String]]) { (data,error) in
            guard let data = data else { return
            }
            let decoder = JSONDecoder()
            do {
                let json = try decoder.decode(PostModel.self, from: data)
                self.post_Arr = json.body.posts_new
            }catch{
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.navigationItem.title = "\(self.post_Arr.count) Posts"
                KRProgressHUD.dismiss()
            }
        }
    }
}

extension PostsTableViewController{
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.post_Arr.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userPost = self.post_Arr[indexPath.row]
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImagePostCell
        if userPost.type == "text"{
            cell2.discrptionLbl.text = userPost.description
            cell2.imageHiehgtConstraint.constant = 0
        }else{
            if (userPost.thumbnail_url != nil) && userPost.thumbnail_url != ""{
                cell2.imageHiehgtConstraint.constant = 166
                let url = URL(string:userPost.thumbnail_url!)
                cell2.backView.kf.setImage(with:url, placeholder:UIImage(named:"placeholder"), options:nil, progressBlock: nil, completionHandler: nil)
                cell2.discrptionLbl.text = userPost.description
            }else{
                cell2.imageHiehgtConstraint.constant = 0
            }
            cell2.discrptionLbl.text = userPost.description
        }
        return cell2
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.videoUrl = post_Arr[indexPath.row].media_url
        let indexPath = tableView.indexPathForSelectedRow
        let cell = tableView.cellForRow(at: indexPath!)! as! ImagePostCell
        if cell.vframe?.isPlaying == true || self.videoUrl == "" || self.videoUrl == nil {
            return
        }
        if self.videoUrl != ""{
            let url  = URL(string:videoUrl!)
            cell.vframe?.alpha = 1
            cell.vframe?.videoUrl = url
//            cell.vframe?.shouldAutoplay = true
            cell.vframe?.shouldAutoRepeat = true
            cell.vframe?.showsCustomControls = false
//            cell.vframe?.isMuted = true
            cell.vframe?.isPlaying  = true
        }else{
            print("No ")
        }
    }
    @IBAction func indexChanged(_ sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            print("First Segment Selected")
            self.sortText()
        case 1:
            print ("Second Segment Selected")
            self.sortImageOrVideo()
        default:
            break
        }
    }
    func sortText() { // should probably be called sort and not filter
        let data = post_Arr.filter { $0.type == "Text" }
        self.post_Arr = data
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func sortImageOrVideo() { // should probably be called sort and not filter
        let data = post_Arr.filter { $0.type == "Video" || $0.type == "image"}
        self.post_Arr = data
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

