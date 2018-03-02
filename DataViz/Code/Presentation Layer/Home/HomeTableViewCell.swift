import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet var backgroundImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        backgroundImageView.isHighlighted = highlighted
    }
}
