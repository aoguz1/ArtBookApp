//
//  ViewController.swift
//  ArtBookProject
//
//  Created by Abdullah Oğuz on 15.01.2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.


        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(onpressAddIcon))
       

    }

   
    
    @objc func onpressAddIcon() {
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }

}

