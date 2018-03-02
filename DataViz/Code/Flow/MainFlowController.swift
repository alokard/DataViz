import UIKit

class MainFlowController: FlowController {
    private let context: FlowContext
    private let factory: FlowsFactory
    private let navigation: NavigationRouter

    init(context: FlowContext, navigation: NavigationRouter, flowsFactory factory: FlowsFactory) {
        self.context = context
        self.navigation = navigation
        self.factory = factory
    }

    func start() {
        showStartScreen()
    }

    func showStartScreen() {
        let controller = HomeViewController.from(storyboard: .main)
        let handlers = HomeViewModelImpl.HandlersContainer(showDetails: { _ in })
        controller.createViewModel = HomeViewModelImpl.create(context: context, data: nil, handlers: handlers)
        navigation.setViewControllers([controller], animated: false)
    }

    func showTemperatureScreen() {
        let controller = TemperatureViewController.from(storyboard: .main)
//        controller.managedObjectContext = context.coreDataService.viewContext
        navigation.pushViewController(controller, animated: true)
    }
}
