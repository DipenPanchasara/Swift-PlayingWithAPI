//
//  ViewController.swift
//  Swift-PlayingWithAPI
//
//  Created by Dipen Panchasara on 07/06/16.
//  Copyright © 2016 Company Name. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    let ReuseIdentifierPostCell = "PostCell"
    
    var sessionConfiguration:NSURLSessionConfiguration!
    var session:NSURLSession!
    
    var arrPosts = NSMutableArray()
    
    var cache:NSCache!
    
    @IBOutlet weak var tableView: UITableView!
    var indicator:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.sessionConfiguration.timeoutIntervalForResource = 60
        self.sessionConfiguration.timeoutIntervalForResource = 120
        self.sessionConfiguration.requestCachePolicy = .ReloadIgnoringLocalAndRemoteCacheData
        
        self.session = NSURLSession(configuration: sessionConfiguration)
        
        self.cache = NSCache()
        
        self.title = "Posts"
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60
        
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.indicator.hidesWhenStopped = true
        
        let itemIndicator:UIBarButtonItem = UIBarButtonItem(customView: indicator)
        self.navigationItem.setRightBarButtonItem(itemIndicator, animated: true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // *** Get Data from API ***
        customRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getPostsTypeA()
    {
        Alamofire.request(.GET, "http://jsonplaceholder.typicode.com/posts", parameters: nil)
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response

                print(response.result)   // result of response serialization
                
                let json = JSON(data: response.data!)
                
                print(json[0]["title"])
                
                dispatch_async(dispatch_get_main_queue())
                {
                    self.tableView.reloadData()
                }
                
        }
    }
    
    func getPostsTypeB()
    {
        indicator.startAnimating()
        
        Alamofire.request(.GET, "http://jsonplaceholder.typicode.com/posts")
            .validate()
            .responseJSON{ response in
                self.indicator.stopAnimating()
                switch response.result
                {
                    case .Success:
                        
                        let jsonResponse = JSON(data: response.data!)
                        
                        
                        if jsonResponse.count > 0
                        {
                            self.arrPosts.addObjectsFromArray(jsonResponse.arrayObject!)
                        }
                        
                        dispatch_async(dispatch_get_main_queue())
                        {
                            self.tableView.reloadData()
                        }
                    
                    case .Failure:
                        print(response.debugDescription)
                }
        }
    }
    
    func customRequest()
    {
        self.indicator.startAnimating()
        
        let requestURLString = "http://jsonplaceholder.typicode.com/posts"
        let request:NSURLRequest = NSURLRequest(URL: NSURL(string: requestURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!)
        
        let task = self.session.dataTaskWithRequest(request) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue())
            {
                self.indicator.stopAnimating()
            }
            
            if let httpResponse = response as? NSHTTPURLResponse {
                switch httpResponse.statusCode
                {
                    case 200:
                        
                        let jsonResponse = JSON(data: data!)
                        if jsonResponse.count > 0
                        {
                            self.arrPosts.addObjectsFromArray(jsonResponse.arrayObject!)
                        }
                        
                        dispatch_async(dispatch_get_main_queue())
                        {
                            self.tableView.reloadData()
                        }
                        
                        print("Successful response.")

                    default:
                        print("Error in request [\(request.URLRequest.URL?.absoluteString)]: \(error?.localizedDescription)")
                }
            }
        }
        
        task.resume()
        print("TaskId : \(task.taskIdentifier)")
    }

}

extension ViewController: UITableViewDelegate,UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.arrPosts.count > 0
        {
            return self.arrPosts.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifierPostCell, forIndexPath: indexPath) as! PostTableViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: PostTableViewCell, atIndexPath indexPath: NSIndexPath)
    {
        // Fetch User
        let post = self.arrPosts[indexPath.row]
        
        // Update Cell
        if let postId = post["id"]!, postTitle = post["title"], postBody = post["body"]
        {
            print("id - \(postId)")
            cell.lblId.text = NSString(format: "%d",(postId as? Int)!) as String
            cell.lblTitle.text = postTitle as? String
            cell.lblBody.text = postBody as? String
        }
    }
}

