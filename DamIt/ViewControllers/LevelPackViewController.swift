//
//  LevelPackViewController.swift
//  DamIt
//
//  Created by Nikhil Bodicharla on 10/18/20.
//

import UIKit
import CoreData
import FirebaseDatabase

protocol packUpdate{
    func updatePack(levelPack: Int)
}

class LevelPackViewController: UIViewController, packUpdate {
    
    @IBOutlet weak var checkcollectionview: UICollectionView!
    var CoOpMode: Bool!
    var delegate: UIViewController!
    var levelData = [String]()
    var userData: [NSManagedObject]!
    var userLevelData = ""
    var test = 0
    var distance = 0
    var levelPack = 0
    var level = 0
    var firebaseData = [String]()
    var dataBaseRef: DatabaseReference!

    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //clearCoreData()
        if(CoOpMode == false){
            dataBaseRef = Database.database().reference()
            //what if no network connection?
            getLevelsFromFirebase { (success) in
                if(success){
                    //compare elements
                    self.retrieveLevels{
                        self.compareFireBaseData()
                    }
                } else {
                    //use data from coredata only
                    self.retrieveLevels()
                    if(self.levelData.count == 0){
                        self.storeLevels()
                        self.retrieveLevels()
                    }
                }

            }
            // converting the data to a level and level pack to use for user
            if let index = userLevelData.firstIndex(of: ":") {
                distance = userLevelData.distance(from: userLevelData.startIndex, to: index)
                self.levelPack = Int(userLevelData.substring(with: 1..<distance))!
                self.level = Int(userLevelData.substring(with: distance+1..<userLevelData.count - 1))!
            }
        } else {
            //co op mode
            self.levelPack = 1
            self.level = 1
            dataBaseRef = Database.database().reference()

            getCoopLevelsFromFirebase() { (success) in
                if(!success){
                    //present error as not connected to internet
                    self.disclosureAlert()
                } else {
                    self.levelData = self.firebaseData
                    if let index = self.userLevelData.firstIndex(of: ":") {
                        self.distance = self.userLevelData.distance(from: self.userLevelData.startIndex, to: index)
                        self.levelPack = Int(self.userLevelData.substring(with: 1..<self.distance))!
                        self.level = Int(self.userLevelData.substring(with: self.distance+1..<self.userLevelData.count - 1))!
                    }
                }
            }
            
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "levelSegue"){
            let vc = segue.destination as! LevelSelectViewController
            let button = sender as? UIButton
            vc.delegate = self
            vc.levelPack = button?.tag
            vc.levelData = levelData
            vc.userLevels = self.level
            vc.userPacks = self.levelPack
            vc.isCoop = self.CoOpMode
        }
    }
    
    
    func disclosureAlert() {
          let alertcontroller = UIAlertController(title: "Error", message: "Must be online for Coop mode to work, please try single player mode", preferredStyle: .alert)
          let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
          alertcontroller.addAction(okAction)
          self.present(alertcontroller, animated: true){
              self.dismiss(animated: true)
          }
    }
}
extension LevelPackViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = checkcollectionview.dequeueReusableCell(withReuseIdentifier: "check", for: indexPath) as? checkCollectionViewCell
        cell?.buttontitle.setTitle("Level Pack \(String(indexPath.row + 1))", for: .normal)
        cell?.buttontitle.tag = indexPath.row + 1
//        for i in 0...indexPath.row{
//            if(i < self.levelPack) {
//                let indexp = IndexPath(index: i)
//                let enabledCell = collectionView.cellForItem(at: indexp) as? checkCollectionViewCell
//                enabledCell?.buttontitle.isEnabled = true
//            }
//        }
        if indexPath.row + 1 > self.levelPack {
            cell?.buttontitle.isEnabled = false
        } else {
            cell?.buttontitle.isEnabled = true
        }
        return cell!
    }
    
    
    func updatePack(levelPack: Int) {
        if(levelPack < (levelData.count/10)){
            self.levelPack = levelPack
            self.level = 1
            checkcollectionview.reloadData()
        }
    }
    
}


//MARK: - CORE DATA METHODS
extension LevelPackViewController {
    func storeLevels() {
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let level1 = NSEntityDescription.insertNewObject(
            forEntityName: "LevelData", into:context)
        
        level1.setValue(true, forKey: "completed")
        level1.setValue(0101, forKey: "id")
        let level1Encoding = "01011004RLLLLLAAAAAALLAALAAARRBAAAAALLAALLLARRLL"
        level1.setValue(level1Encoding, forKey: "encoding")
        
        let level2 = NSEntityDescription.insertNewObject(
            forEntityName: "LevelData", into:context)
        
        let level2Encoding = "01021003RLLRLALAARAARRLRRBRLLAAARRALLL"
        level2.setValue(false, forKey: "completed")
        level2.setValue(0102, forKey: "id")
        level2.setValue(level2Encoding, forKey: "encoding")
        
        let level3 = NSEntityDescription.insertNewObject(
            forEntityName: "LevelData", into:context)
        
        level3.setValue(false, forKey: "completed")
        level3.setValue(0103, forKey: "id")
        let level3Encoding = "01031004RLLLRLLARLAARAAARLAARRBAAAAARAAARLAARRLA"
        level3.setValue(level3Encoding, forKey: "encoding")
        
        let level4 = NSEntityDescription.insertNewObject(
            forEntityName: "LevelData", into:context)
        
        level4.setValue(false, forKey: "completed")
        level4.setValue(0104, forKey: "id")
        let level4Encoding = "01041006RLLLLLRLLLLLRLLAAARLAAAARRAAAAAAAAAARLBAAARLLAAARLAAAARLLLAA"
        level4.setValue(level4Encoding, forKey: "encoding")
        
        let level5 = NSEntityDescription.insertNewObject(
            forEntityName: "LevelData", into:context)

        level5.setValue(false, forKey: "completed")
        level5.setValue(0105, forKey: "id")
        let level5Encoding = "01051405LLLLLAAAAARRLLLLLLLALAAAALLAAALLLLARLLAALLBAALAAAARRAAALLLAARRLLLRRLLL"
        level5.setValue(level5Encoding, forKey: "encoding")
        
        let level6 = NSEntityDescription.insertNewObject(
            forEntityName: "LevelData", into:context)

        level6.setValue(false, forKey: "completed")
        level6.setValue(0106, forKey: "id")
        let level6Encoding = "01061407RLLLLLALLLLLAARRLLAAALLLAAAARLAAAAARBAAAAARRAAAAARAAAAAARRRAAAALLLLAAALLAAAAALAAAAAALLAAAAALLLLLL"
        level6.setValue(level6Encoding, forKey: "encoding")
        let level7 = NSEntityDescription.insertNewObject(
            forEntityName: "LevelData", into:context)
        
        level7.setValue(false, forKey: "completed")
        level7.setValue(0107, forKey: "id")
        let level7Encoding = "01071106LLLLAALLAAAALBAAAARRAAAALLLAAAAAAAAALLLAAALLLLAALLLLLALLLLLLRRLAAA"
        level7.setValue(level7Encoding, forKey: "encoding")
        
        let level8 = NSEntityDescription.insertNewObject(
            forEntityName: "LevelData", into:context)
        
        level8.setValue(false, forKey: "completed")
        level8.setValue(0108, forKey: "id")
        let level8Encoding = "01081806RAAAAARAAAAARLAAAARLLAAARAAAAARAAAAARLLLLLRAAAAARAAAAARLLAAARAAAAARAAAAARLLLAARAAAAARLLAAARLAAAARBAAAARLLAAA"
        level8.setValue(level8Encoding, forKey: "encoding")
        
        let level9 = NSEntityDescription.insertNewObject(
            forEntityName: "LevelData", into:context)
        
        level9.setValue(false, forKey: "completed")
        level9.setValue(0109, forKey: "id")
        let level9Encoding = "01091604LLLLRAAARRLAAAAARRAAAAAALAAALLLARRAARBAARRLLAAAAAAAARRLARLLLRLLL"
        level9.setValue(level9Encoding, forKey: "encoding")
        
        let level10 = NSEntityDescription.insertNewObject(
            forEntityName: "LevelData", into:context)
        
        level10.setValue(false, forKey: "completed")
        level10.setValue(0110, forKey: "id")
        let level10Encoding = "01101805RRLAALLAAAAAAAARRLAAAAAAAAAAAALAAAARLLAALLBAAAAAAARRLLARAAAARRLLLAAAAARLLAARLAAARLAAARLLLL"
        //01101805RRLAALLAAAAAAAARRLAAAAAAAAAAAALAAAARLLAALLBAAAAAAARRLLARAAAARRLLLLAAAARLAAARLLAARLLLARLLLL
        level10.setValue(level10Encoding, forKey: "encoding")
        
        // Commit the changes
        do {
            print("saving data")
            try context.save()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func clearCoreData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LevelData")
        
        var fetchedResults: [NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                }
            }
            try context.save()
            
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        
    }
    
    func getCoopLevelsFromFirebase(completionHandler: @escaping(_ success :Bool)-> Void){
            dataBaseRef.child("cooplevels").observeSingleEvent(of: .value, with: { (snapshot) in
                let levelDataBase = snapshot.value as! NSMutableDictionary
                self.firebaseData = Array(repeating: "", count: levelDataBase.count)
                for (key,value) in levelDataBase {
                    let encoding = value as? String
                    if let realEncoding = encoding {
                        let levelPack = Int(realEncoding.substring(to: 2))
                        let levelNum = Int(realEncoding.substring(with: 2..<4))
                        let index = levelNum! - 1
                        self.firebaseData[((levelPack!-1)*10) + index] = realEncoding
                        print(value)
                    }
                }
                //network connection completed
                completionHandler(true)
            }) { (error) in
                //firebase request unsuccessful
                completionHandler(false)
            }
        }
    
    func getLevelsFromFirebase(completionHandler: @escaping (_ success:Bool) -> Void){
        //pull from firebase levels
        dataBaseRef.child("Levels").observeSingleEvent(of: .value, with: { (snapshot) in
            let levelDataBase = snapshot.value as! NSMutableDictionary
            self.firebaseData = Array(repeating: "", count: levelDataBase.count)
            for (key,value) in levelDataBase {
                let encoding = value as? String
                if let realEncoding = encoding {
                    let levelPack = Int(realEncoding.substring(to: 2))
                    let levelNum = Int(realEncoding.substring(with: 2..<4))
                    let index = levelNum! - 1
                    self.firebaseData[((levelPack!-1)*10) + index] = realEncoding
                    print(value)
                }
            }
            //network connection completed
            completionHandler(true)
        }) { (error) in
            //firebase request unsuccessful
            completionHandler(false)
        }
    }
    
    func retrieveLevels(completionHandler: (() -> Void)? = nil){
        //pull from CoreData
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LevelData")
        
        var fetchedResults: [NSManagedObject]? = nil
        
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
            if fetchedResults!.count > 0{
                //results exist
                self.levelData = Array(repeating: "", count: fetchedResults!.count)
                for level in fetchedResults!{
                    if let completed = level.value(forKey: "completed") as? Bool{
                        if let id = level.value(forKey: "id") as? Int{
                            if let encoding = level.value(forKey: "encoding") as? String {
                                let levelPack = Int(encoding.substring(to: 2))
                                let levelNum = Int(encoding.substring(with: 2..<4))
                                let levelPackIndex = levelPack! - 1
                                let index = levelPackIndex * 10 + levelNum! - 1
                                self.levelData[index] = encoding
                            }
                        }
                    }
                }
            }
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        if (completionHandler != nil){
            completionHandler!()
        }
    }
    
    func compareFireBaseData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        for level in firebaseData {
            if(!levelData.contains(level)){
                //write level to coreData
                let CDLevel = NSEntityDescription.insertNewObject(
                    forEntityName: "LevelData", into:context)
                
                CDLevel.setValue(false, forKey: "completed")
                let id = Int(level.prefix(4))
                CDLevel.setValue(id, forKey: "id")
                let levelEncoding = level
                CDLevel.setValue(levelEncoding, forKey: "encoding")
            }
        }
        
        // Commit the changes
        do {
            print("saving data")
            try context.save()
            levelData = firebaseData
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
}
