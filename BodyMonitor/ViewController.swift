//
//  ViewController.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 12/17/16.
//  Copyright © 2016 Nicole Marvin. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View did load")
        // Do any additional setup after loading the view, typically from a nib.
        var myManager: CBCentralManager!
        var myHeartMonitorPeripheral: CBPeripheral!
        var myFootPodPeripheral: CBPeripheral!
        myManager = CBCentralManager(delegate: MyCentralManagerDelegate(), queue: nil)
        // TODO: connect to peripheral
        //myManager.connect(<#T##peripheral: CBPeripheral##CBPeripheral#>, options: <#T##[String : Any]?#>)
        
    }

    @IBAction func getStarted(_ sender: Any) {
        print("Starting!")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        // practice putting in an alert (yes this works)
       /* let alertController = UIAlertController(title: "BodyMonitor", message: "App View Loaded", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Let's Get Started!", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)*/
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

