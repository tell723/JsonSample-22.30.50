//
//  ViewController.swift
//  JsonSample
//
//  Created by 渡邊輝夢 on 2019/12/28.
//  Copyright © 2019 Terumu Watanabe. All rights reserved.
//

import UIKit
import SwiftyJSON
import UserNotifications
import CoreLocation

class ViewController: UIViewController, UNUserNotificationCenterDelegate, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var resister: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    
    var locationManager: CLLocationManager!
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var location = ""
    var weather = "" {
        willSet{
            switch newValue {
            case "":
                message = "天気情報が所得されていません"
            case "Rain":
                message = "傘忘れんなよ！！"
            default:
                message =  "傘はいりません"
            }
        }
    }
    var message = ""
    let baseUrl = "https://api.openweathermap.org/data/2.5/weather?"
    let apiKey = "06c2c12ef09f140ac6e2270864976fc4"
    
    var hour: Int!
    var min: Int!
    let hourList = [Int](0...23)
    let minList = [Int](0...59)
    @IBOutlet weak var hourPickerView: UIPickerView!
    @IBOutlet weak var minPickerView: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupLocationManager()
        
        hourPickerView.delegate = self
        hourPickerView.dataSource = self
        minPickerView.delegate = self
        minPickerView.dataSource = self
        
        self.resister.isEnabled = true
        self.locationLabel.text = "Location:"
    }
    
    @IBAction func resisterButton(_ sender: Any) {
        
        let content = UNMutableNotificationContent()
        content.title = self.message
        content.body = self.location
        content.sound = UNNotificationSound.default
        
        var notificationTime = DateComponents()
        notificationTime.hour = self.hour
        notificationTime.minute = self.min
        
        let tirgger: UNNotificationTrigger
        tirgger = UNCalendarNotificationTrigger(dateMatching: notificationTime,
                                                repeats: false)
        
        let request = UNNotificationRequest(identifier: "Timer",
                                            content: content,
                                            trigger: tirgger)
        
        UNUserNotificationCenter.current().add(request,
                                               withCompletionHandler: nil)
        
        if let lat = self.latitude, let lon = self.longitude {
            print("lat: \(lat) lon: \(lon)")
        }
        if location == "" {
            self.locationLabel.text = "Location: 位置情報が取得できません"
        } else {
            self.locationLabel.text = "Location: \(location)"
        }
        
        self.resister.isEnabled = false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return hourList.count
        } else if pickerView.tag == 1 {
            return minList.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return String(hourList[row])
        } else if pickerView.tag == 1 {
            return String(minList[row])
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        if pickerView.tag == 0 {
            self.hour = hourList[row]
        } else if pickerView.tag == 1 {
            self.min = minList[row]
        }
        self.resister.isEnabled = true
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        
        locationManager.requestAlwaysAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways {
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        
        guard let lat = latitude, let lon = longitude else { return }
        print("lat: \(lat) lon: \(lon)")
        let jsonString = "\(self.baseUrl)lat=\(lat)&lon=\(lon)&appid=\(self.apiKey)"
        guard let url = URL(string: jsonString) else { return }
        
        let task: URLSessionTask = URLSession.shared.dataTask(with: url,
                                                              completionHandler: {data, response, error in
            guard let data = data else { return }
            do {
                let json = try? JSON(data: data)
                self.weather = json!["weather"][0]["main"].stringValue
                self.location = json!["name"].stringValue
                print("weather: \(self.weather)")
                print("name: \(self.location)")
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
           completionHandler([.alert, .badge, .sound])
       }
}

