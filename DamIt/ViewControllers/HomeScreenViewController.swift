//
//  ViewController.swift
//  DamIt
//
//  Created by kishanS on 9/30/20.
//

import UIKit
import GameKit
import CoreData
import Firebase
import AVKit

var backgroundMusicPlayer: AVAudioPlayer!

class HomeScreenViewController: UIViewController, SettingsViewControllerDelegate {
    
    let settingsSegueID = "settingsSegue"
    let levelPackSegueID = "LevelPackSelectSegue"
    var user = ""
    var userData: [NSManagedObject]!
    var ref: DatabaseReference!
    var userLevelData = ""
    var audioPlayer: AVAudioPlayer!
    var coopClicked: Bool = false
    var coopuserLevelData = ""
    
    var settingArray: [Bool]!
    var notificationManager = NotificationManager()
    
   
    override func viewDidLoad() {
//        navigationController?.setNavigationBarHidden(true, animated: true)
        playBackgroundMusic(backgroundMusic: "retroBackgroundMusic")
    }
    override func viewDidAppear(_ animated: Bool) {
        coopClicked = false
    }
    override func viewWillAppear(_ animated: Bool) {
        ref = Database.database().reference()
        var userID = Auth.auth().currentUser?.email
        // reformatting the email again to query the database
        userID = userID!.replacingOccurrences(of: "@", with: ",")
        userID = userID!.replacingOccurrences(of: ".", with: ",")
        ref.child("users").child(userID!).child("level").observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
          let value = snapshot.value as? NSDictionary
            self.userLevelData = value?["levelPack"] as? String ?? ""

          // ...
          }) { (error) in
            print(error.localizedDescription)
        }
        ref.child("users").child(userID!).child("cooplevel").observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
          let value = snapshot.value as? NSDictionary
            self.coopuserLevelData = value?["levelPack"] as? String ?? ""

          // ...
          }) { (error) in
            print(error.localizedDescription)
        }
        super.viewDidLoad()
        retrieveUser()
        settingsArray()
//        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        // make nav bar  come back for next pages
        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func playBackgroundMusic(backgroundMusic: String) {
        print("Music on:", gameSettings.settings[1])
        let url = Bundle.main.url(forResource: backgroundMusic, withExtension: "mp3")
        audioPlayer = try! AVAudioPlayer(contentsOf: url!)
        audioPlayer.numberOfLoops = -1
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "backroundMusicSwitch") {
            audioPlayer.play()
        }
        backgroundMusicPlayer = audioPlayer
    }
    
    func changedSoundFX(isOn: Bool) {
        // change user defaults
        let defaults = UserDefaults.standard
        defaults.set(1,forKey: "sfxSet")
        defaults.set(isOn,forKey: "soundFXSwitch")
    }

    func changedBackgroundMusic(isOn: Bool) {
        //
        let defaults = UserDefaults.standard
        defaults.set(1,forKey: "bgmusicSet")
        defaults.set(isOn,forKey: "backroundMusicSwitch")
    }

    func changedDailyNotification(isOn: Bool) {
        //
        let defaults = UserDefaults.standard
        defaults.set(1,forKey: "notificationsSet")
        defaults.set(isOn,forKey: "notificationSwitch")
    }

    func changedDpad(isOn: Bool) {
        //
        let defaults = UserDefaults.standard
        defaults.set(1,forKey: "dpadSet")
        defaults.set(isOn,forKey: "dpadSwitch")
    }
//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        self.navigationController?.isNavigationBarHidden = false
        if (segue.identifier == settingsSegueID){
            let vc = segue.destination as! SettingsViewController
            vc.delegate = self
            if(settingArray.count == 0){
                vc.settingsArray = settingsArray()
            }else{
                vc.settingsArray = settingArray
            }
            vc.audioPlayer = self.audioPlayer
            gameSettings.settings = vc.settingsArray
            vc.notificationManager = notificationManager
        }
        if(segue.identifier == "LevelPackSelectSegue" ){
            let vc = segue.destination as! LevelPackViewController
            vc.delegate = self
            vc.userData = userData
            if(coopClicked){
                vc.userLevelData = coopuserLevelData
            } else {
                vc.userLevelData = userLevelData
            }
            vc.CoOpMode = coopClicked
        }
        if (segue.identifier == "tutorialSegue") {
            let vc = segue.destination as! GameViewController
            vc.levelEncoding = "00001205RRRLLRRRLARRRAARRRAARRRAARRRAARRRAARRRAARRRBARRRAAAAAAARRRAA"
            vc.isTutorial = true
        }
    }
    
    
    func settingsArray(completionHandler: (()->Void)? = nil) -> [Bool] {
        var arr = [true, false, true ,false]
        
        ref = Database.database().reference()
        var userID = Auth.auth().currentUser?.email
        // reformatting the email again to query the database
        userID = userID!.replacingOccurrences(of: "@", with: ",")
        userID = userID!.replacingOccurrences(of: ".", with: ",")
        ref.child("users").child(userID!).child("settings").observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
            let value = snapshot.value as? NSDictionary
            self.settingArray = [Bool](repeating: true, count: 4)
            self.settingArray[0] = value?["soundFX"] as? Bool ?? true
            self.settingArray[1] = value?["backgroundMusic"] as? Bool ?? true
            self.settingArray[2] = value?["notifications"] as? Bool ?? true
            self.settingArray[3] = value?["dpad"] as? Bool ?? false
            // ...
          }) { (error) in
            print(error.localizedDescription)
            print("getting settings from user defaults")
            let defaults = UserDefaults.standard
            let sfxSet = defaults.integer(forKey: "sfxSet")
            let bgmSet = defaults.integer(forKey: "bgmusicSet")
            let notificaitonsSet = defaults.integer(forKey: "notificationsSet")
            let dpad = defaults.integer(forKey: "dpadSet")
            if(sfxSet == 1) {
                arr[0] = defaults.bool(forKey: "soundFXSwitch")
            }
            if(bgmSet == 1){
                arr[1] = defaults.bool(forKey: "backroundMusicSwitch")
            }
            if(notificaitonsSet == 1){
                arr[2] = defaults.bool(forKey: "notificationSwitch")
            }
            if(dpad == 1){
                arr[3] = defaults.bool(forKey: "dpadSwitch")
            }
        }
        
        return arr
    }
    
    @IBAction func playerModeButtonPressed(_ sender: UIButton) {
        let tag = sender.tag
        //Co - op mode
        if (tag == 1) {
          coopClicked = true
        } else if (tag == 2) {
            // multi player mode
            disclosureAlert()
        }
        performSegue(withIdentifier: levelPackSegueID , sender: self)
    }
    
    @IBAction func tutorialButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "tutorialSegue", sender: self)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    
    func disclosureAlert() {
        let controller = UIAlertController(title: "Disclosure", message: "This mode is not yet implemented. Planned as a strech goal or future release.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    func retrieveUser() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "id = %@", user)
        
        
        do {
            try userData = context.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
}

