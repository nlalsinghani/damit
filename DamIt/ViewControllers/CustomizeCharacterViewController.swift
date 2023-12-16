//
//  CustomizeCharacterViewController.swift
//  DamIt
//
//  Created by kishanS on 9/30/20.
//

import UIKit

class CustomizeCharacterViewController: UIViewController {
    
    var style : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.title = "Customize Character"
        style = UserDefaults.standard.integer(forKey: "customStyle")
        print("Style Number \(style!)")
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        disclosureAlert()
    }
    
    func disclosureAlert() {
        let controller = UIAlertController(title: "Disclosure", message: "Player Skin Selection not yet implemented. Planned for Beta Release.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func skinStyleSelected(_ sender: Any) {
        let button = sender as! UIButton
        let style = button.tag
        let defaults = UserDefaults.standard
        gameSettings.skin = style
        defaults.setValue(style, forKey: "customStyle")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
