import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class HomeViewController: UIViewController {

    @IBOutlet var startButton: ConnectionButton!
    @IBOutlet var tableView: UITableView!

    private let disposeBag = DisposeBag()
    private let dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, HomeCellViewModel>>(configureCell: { dataSource, tableView, indexPath, item in
        let cell = HomeTableViewCell.dequeueFrom(tableView: tableView, for: indexPath)
        cell.viewModel = item
        return cell
    })


    var createViewModel: HomeViewModel.CreateHandler!
    private var viewModel: HomeViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = createViewModel(())

        viewModel.measurements
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        viewModel.startButtonState
            .drive(startButton.rx.connectionState)
            .disposed(by: disposeBag)

        startButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.startPressed()
        }).disposed(by: disposeBag)
    }
}
