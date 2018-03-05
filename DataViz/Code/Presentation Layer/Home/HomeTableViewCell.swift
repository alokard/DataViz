import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var dateTimeLabel: UILabel!

    var viewModel: HomeCellViewModel! {
        didSet {
            nameLabel.text = viewModel.identity
            valueLabel.text = viewModel.formattedValue
            dateTimeLabel.text = viewModel.formattedDate
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        backgroundImageView.isHighlighted = highlighted
    }
}
