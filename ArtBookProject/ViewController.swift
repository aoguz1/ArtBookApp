//
//  ViewController.swift
//  ArtBookProject
//
//  Created by Abdullah Oğuz on 15.01.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
  
    
    // name ve id olarak iki tane dizi tanimliyoruz bunun amaci gelen verileri bu dizilere atip tableview uzerunde gostermek
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedPainting = ""
    var selectedPaintingID :UUID?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tableView.delegate = self
        tableView.dataSource = self

        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(onpressAddIcon))
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "deleteData"), object: nil)
    }
    
    // SEGUE

    //tabbardaki buton icin yapilan segue
    @objc func onpressAddIcon() {
        
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    
    //tablenin uzerinde bir iteme tiklaninca yapilacak segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destination = segue.destination as! DetailViewController
            destination.chosenPainting = selectedPainting
            destination.chosenPaintingID = selectedPaintingID
            print("Destination \(destination.chosenPainting)")
           
        }
    }
    
    // TABLEVIEW
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text =  nameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingID = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Paintings")
            
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            
            
            do {
                let results =  try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                idArray.remove(at: indexPath.row)
                                nameArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                print("basari ile tamamlandi")
                                do {
                                    try context.save()
                                } catch  {
                                    print("error")
                                }
                                
                                break
                            }
                        }
                        
                    }
                }
                
                
            } catch  {
                print("ERROR")
            }
        }
    }
    
    
    //FETCH DATA
    @objc func getData() {
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
      
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Paintings") // hangi dokumandan verileri cekecegimizi yaziyoruz
        fetchRequest.returnsObjectsAsFaults = false //cachelenmis datalari almiyor
        
        do {
            let results = try context.fetch(fetchRequest) //veri cekme islemi
        
            if results.count > 0  {
                
                // sonrasinda veriler uzerinde islem yapmak icin for ile gelen datalar uzerinde geziyoruz
                for result in results as! [NSManagedObject] {
                   
                    
                    if let name = result.value(forKey: "name") as? String {
                        self.nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                       
                        self.idArray.append(id)
                    }
                    self.tableView.reloadData()
                }
            }
           
            
            print("get data")
        } catch {
            print("Error")
        }
    }
}

