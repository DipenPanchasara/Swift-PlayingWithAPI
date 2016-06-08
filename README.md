# Swift-PlayingWithAPI
Showcase usage of UITableViewCell (Custom cell), NSCache and NSOperationQueue. Application downloads list data with images in UITableView with memory management &amp; threading.

##Objective
Sample containts 3 viewcontrollers in tab controller. Each of them represents different concept & approach for data retrieval using API call, storing & displaying it.

### First controller (ViewController)
Its simple API call which lists all the `Posts` with `Dynamic Cell Height`

### Second controller (PhotosViewController)
Its loads Photos list `Dynamic Cell Height` and holds all `UIImage` using `NSCache` for better performance & usage.

### Third controller (PhotosWithQueueViewController)
Its loads Photos list `Dynamic Cell Height` and downloads Photos save it into Documents Directory of application as well uses `NSCache` for extrem performance & usage.
It also handles memory management by releasing cached and cancelling `NSOperation's` as per requirement.

##Classes Explored
- NSURLSession
- NSURLSessionTask
- UITableViewCell (Custom Cell)
- NSOperationQueue
- NSCache

##Pod file
    # Uncomment this line to define a global platform for your project
     platform :ios, '8.0'
    # Uncomment this line if you're using Swift
     use_frameworks!

    target 'Swift-PlayingWithAPI' do
        pod 'Alamofire', '~> 3.4'
        pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
    end

##Usage
- Clone Project using terminal & git command `git clone https://github.com/DipenPanchasara/Swift-PlayingWithAPI.git`.
- Navigate to project directory & install required pods by running `pod install` command in terminal.
- Open project using `Swift-PlayingWithAPI.xcworkspace` file. Thats all.

Happy Coding :)

