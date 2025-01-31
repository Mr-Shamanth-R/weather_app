//
//  WeatherTableViewCell.swift
//  WeatherApp
//
//  Created by Shamanth R on 28/01/25.
//

import UIKit
import Kingfisher

class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static let identifier = "WeatherTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
    
    func configure(with model: Forecastday) {
        self.lowTempLabel.text = "\(model.day.mintempF)°"
        self.highTempLabel.text = "\(model.day.maxtempF)°"
        self.lowTempLabel.textAlignment = .center
        self.highTempLabel.textAlignment = .center

        self.dayLabel.text = getDayForDate(Date(timeIntervalSince1970: Double(model.dateEpoch)))
        let imageURL = URL(string: "https:"+model.day.condition.icon)
        self.iconImageView.kf.setImage(with: imageURL)
    }
    
    func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Monday
        return formatter.string(from: inputDate)
    }
    
}
