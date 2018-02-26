import Foundation

protocol FlowsFactory {
    func createMainFlow(navigation: NavigationRouter) -> FlowController
}

class FlowsFactoryImpl {
    fileprivate let context: FlowContext

    init(context: FlowContext) {
        self.context = context
    }
}

extension FlowsFactoryImpl: FlowsFactory {
    func createMainFlow(navigation: NavigationRouter) -> FlowController {
        return MainFlowController(context: context, navigation: navigation, flowsFactory: self)
    }
}
