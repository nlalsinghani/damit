//
//  LevelSelectViewController.swift
//  DamIt
//
//  Created by kishanS on 10/8/20.
//

import UIKit
import CoreData


protocol LevelUpdate{
    func updateLevel(levelpack: Int, levelNumber: Int)
}

class LevelSelectViewController: UIViewController, LevelUpdate {
    
    var delegate : UIViewController!
    
    var levelsCompleted : [Bool]!
    var levelData: [String]!
    var currentLevel: Int!
    var userLevels:Int!
    var userPacks:Int!
    
    var selectedLevelEncoding = ""
    var levelPack: Int!
    var isCoop: Bool!
    let segue: String = "gameSegue"
    
    @IBOutlet var buttons: [UIButton]!
   
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for button in buttons {
            let buttonNumber = Int((button.titleLabel?.text)!)!
            if(levelPack >= userPacks){
                if buttonNumber > self.userLevels{
                   button.isEnabled = false
                }
            }
        }
    }
    
    @IBAction func levelButtonPressed(_ sender: Any) {
        let button = sender as! UIButton
        self.currentLevel = button.tag
        let index = (levelPack - 1) * 10 + self.currentLevel
        selectedLevelEncoding = levelData[index]
        performSegue(withIdentifier: segue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == self.segue) {
            let vc = segue.destination as! GameViewController
            vc.levelEncoding = self.selectedLevelEncoding
            vc.levelData = self.levelData
            vc.currentLevel = self.currentLevel
            vc.currentPack = levelPack
            vc.delegate = self
            vc.isCoop = self.isCoop
            
        }
    }
    
    //broken for multiple levels
    func updateLevel(levelpack:Int, levelNumber: Int) {
        var index = (levelpack - 1) * 10
        index += levelNumber
        if(levelpack == self.levelPack && index < levelData.count){
            index = levelNumber
            for button in buttons{
                let buttonNumber = Int((button.titleLabel?.text)!)!
                //button numbers start at 1 and go to 10
                // to use in comparison to index subtract 1
                if buttonNumber - 1 <= index{
                   button.isEnabled = true
                }
            }
        }
    }
    
    func updateLevelPack(levelpack:Int){
        let othervc = delegate as! LevelPackViewController
        othervc.updatePack(levelPack: levelpack)
    }
}
