//
//  MoviesViewController.swift
//  RootenTomatoes2
//
//  Created by ToanVo on 11/13/15.
//  Copyright © 2015 ToanVo. All rights reserved.
//
import AFNetworking
import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!
   
    
    @IBOutlet weak var netWorkErrorView: UIView!
    
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*
        let url = NSURL(string: "https://coderschool-movies.herokuapp.com/movies?api_key=xja087zcvxljadsflh214")!
        let request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            //(response: NSURLResponse!, data: NSData!, error:NSError!) -> Void in
            // let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.tableView.reloadData()
                }
                //print(json)
            } catch let error as NSError {
                print(error)
            }
        }
        */
        
        CozyLoadingActivity.show("Loading...", disableUI: true)
        
        tableView.dataSource = self
        tableView.delegate = self // event
        
        customizeNavigationController()
        
        // Add pull to refresh to the tableview
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "requestMovies:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        netWorkErrorView.hidden = true
        requestMovies(self)
        
        //CozyLoadingActivity.hide(success: true, animated: true)
        
        
    }
    
    func customizeNavigationController(){
        // Style navigation bar controller
        navigationController?.navigationBar.barTintColor = UIColor.greenColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.yellowColor()]
        navigationController?.navigationBar.tintColor = UIColor.yellowColor()
        navigationController?.navigationBar.backgroundColor = UIColor.blackColor()
    }
    
    func showNetworkError(){
        // Animate the appearance of network error
        UIView.animateWithDuration( 1.0,
            delay: 0.0,
            options: [],
            animations: {
                self.netWorkErrorView.hidden = false
            },
            completion: {
                finished in
        })
        
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    func requestMovies(sender:AnyObject){
        
        // Default API looks for box office movies
        let url = NSURL(string: "https://coderschool-movies.herokuapp.com/movies?api_key=xja087zcvxljadsflh214")!
        
        let request = NSURLRequest(URL: url)
        print("\(request)")
        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            //(response: NSURLResponse!, data: NSData!, error:NSError!) -> Void in
            // let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
            if error == nil{
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                
                    if let json = json {
                        self.movies = json["movies"] as? [NSDictionary]
                        
                        // Refresh the tableView
                        self.tableView.reloadData()
                        
                        self.netWorkErrorView.hidden = true
                        
                    }
                    CozyLoadingActivity.hide()
                } catch let error as NSError {
                    print(error)
                    CozyLoadingActivity.hide(success: false, animated: true)
                }
            }
            else {
                CozyLoadingActivity.hide(success: false, animated: true)
            // If there's an issue, show the network error alert.
                self.showNetworkError()
                    
            }
        }
        
        // Clear out loading overlays
        self.onRefresh()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        }  else{
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    @available(iOS 2.0, *)
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        
        
        if let poster = movie["posters"] as? NSDictionary {
            
            let imageURLString = poster["thumbnail"] as! String
            let imageURL = NSURL(string: imageURLString)
            cell.posterView.alpha = 0.0
            cell.posterView.setImageWithURL(imageURL!)
            
            
            // Make poster images fade in
            UIView.animateWithDuration(3.0,
                delay: 0.0,
                options: UIViewAnimationOptions.AllowAnimatedContent ,
                animations: {
                    cell.posterView.alpha = 1.0
                },
                completion: {
                    finished in
            })
        }
        
        //let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as!String )!
        //cell.posterView.setImageWithURL(url)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath (indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = UIColor.orangeColor()
        cell?.backgroundColor = UIColor.orangeColor()
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = UIColor.whiteColor()
        cell?.backgroundColor = UIColor.lightGrayColor()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        let movie = movies![indexPath.row]
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
       // print ( "Hello Vietnam!")
    }
    

}
