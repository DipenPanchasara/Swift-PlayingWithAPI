//
//  PhotosViewController.swift
//  Swift-PlayingWithAPI
//
//  Created by Dipen Panchasara on 07/06/16.
//  Copyright © 2016 Company Name. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PhotosViewController: UIViewController {

    let ReuseIdentifierPostCell = "PhotoCell"
    
    var sessionConfiguration:NSURLSessionConfiguration!
    var session:NSURLSession!
    
    var arrPosts = NSMutableArray()
    var dictDownloadTracking = NSMutableDictionary()
    var cache:NSCache!
    
    @IBOutlet weak var tableView: UITableView!
    var indicator:UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.sessionConfiguration.timeoutIntervalForResource = 60
        self.sessionConfiguration.timeoutIntervalForResource = 120
        self.sessionConfiguration.requestCachePolicy = .ReloadIgnoringLocalAndRemoteCacheData
        
        self.session = NSURLSession(configuration: sessionConfiguration)
        
        self.dictDownloadTracking = NSMutableDictionary()
        self.cache = NSCache()
        
        self.title = "Photos"
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60
        
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.indicator.hidesWhenStopped = true
        
        let itemIndicator:UIBarButtonItem = UIBarButtonItem(customView: indicator)
        self.navigationItem.setRightBarButtonItem(itemIndicator, animated: true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        customRequest()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func customRequest()
    {
        // *** start indicator animation ***
        self.indicator.startAnimating()
        
        // *** init request
        let requestURLString = "http://jsonplaceholder.typicode.com/photos"
        
        // *** generate request using URL by adding escape characters ***
        let request:NSURLRequest = NSURLRequest(URL: NSURL(string: requestURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!)
        
        // *** create NSURLSessionTask for API call ***
        let task = self.session.dataTaskWithRequest(request) { (data, response, error) in
            
            // *** stop indicator animation on response using main queue ***
            dispatch_async(dispatch_get_main_queue())
            {
                self.indicator.stopAnimating()
            }
            
            // *** get statusCode of response and perform action ***
            if let httpResponse = response as? NSHTTPURLResponse {
                switch httpResponse.statusCode
                {
                case 200:
                    
                    // *** on 200 status code parse data and fill in array ***
                    let jsonResponse = JSON(data: data!)
                    if jsonResponse.count > 0
                    {
                        self.arrPosts.addObjectsFromArray(jsonResponse.arrayObject!)
                    }
                    
                    // *** Update/reload tableview with new data ***
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

extension PhotosViewController: UITableViewDelegate,UITableViewDataSource
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
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifierPostCell, forIndexPath: indexPath) as! PhotoTableViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: PhotoTableViewCell, atIndexPath indexPath: NSIndexPath)
    {
        // Fetch User
        let post = self.arrPosts[indexPath.row]
        
        let photoId = post["id"] as? Int
        
        // Update Cell
        if let photoTitle = post["title"]!
        {
//            print("PhotoId - \(photoId!)")
            cell.lblTitle.text = photoTitle as? String
        }
        
        // *** set empty/placehoder image **
        cell.imgView.image = UIImage(named: "")
        
        // *** check for thumbnailUrl ***
        if let thumbnaiURL = post["thumbnailUrl"]! as? String
        {
            // *** Check if image already in cache, then display it ***
            if (self.cache.objectForKey(photoId!) != nil)
            {
                print("loading from cache \(photoId!)")
                
                cell.imgView?.image = self.cache.objectForKey(photoId!) as? UIImage
            }
            else
            {
                // *** if image not in cache, check if its in downloading queue ***
                let keyExists = self.dictDownloadTracking[photoId!] != nil
                if !keyExists
                {
                    print("Downloading \(photoId!)")
                    
                    // *** If it is not in queue start new download ***
                    let url:NSURL! = NSURL(string: thumbnaiURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
                    print(url)
                    let task = session.downloadTaskWithURL(url, completionHandler: { (location, response, error) -> Void in
                        if let data = NSData(contentsOfURL: url){
                            
                            self.dictDownloadTracking.removeObjectForKey(photoId!)
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                if let updateCell = self.tableView.cellForRowAtIndexPath(indexPath) as? PhotoTableViewCell {
                                    
                                    // *** set image to imageview ***
                                    let img:UIImage! = UIImage(data: data)
                                    updateCell.imgView?.image = img
                                    
                                    // *** Add image to cache for later reference ***
                                    self.cache.setObject(img, forKey: photoId!)
                                }
                            })
                        }
                    })
                    task.resume()
                    
                    self.dictDownloadTracking.setObject(task, forKey: photoId!)
                }
                else
                {
                    print("Already in download")
                }
            }
        }
    }
}
