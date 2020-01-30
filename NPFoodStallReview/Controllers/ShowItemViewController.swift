//
//  ShowItemViewController.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 29/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn

public class ShowItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var itemTableView: UITableView!
    
    var selectedStall:Stall?
    var selectedCanteen:Canteen?
    var itemList: [Item] = [];
    var itemController: ItemController = ItemController();
    
    public override func viewDidLoad() {
        super.viewDidLoad();
        self.itemTableView.delegate = self;
        self.itemTableView.dataSource = self;
        self.navigationItem.title = "\(selectedStall!.name) Stall";
        self.navigationItem.prompt = "\(selectedCanteen!.name)";
        
        DispatchQueue.global(qos: .utility).async {
            let semaphore = DispatchSemaphore(value: 0);
            do {
                let items = try self.itemController.retrieveItemsByStallId(stallId: self.selectedStall!.stallId);
                self.itemList = items;
                semaphore.signal()
            } catch {
                print(error)
                return
            }
            semaphore.wait()
            
            DispatchQueue.main.async {
                dump(self.itemList);
                self.itemTableView.reloadData()
            }
        }
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // TableView Configurations
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.itemTableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell;
        let item = itemList[indexPath.row];
        cell.setup(item: item);
        
        cell.likeBtn.addTarget(self, action: #selector(likePressed), for: .touchUpInside)
        cell.unlikeBtn.addTarget(self, action: #selector(unlikePressed), for: .touchUpInside)
        cell.likeBtn.tag = indexPath.row;
        cell.unlikeBtn.tag = indexPath.row;
        
        // check which btn to show
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        if (AppDelegate.googleUser == nil) {
            cell.unlikeBtn.isHidden = true;
            cell.likeBtn.isHidden = false;
        } else {
            let userId = (AppDelegate.googleUser?.userID)!
            if (item.userWhoLike[userId] ?? false) {
                cell.unlikeBtn.isHidden = false;
                cell.likeBtn.isHidden = true;
            } else {
                cell.unlikeBtn.isHidden = true;
                cell.likeBtn.isHidden = false;
            }
        }
        return cell;
    }
    
    // Functions for like and unlike
    
    @objc func likePressed(button: UIButton) {
        // Authenticate user first before anything
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        let item = itemList[button.tag];
        if (AppDelegate.googleUser == nil) {
            GIDSignIn.sharedInstance()?.signIn()
        } else {
            DispatchQueue.global(qos: .utility).async {
                let semaphore = DispatchSemaphore(value: 0);
                
                let success:Bool = self.itemController.addOrUpdateLikes(itemId: item.itemId, userId: (AppDelegate.googleUser?.userID)!, value: true);
                semaphore.signal();
                
                semaphore.wait();
                guard success else {return}
                do {
                    let items = try self.itemController.retrieveItemsByStallId(stallId: self.selectedStall!.stallId);
                    self.itemList = items;
                    semaphore.signal()
                } catch {
                    print(error)
                    return
                }
                semaphore.wait();
                DispatchQueue.main.async {
                    self.itemTableView.reloadData();
                }
            }
        }
        // Refetch the items then reload data
    }
    
    @objc func unlikePressed(button: UIButton) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        let item = itemList[button.tag];
        if (AppDelegate.googleUser == nil) {
            GIDSignIn.sharedInstance()?.signIn()
        } else {
            DispatchQueue.global(qos: .utility).async {
                let semaphore = DispatchSemaphore(value: 0);
                
                let success:Bool = self.itemController.addOrUpdateLikes(itemId: item.itemId, userId: (AppDelegate.googleUser?.userID)!, value: false);
                semaphore.signal();
                
                semaphore.wait();
                guard success else {return}
                do {
                    let items = try self.itemController.retrieveItemsByStallId(stallId: self.selectedStall!.stallId);
                    self.itemList = items;
                    semaphore.signal()
                } catch {
                    print(error)
                    return
                }
                semaphore.wait();
                DispatchQueue.main.async {
                    self.itemTableView.reloadData();
                }
            }
        }
    }
    
    
    
}
