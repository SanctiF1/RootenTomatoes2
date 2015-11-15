//
//  MovieDetailsViewController.swift
//  RootenTomatoes2
//
//  Created by ToanVo on 11/14/15.
//  Copyright © 2015 ToanVo. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
        
    @IBOutlet weak var synopsisTextView: UITextView!
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = movie["title"] as? String
        synopsisTextView.text = movie["synopsis"] as? String
        if let poster = movie["posters"] as? NSDictionary {
            
            let imageURLString = poster["thumbnail"] as! String
            let imageURL = NSURL(string: imageURLString)
            imageView.setImageWithURL(imageURL!)
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
