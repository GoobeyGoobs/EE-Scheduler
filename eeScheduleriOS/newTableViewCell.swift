//
//  newTableViewCell.swift
//  eeScheduleriOS
//
//

import UIKit

class newTableViewCell: UITableViewCell {
    @IBOutlet var photoView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var tutorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
