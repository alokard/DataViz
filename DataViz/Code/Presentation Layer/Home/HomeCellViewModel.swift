import Differentiator

class HomeCellViewModel: Equatable {
    typealias Identity = String
    let identity: String

    init(identity: String) {
        self.identity = identity
    }

    static func ==(lhs: HomeCellViewModel, rhs: HomeCellViewModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension HomeCellViewModel: IdentifiableType { }
