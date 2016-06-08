//
//  PhotosWithQueueViewController.swift
//  Swift-PlayingWithAPI
//
//  Created by Dipen Panchasara on 08/06/16.
//  Copyright © 2016 Company Name. All rights reserved.
//

import UIKit
import SwiftyJSON

class PhotosWithQueueViewController: UIViewController {

    let ReuseIdentifierPostCell = "PhotoCell"
    
    var sessionConfiguration:NSURLSessionConfiguration!
    var session:NSURLSession!
    
    var arrPosts = NSMutableArray()
    var dictDownloadTracking = NSMutableDictionary()
    var cache:NSCache!
    let fileManager = NSFileManager.defaultManager()

    var queue = NSOperationQueue()
    
    var indicator:UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    struct Common {
        static let DOC_DIR = NSSearchPathForDirectoriesInDomains(.ApplicationDirectory, .UserDomainMask, true)[0]
        
        static func getDocumentsURL() -> NSURL {
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            return documentsURL
        }
        
        static func fileInDocumentsDirectory(filename: String) -> String {
            
            let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
            return fileURL.path!
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // *** Create session configuration ***
        self.sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.sessionConfiguration.timeoutIntervalForResource = 60
        self.sessionConfiguration.timeoutIntervalForResource = 120
        self.sessionConfiguration.requestCachePolicy = .ReloadIgnoringLocalAndRemoteCacheData
        
        // *** Create session using configuration ***
        self.session = NSURLSession(configuration: sessionConfiguration)
        
        // *** init dictionary for download tracking ***
        self.dictDownloadTracking = NSMutableDictionary()
        
        // *** init cache ***
        self.cache = NSCache()
        
        // *** configure queue ***
        queue.maxConcurrentOperationCount = 4
        queue.name = "PhotosWithQueue"
        queue.qualityOfService = .UserInteractive
        
        // *** set title ***
        self.title = "Photos using Ope. Queue"
        
        // *** set tableview estimated height & rowheight ***
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60
        
        // *** Init Indicator & set as Bar Item ***
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.indicator.hidesWhenStopped = true
        
        let itemIndicator:UIBarButtonItem = UIBarButtonItem(customView: indicator)
        self.navigationItem.setRightBarButtonItem(itemIndicator, animated: true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // *** Request data from API ***
        customRequest()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // *** Cancel all photo download operations ***
        self.queue.cancelAllOperations()
        
        // *** empty cache ***
        self.cache.removeAllObjects()
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
                        // *** Handle response error ***
                        print("Error in request [\(request.URLRequest.URL?.absoluteString)]: \(error?.localizedDescription)")
                }
            }
        }
        
        // *** Don't forget this, resume task otherwise request will never initiate ***
        task.resume()
        
        // *** Logged current Task identifier, could be use for tracking ***
        print("TaskId : \(task.taskIdentifier)")
    }

}

extension PhotosWithQueueViewController: UITableViewDelegate,UITableViewDataSource
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
        
        // *** set empty/placehoder image ***
        cell.imgView.image = UIImage(named: "")
        
        // *** check for thumbnailURL ***
        if let thumbnaiURL = post["thumbnailUrl"]! as? String
        {
            let filePath:String = Common.fileInDocumentsDirectory(NSString(format:"\(photoId!).jpg") as String)
            
            // *** Check if image already in cache, then display it ***
            if (self.cache.objectForKey(photoId!) != nil)
            {
                print("loading from cache \(photoId!)")
                // 2
                cell.imgView?.image = self.cache.objectForKey(photoId!) as? UIImage
            }
            // *** Load image from documents diretory ***
            else if self.fileManager.fileExistsAtPath(filePath)
            {
                if let img = UIImage(contentsOfFile: filePath)
                {
                    // *** set image to imageview ***
                    cell.imgView?.image = img
                    
                    // *** Add image to cache for later reference ***
                    self.cache.setObject(img, forKey: photoId!)
                }
            }
            else
            {
                // *** if image not in cache, check if its in downloading queue ***
                let keyExists = self.dictDownloadTracking[photoId!] != nil
                if !keyExists
                {
                    print("Adding in queue \(photoId!)")
                    
                    // *** If it is not in queue start new download ***
                    let operation = NSBlockOperation(block: {
                        
                        let url:NSURL! = NSURL(string: thumbnaiURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
                        let imgData = NSData(contentsOfURL: url)
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            
                            // *** Remove object from tracking dictionary when download complete ***
                            self.dictDownloadTracking.removeObjectForKey(photoId!)
                            
                            if let img = UIImage(data: imgData!)
                            {
                                if let updateCell = self.tableView.cellForRowAtIndexPath(indexPath) as? PhotoTableViewCell
                                {
                                    // *** set downloaded image ***
                                    updateCell.imgView?.image = img
                                    
                                    // *** save image in documents directory ***
                                    if let isSuccess = UIImageJPEGRepresentation(img, 1)?.writeToFile(filePath, atomically: true)
                                    {
                                        print("image saved [\(isSuccess)] : \(filePath)")
                                    }
                                    
                                    // *** Add download image in cache for later usage ***
                                    self.cache.setObject(img, forKey: photoId!)
                                }
                            }
                            else
                            {
                                print("Download failed for \(photoId!)")
                            }
                        })
                    })
                    
                    // *** completion block for NSOoperation ***
                    operation.completionBlock = {
                        print("\(photoId!) completed")
                    }
                    
                    // *** Add current Operation to Queue ***
                    queue.addOperation(operation)
                    
                    // *** Add operation object to dictionary for tracking ***
                    self.dictDownloadTracking.setObject(operation, forKey: photoId!)
                }
                else
                {
                    print("Already in queue")
                }
            }
        }
    }
}
