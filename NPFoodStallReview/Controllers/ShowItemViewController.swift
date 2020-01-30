//
//  ShowItemViewController.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 29/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit

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
        
        return cell;
    }
    
    
    
}
