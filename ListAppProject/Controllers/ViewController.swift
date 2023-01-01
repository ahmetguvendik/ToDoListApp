//
//  ViewController.swift
//  ListAppProject
//
//  Created by Ahmet GÜVENDİK on 24.12.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKeyPath: "title") as? String
        return cell
    }
    var alertController = UIAlertController()
    
    @IBOutlet weak var tableView: UITableView!
    var data = [NSManagedObject]()
    
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let manangedObject = appDelegate?.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        data = try! manangedObject!.fetch(fetch)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetch()
        
        
    }
    @IBAction func didDeleteButton(_ sender:UIBarButtonItem){
        alertController = UIAlertController(title: "UYARI", message: "Bütün Veriler Silinecek Emin misiniz?", preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "Evet", style: .default,handler: {
            _ in
            //self.data.removeAll()
//            self.tableView.reloadData()
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let manangedObject = appDelegate?.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try? manangedObject?.execute(deleteRequest)
            self.fetch()
        })
        let cancelButton = UIAlertAction(title: "Vazgeç", style: .cancel)
        alertController.addAction(cancelButton)
        alertController.addAction(yesButton)
        present(alertController, animated: true)
        
    }
    @IBAction func didAddButton(_ sender:UIBarButtonItem){
        alertController = UIAlertController(title: "Yeni Olay Ekle", message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Vazgeç", style: .cancel)
        
        let saveButton = UIAlertAction(title: "Kaydet", style: UIAlertAction.Style.default,handler: { action in
            let text = self.alertController.textFields?.first?.text
            if text != "" {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let manangedObject = appDelegate?.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: manangedObject!)
                let listItem = NSManagedObject(entity: entity!, insertInto: manangedObject)
                listItem.setValue(text, forKey: "title")
                try? manangedObject?.save()
                self.fetch()
               // self.data.append(text ?? "default value")
                self.tableView.reloadData()
            }else{
                let warningAlert = UIAlertController(title: "UYARI!", message: "Bu Alan Boş Bırakılmaz", preferredStyle: .alert)
                let cancelButton2 = UIAlertAction(title: "Vazgeç", style: .cancel)
                warningAlert.addAction(cancelButton2)
                self.present(warningAlert, animated: true)
            }
        })
        
        alertController.addTextField()
        alertController.addAction(cancelButton)
        alertController.addAction(saveButton)
        present(alertController, animated: true)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Sil", handler: {_,_,_ in
        //    self.data.remove(at: indexPath.row)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let manangedObject = appDelegate?.persistentContainer.viewContext
            manangedObject?.delete(self.data[indexPath.row])
            try? manangedObject?.save()
            self.fetch()
        })
        
       
        
        deleteAction.backgroundColor = .red
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeAction = UIContextualAction(style: .normal, title: "Düzenle", handler: { [self]
            _,_,_ in
            self.alertController = UIAlertController(title: "Elemanı Düzenle", message: nil, preferredStyle: .alert)
            alertController.addTextField()
            let updateButton = UIAlertAction(title: "Güncelle", style: .default,handler: {_ in
                let text = self.alertController.textFields?.first?.text
                if text != ""{
                    //self.data[indexPath.row] = text ?? ""
                    //self.tableView.reloadData()
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let manangedObject = appDelegate?.persistentContainer.viewContext
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    if ((manangedObject?.hasChanges) != nil){
                       try? manangedObject?.save()
                       fetch()
                    }
                    
                }else{
                    self.alertController = UIAlertController(title: "UYARI", message: "Boş Bırakılamaz", preferredStyle: .alert)
                    let cancelButton = UIAlertAction(title: "Vazgeç", style: .cancel)
                    self.alertController.addAction(cancelButton)
                    present(alertController, animated: true)
                }
                
             
            })
            
            self.alertController.addAction(updateButton)
            
            present(alertController, animated: true)
            
        })
        
        let config = UISwipeActionsConfiguration(actions: [removeAction])
        return config
    }
}




