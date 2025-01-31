//
//  WeatherCollectionViewCell.swift
//  WeatherApp
//
//  Created by Shamanth R on 31/01/25.
//

import UIKit
import Kingfisher

class WeatherCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "WeatherCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
    }
                     
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code if any
    }
    
    func configure(with model: Current) {
        // Set the temperature label text
        self.tempLabel.text = "\(model.tempF)"
        
        // Prepare the image URL and set the image using Kingfisher
        let imageURL = URL(string: "https:" + model.condition.icon)
        self.iconImageView.contentMode = .scaleAspectFit
        self.iconImageView.kf.setImage(with: imageURL)
    }
}
