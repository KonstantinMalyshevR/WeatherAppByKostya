//
//  ViewController.swift
//  WeatherAppByKostya
//
//  Created by Konstantin Malyshev on 11.02.19.
//  Copyright © 2019 Konstantin Malyshev. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var editView: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.isEditable = false
        progress.hidesWhenStopped = true
        locationManager.delegate = self
        determineMyCurrentLocation();
    }
    
    func determineMyCurrentLocation() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation();
            return
            
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation();
            break
            
        case .denied, .restricted:
            showMessage(title: "Внимание!", value: "Введите название города, определение местоположения запрещено!")
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation:CLLocation = locations.last {
            let lat = userLocation.coordinate.latitude
            let lon = userLocation.coordinate.longitude
            
            let parameters: Parameters = ["lat": lat, "lon": lon, "appid": "172e5ab3bc3414d8c7261084742e7f7f", "units":"metric"]
            sendRequest(parameters: parameters)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    @IBAction func buttonClick(_ sender: Any) {
        if(editView.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""){
            let city: String = editView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let parameters: Parameters = ["q": city, "appid": "172e5ab3bc3414d8c7261084742e7f7f", "units":"metric"]
            sendRequest(parameters: parameters)
        }else{
            showMessage(title: "Внимание!", value: "Введите название своего города")
        }
    }
    
    func sendRequest(parameters: Parameters){
        self.textView.text = ""
        progress.startAnimating();
        
        let url = "https://api.openweathermap.org/data/2.5/weather"
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            self.progress.stopAnimating();
            if let json = response.result.value as? [String: Any] {
                print("JSON: \(json)")
                guard let cod = json["cod"] as? Int, cod == 200 else {
                    if let message = json["message"] as? String {
                        self.textView.text = "Произошла ошибка! Сообщение: \(message)"
                    }else{
                        self.textView.text = "Произошла ошибка, own code 1"
                    }
                    return
                }
                
                var main_str: String! = ""
                
                if let name = json["name"] as? String {
                    main_str = main_str + "Город: \(name)\n"
                }
                
                if let coord = json["coord"] as? [String: Any] {
                    main_str = main_str + "\nГеографические координаты:\n"
                    if let lat = coord["lat"] as? Float {
                        main_str = main_str + "Широта: \(lat)\n"
                    }
                    if let lon = coord["lon"] as? Float {
                        main_str = main_str + "Долгота: \(lon)\n"
                    }
                }
                
                if let main = json["main"] as? [String: Any] {
                    main_str = main_str + "\nОсновные данные:\n"
                    if let temp = main["temp"] as? Int {
                        main_str = main_str + "Температура: \(temp) С\n"
                    }
                    if let pressure = main["pressure"] as? Int {
                        main_str = main_str + "Давление: \(pressure) мм.рт.ст\n"
                    }
                    if let humidity = main["humidity"] as? Int {
                        main_str = main_str + "Влажность: \(humidity) %\n"
                    }
                }
                
                if let wind = json["wind"] as? [String: Any] {
                    main_str = main_str + "\nВетер:\n"
                    if let deg = wind["deg"] as? Int {
                        main_str = main_str + "Направление: \(deg) град.\n"
                    }
                    if let speed = wind["speed"] as? Int {
                        main_str = main_str + "Скорость: \(speed) м/с\n"
                    }
                }
                
                self.textView.text = main_str
            }else{
                self.textView.text = "Произошла ошибка, own code 2"
            }
        }
    }
    
    func showMessage(title: String, value: String){
        let alert = UIAlertController(title: title, message: value, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Понятно", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
