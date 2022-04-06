//
//  ViewController.swift
//  ShoppingList
//
//  Created by Furkan Açıkgöz on 16.03.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var chosenProductName = ""
    var chosenProductId : UUID?
    
    var namesList = [String]()
    var idList = [UUID]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(barButtonClicked))
        
        fetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(fetch), name: NSNotification.Name.init(rawValue: "New Products"), object: nil)
    }
    
    @objc func fetch(){
        namesList.removeAll(keepingCapacity: false)
        idList.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let products = try context.fetch(fetchRequest)
            
            if products.count > 0 {
                for product in products  as! [NSManagedObject] {
                    if let name = product.value(forKey: "name") as? String {
                        namesList.append(name)
                    }
                    
                    if let id = product.value(forKey: "id") as? UUID {
                        idList.append(id)
                    }
                }
                
                tableView.reloadData()
            }
        }catch{
            print("error")
        }
    }
    
    @objc func barButtonClicked(){
        chosenProductName = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = namesList[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
            let uuidString = idList[indexPath.row].uuidString
            
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate = NSPredicate.init(format: "id = %@", uuidString)
            
            do{
                let products = try context.fetch(fetchRequest)
                
                if products.count > 0 {
                    for product in products as! [NSManagedObject] {
                        if let id = product.value(forKey: "id") as? UUID{
                            if id == idList[indexPath.row]{
                                context.delete(product)
                                
                                idList.remove(at: indexPath.row)
                                namesList.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    print("error")
                                }
                                
                                break
                            }
                        }
                    }
                }
                
            }catch{
                print("error")
            }
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenProductName = namesList[indexPath.row]
        chosenProductId = idList[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.productName = chosenProductName
            destinationVC.productId = chosenProductId
        }
    }
    

}

