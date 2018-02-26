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
        let controller = ViewController.from(storyboard: .main)
        controller.managedObjectContext = context.coreDataService.viewContext
        navigation.setViewControllers([controller], animated: false)
    }
}
