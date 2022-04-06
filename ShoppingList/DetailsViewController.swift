//
//  DetailsViewController.swift
//  ShoppingList
//
//  Created by Furkan Açıkgöz on 16.03.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var productName = ""
    var productId : UUID?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageClicked))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if productName != "" {
            
            saveButton.isHidden = true
            
            if let uuidString = productId?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
                fetchRequest.returnsObjectsAsFaults = false
                fetchRequest.predicate = NSPredicate.init(format: "id = %@", uuidString)
                
                do{
                    let products = try context.fetch(fetchRequest)
                    
                    if products.count > 0 {
                        
                        for product in products as! [NSManagedObject]{
                            
                            if let name = product.value(forKey: "name") as? String{
                                nameTextField.text = name
                            }
                            
                            if let price = product.value(forKey: "price") as? Int{
                                priceTextField.text = String(price)
                            }
                            
                            if let size = product.value(forKey: "size") as? String{
                                sizeTextField.text = size
                            }
                            
                            if let imageData = product.value(forKey: "image") as? Data{
                                imageView.image = UIImage(data: imageData)
                            }
                            
                        }
                        
                    }
                    
                }catch{
                    print("error")
                }
                
            }
            
           
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            //imageView.image = UIImage(named: "tap")
            //nameTextField.text = ""
            //priceTextField.text = ""
            //sizeTextField.text = ""
        }
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func imageClicked(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let product = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context)
        product.setValue(nameTextField.text!, forKey: "name")
        product.setValue(sizeTextField.text!, forKey: "size")
        product.setValue(UUID(), forKey: "id")
        
        if let price = Int(priceTextField.text!){
            product.setValue(price, forKey: "price")
        }
        
        let imageData = imageView.image?.jpegData(compressionQuality: 0.5)
        product.setValue(imageData, forKey: "image")
        
        do{
            try context.save()
        } catch{
            print("Context cannot be saved!")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "New Products"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}
