//
//  DetailViewController.swift
//  ArtBookProject
//
//  Created by Abdullah Oğuz on 16.01.2021.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var chosenPainting = ""
    var chosenPaintingID : UUID?
    
    

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            getDetailData()
            
        } else{
            
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameTextField.text = ""
            yearTextField.text = ""
            artistTextField.text = ""
            
        }
        
        

        // Do any additional setup after loading the view.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        

        
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        let  appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context  = appdelegate.persistentContainer.viewContext
       

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Paintings")
        
        do {
         let results =  try context.fetch(fetchRequest)
            
            for result in results as! [NSManagedObject] {
                context.delete(result)
                try context.save()
            }
        } catch  {
            print("ERROR")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deleteData"), object: nil)
        
        self.navigationController?.popViewController(animated: true)

    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        //AppDelegate.swift dosyasinda yer alan contexti cagirma islemleri
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // UIApplication bize appin kendisini verir
        let context = appDelegate.persistentContainer.viewContext
        
        // Burada coreDataya tanimlama yapiliyor
        let  newPaintings = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        
        newPaintings.setValue(nameTextField.text, forKey: "name")
        newPaintings.setValue(artistTextField.text, forKey: "artist")
        newPaintings.setValue(UUID(), forKey: "id")
        
        if let year = Int(yearTextField.text!) {
            newPaintings.setValue(year, forKey: "year")
        }
        
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        newPaintings.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("print")
        } catch  {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func selectImage(){
        let picker = UIImagePickerController() // fotograflari videolari vb calismalari secebilcegimiz alan acar
        picker.delegate = self
        picker.sourceType = .photoLibrary // yapilan islemi fotograf galerisi uzerinden yapilcagini bildiriyoruz
        picker.allowsEditing = true //duzenlenebilme ozellgini aktif ya da pasif hale getiiryoruz
        present(picker, animated: true, completion: nil) //present ile islemin  acilma durumunu yaziyoruz
        saveButton.isEnabled = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage // secilen resmin ekrana basilmasini saglar
        self.dismiss(animated: true, completion: nil) // ekran kapanirken self  uzerinden islami kapatiyoruz
    }
    
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    //tableviewdan tikladigimizda verilerin icini doldurmak icin yapilan islemdir
    @objc func getDetailData(){
        
        // core date icindeki context islemleri
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Paintings")
        let idString = chosenPaintingID?.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            for result in results as! [NSManagedObject] {
                
                print(result)
                if let name = result.value(forKey: "name") as? String {
                    nameTextField.text = name
                }
                
                if let artist = result.value(forKey: "artist") as? String {
                    artistTextField.text = artist
                }
                
                if let year = result.value(forKey: "year") as? Int  {
                    print(year)
                    yearTextField.text = String(year)
                }
                
                if let image = result.value(forKey: "image") as? Data {
                    let image = UIImage(data: image)
                    imageView.image = image
                    
                }
            }
            
        } catch {
            print("ERROR")
        }
        
    }
   
}
