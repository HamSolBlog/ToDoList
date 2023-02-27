//
//  ToDoCell.swift
//  ToDoList
//
//  Created by 김정운 on 2023/01/21.
//

import UIKit

class ToDoCell: UITableViewCell {

    @IBOutlet weak var topTitleLabel: UILabel!
    
    @IBOutlet weak var prioirtyView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet var photoView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
