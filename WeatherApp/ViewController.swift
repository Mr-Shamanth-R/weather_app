//
//  ViewController.swift
//  WeatherApp
//
//  Created by Shamanth R on 28/01/25.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var models = [Forecastday]()
    var hourlyModels = [Current]()
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    
    var current: WeatherModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        tableView.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)

                           
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = UIColor(red: 178/255.0, green: 165/255.0, blue: 255/255.0, alpha: 1.0)
        view.backgroundColor = UIColor(red: 178/255.0, green: 165/255.0, blue: 255/255.0, alpha: 1.0)
        navigationController?.navigationBar.barTintColor = UIColor(red: 178/255.0, green: 165/255.0, blue: 255/255.0, alpha: 1.0)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Weather Forecast"
        navigationController?.navigationBar.tintColor = .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpLocation()
    }
    
    func setUpLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation() {
        guard let long = currentLocation?.coordinate.latitude else { return }
        guard let lat = currentLocation?.coordinate.longitude else { return }
        print("Long: \(long), lat: \(lat)")
        let apiKey = "add your api key"
        let (currentDate, futureDate) = getCurrentAndFutureDate()
        let url = "https://api.weatherapi.com/v1/forecast.json?q=\(long),\(lat)&days=10&dt=\(currentDate),\(futureDate)&key=\(apiKey)"
        
        URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            // validate
            guard let data = data, error == nil else { return }
            // convert data to models
            var json: WeatherModel?
            do {
                json = try JSONDecoder().decode(WeatherModel.self, from: data)
            }
            catch {
                print("error \(error)")
            }
            guard let result = json else {
                return
            }
            let entries = result.forecast.forecastday
            self.models.append(contentsOf: entries)
            
            let current = result
            self.current = current
            
            self.hourlyModels = current.forecast.forecastday.first?.hour ?? []

            // update user interface
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
                self.tableView.tableHeaderView = self.createTableHeader()
            }
        }.resume()
    }
    
    func createTableHeader() -> UIView {
        let headerVIew = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 220))
        headerVIew.backgroundColor = UIColor(red: 73/255.0, green: 61/255.0, blue: 158/255.0, alpha: 1.0)
        
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.width-20, height: headerVIew.frame.size.height/4))
        let summeryLabel = UILabel(frame: CGRect(x: 10, y: 20 + locationLabel.frame.size.height, width: view.frame.width-20, height: headerVIew.frame.size.height/4))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20 + summeryLabel.frame.size.height, width: view.frame.width-20, height: headerVIew.frame.size.height/1))
        headerVIew.addSubview(locationLabel)
        headerVIew.addSubview(summeryLabel)
        headerVIew.addSubview(tempLabel)
        
        locationLabel.textAlignment = .center
        summeryLabel.textAlignment = .center
        tempLabel.textAlignment = .center
        
        locationLabel.textColor = .white
        summeryLabel.textColor = .white
        tempLabel.textColor = .white
        
        guard let currentWeather = self.current else { return UIView() }
        tempLabel.text = "\(currentWeather.current.tempF.description)°"
        locationLabel.text = "\(currentWeather.location.name), \(currentWeather.location.region), \(currentWeather.location.country)"
        locationLabel.numberOfLines = 0
        summeryLabel.text = currentWeather.current.condition.text
        
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)

        return headerVIew
    }

    func getCurrentAndFutureDate() -> (String, String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Customize as needed

        // Current date
        let currentDate = Date()
        let currentDateString = dateFormatter.string(from: currentDate)

        // Date 10 days in the future
        if let futureDate = Calendar.current.date(byAdding: .day, value: 10, to: currentDate) {
            let futureDateString = dateFormatter.string(from: futureDate)
            return (currentDateString, futureDateString)
        }

        return (currentDateString, "Error calculating future date")
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
            return 2 // Section 0: Hourly, Section 1: Daily Forecast
        }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Section 0: Hourly Forecast
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            cell.configure(with: hourlyModels)
            return cell
        } else {
            // Section 1: Daily Forecast
            let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
            cell.configure(with: models[indexPath.row])
            cell.backgroundColor = UIColor(red: 178/255.0, green: 165/255.0, blue: 255/255.0, alpha: 1.0)// Pass daily forecast data
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    
}
