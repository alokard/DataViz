import UIKit
import CoreData
import RxSwift

class ViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext? = nil
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.rx.controlEvent(.valueChanged).subscribe(onNext: { [unowned self] in
            do {
                try self.fetchedResultsController.performFetch()
            } catch { }
            self.tableView?.reloadData()
            guard let refreshControl = self.refreshControl else { return }
            refreshControl.endRefreshing()
        }).disposed(by: disposeBag)
        self.refreshControl = refreshControl
    }

    lazy var fetchedResultsController: NSFetchedResultsController<Temperature> =
    {
        let fetchRequest: NSFetchRequest<Temperature> = Temperature.fetchRequest()
        fetchRequest.fetchBatchSize = 20

        let sortDescriptor = NSSortDescriptor(key: "measurementDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: self.managedObjectContext!,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
        aFetchedResultsController.delegate = self

        do {
            try aFetchedResultsController.performFetch()
        } catch { }

        return aFetchedResultsController
    }()
}

extension ViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView?.reloadData()
    }
}

extension ViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        let count = self.fetchedResultsController.sections?.count
        return count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.fetchedResultsController.sections?[section].numberOfObjects
        return count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let temperature = self.fetchedResultsController.object(at: indexPath)
        cell.textLabel!.text = String(temperature.value)
        return cell
    }
}

