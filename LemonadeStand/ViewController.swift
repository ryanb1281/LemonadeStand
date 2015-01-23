//
//  ViewController.swift
//  LemonadeStand
//
//  Created by Ryan Budish on 10/27/14.
//  Copyright (c) 2014 Ryan Budish. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var lemonInventoryLabel: UILabel!
    @IBOutlet weak var iceInventoryLabel: UILabel!
    @IBOutlet weak var lemonCartLabel: UILabel!
    @IBOutlet weak var iceCartLabel: UILabel!
    @IBOutlet weak var lemonMixLabel: UILabel!
    @IBOutlet weak var iceMixLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    
    var wallet: Int = 10
    var lemonInventory: Int = 1
    var iceInventory: Int = 1
    
    var lemonCart: Int = 0
    var iceCart: Int = 0
    
    var lemonMix: Int = 0
    var iceMix: Int = 0
    
    var initialLemonInventory: Int = 1
    var initialIceInventory: Int = 1
    
    var currentWeather: String = "mild"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buyLemonPlusPressed(sender: UIButton) {
        if wallet >= 2 {
            wallet -= 2
            lemonInventory++
            lemonCart++
            refreshView()
        } else {
            showAlertWithText(header: "Not Enough Money", message: "You don't have sufficient funds")
        }
        
    }
    
    @IBAction func buyLemonMinusPressed(sender: UIButton) {
        // be sure that you don't have too many lemons in mix
        if lemonCart <= 0 {
            showAlertWithText(header: "No Lemons In Cart", message: "You have no lemons")
        } else {
            wallet += 2
            lemonCart--
            if (lemonMix > initialLemonInventory + lemonCart) && lemonMix > 0 {
                lemonMix--
            } else {
                lemonInventory--
            }
            refreshView()
        }
    }
    
    
    @IBAction func buyIcePlusPressed(sender: UIButton) {
        if wallet >= 1 {
            wallet -= 1
            iceInventory++
            iceCart++
            refreshView()
        } else {
            showAlertWithText(header: "Not Enough Money", message: "You don't have sufficient funds")
        }

    }
    
    @IBAction func buyIceMinusPressed(sender: UIButton) {
        // be sure to check mix
        if iceCart <= 0 {
            showAlertWithText(header: "No Ice In Cart", message: "You have no ice")
        } else {
            wallet += 1
            iceCart--
            if (iceMix > initialIceInventory + iceCart) && iceMix > 0 {
                iceMix--
            } else {
                iceInventory--
            }
            refreshView()
        }

    }
    
    
    @IBAction func mixLemonPlusPressed(sender: UIButton) {
        if lemonInventory >= 1 {
            lemonMix++
            lemonInventory--
            refreshView()
        } else {
            showAlertWithText(header: "No Lemons In Inventory", message: "You are out of lemons")
        }
    }
    
    @IBAction func mixLemonMinusPressed(sender: UIButton) {
        if lemonMix >= 1 {
            lemonMix--
            lemonInventory++
            refreshView()
        } else {
            showAlertWithText(header: "No Lemons In Mix", message: "You cannot have fewer than 0 lemons")
        }
    }
    
    @IBAction func mixIcePlusPressed(sender: UIButton) {
        if iceInventory >= 1 {
            iceMix++
            iceInventory--
            refreshView()
        } else {
            showAlertWithText(header: "No Ice In Inventory", message: "You are out of ice")
        }
    }
    
    @IBAction func mixIceMinusPressed(sender: UIButton) {
        if iceMix >= 1 {
            iceMix--
            iceInventory++
            refreshView()
        } else {
            showAlertWithText(header: "No Ice In Mix", message: "You cannot have fewer than 0 ice cubes")
        }
    }
    
    
    @IBAction func startDayPressed(sender: UIButton) {
        
        if lemonMix == 0  {
            println("Lemon Mix is \(lemonMix)")
            showAlertWithText(header: "Missing Ingredients", message: "You need at least 1 lemon and 1 ice cube")
        } else if iceMix == 0 {
            println("Ice Mix is \(iceMix)")
            showAlertWithText(header: "Missing Ingredients", message: "You need at least 1 lemon and 1 ice cube")
        } else {
            let kLemonadeRatio: Double = Double(lemonMix / iceMix)
            let kNumberOfCustomers: Int = generateNumberOfCustomers()
            var customerPreferences: [Double]
            var profit: Int = 0

            println("There are \(kNumberOfCustomers) customers today")
            customerPreferences = generateCustomerPreferences(kNumberOfCustomers)
            profit = generateSales(kLemonadeRatio, customerPreferences: customerPreferences)
            wallet += profit
            refreshView()
            setUpNextDay()
        }
    }

    func updateInventoryView() {
        walletLabel.text = "$\(wallet)"
        if lemonInventory == 1 {
            lemonInventoryLabel.text = "\(lemonInventory) Lemon"
        } else {
            lemonInventoryLabel.text = "\(lemonInventory) Lemons"
        }
        if iceInventory == 1 {
            iceInventoryLabel.text = "\(iceInventory) Ice Cube"
        } else {
            iceInventoryLabel.text = "\(iceInventory) Ice Cubes"
        }
        
    }
    
    func refreshView() {
        updateInventoryView()
        iceCartLabel.text = "\(iceCart)"
        lemonCartLabel.text = "\(lemonCart)"
        iceMixLabel.text = "\(iceMix)"
        lemonMixLabel.text = "\(lemonMix)"
    }
    
    func showAlertWithText (header: String = "Warning", message: String) {
        var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func setUpNextDay() {
        if testIfSufficientFunds() {
            initialIceInventory = iceInventory
            initialLemonInventory = lemonInventory
            lemonMix = 0
            iceMix = 0
            lemonCart = 0
            iceCart = 0
            refreshView()
        } else {
            showAlertWithText(header: "Game Over", message: "Insufficient Funds to Continue")
        }
    }
    
    func generateNumberOfCustomers() -> Int {
        var numCustomers = Int(arc4random_uniform(UInt32(10))) + 1
        println("Inside GenerateNumberOfCustomers: Customers = \(numCustomers)")
        currentWeather = generateWeatherConditions()
        switch currentWeather {
        case "cold":
            println("The weather today is cold")
            numCustomers -= 3
            if numCustomers < 0 {
                numCustomers = 0
            }
            weatherImage.image = UIImage(named: "Cold")
        case "mild":
            println("The weather today is mild")
            weatherImage.image = UIImage(named: "Mild")
        case "warm":
            println("The weather today is warm")
            numCustomers += 4
            weatherImage.image = UIImage(named: "Warm")
        default:
            println("default case - something went wrong with the weather")
            weatherImage.image = UIImage(named: "Cold")
            
        }
        println("Adjusted number of customers is \(numCustomers)")
        return numCustomers
    }
    
    func generateWeatherConditions() -> String {
        var weather = Int(arc4random_uniform(3))
        
        switch weather {
        case 0:
            return "cold"
        case 1:
            return "mild"
        case 2:
            return "warm"
        default:
            return "mild"
        }
        
    }
    
    func generateCustomerPreferences(numberOfCustomers: Int) -> [Double] {
        var preferenceArray: [Double] = []
        var preference: Double
        let kTen = 10.00
        
        for i in 1...numberOfCustomers {
            preference = Double(arc4random_uniform(11)) / kTen
            preferenceArray.append(preference)
        }
        return preferenceArray
    }
    
    func generateSales(lemonadeRatio: Double, customerPreferences: [Double]) -> Int {
        var profit: Int = 0
        var numberOfSales: Int = 0
        var preference: Double
        
        println("Today's lemonade is " + describeLemonade(lemonadeRatio))
        
        for var i = 0; i < customerPreferences.count; i++ {
            preference = customerPreferences[i]
            if preference < 0.4 && lemonadeRatio > 1 {
                println("Customer \(i + 1): favors " + describePreference(preference) + " lemonade. Sale!")
                numberOfSales++
                profit++
            } else if preference >= 0.4 && preference < 0.6 && lemonadeRatio == 1 {
                println("Customer \(i + 1): favors " + describePreference(preference) + " lemonade. Sale!")
                numberOfSales++
                profit++
            } else if preference >= 0.6 && lemonadeRatio < 1 {
                println("Customer \(i + 1): favors " + describePreference(preference) + " lemonade. Sale!")
                numberOfSales++
                profit++
            } else {
                println("Customer \(i + 1): favors " + describePreference(preference) + " lemonade. No Sale :(")
            }
        }
        println("Today there were \(numberOfSales) sales")
        return profit
    }
    
    func describeLemonade(lemonadeRatio: Double) -> String {
        if lemonadeRatio > 1 {
            return "acidic"
        } else if lemonadeRatio == 1 {
            return "equal portioned"
        } else {
            return "diluted"
        }
    }
    
    func describePreference(preference: Double) -> String {
        if preference < 0.4 {
            return "acidic"
        } else if preference >= 0.4 && preference < 0.6 {
            return "equal portioned"
        } else {
            return "diluted"
        }
    }
    
    func testIfSufficientFunds() -> Bool {
        var amountNeeded: Int = 0
        if lemonInventory == 0 {
            amountNeeded += 2
        }
        if iceInventory == 0 {
            amountNeeded += 1
        }
        if amountNeeded > wallet {
            return false
        } else {
            return true
        }
    }

}

