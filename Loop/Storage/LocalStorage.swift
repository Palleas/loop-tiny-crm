import Foundation
import ReactiveSwift
import Result
import CoreData
import LoopKit

final class LocalStorage {
    enum Error: Swift.Error {
        case savingError(underlyingError: Swift.Error)
    }

    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func save<T: Storable>(_ storable: T) -> SignalProducer<T.Stored, Error> {
        let context = container.newBackgroundContext()
        let scheduler = CoreDataScheduler(context: context)

        let saving = Result<T.Stored, Error> { () -> T.Stored in
            let stored = storable.stored(in: context)
            try context.save()

            return stored
        }

        return SignalProducer(result: saving)
        .start(on: scheduler)
    }
}

class CoreDataScheduler: Scheduler {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func schedule(_ action: @escaping () -> Void) -> Disposable? {
        let d = AnyDisposable { [weak self] in
            self?.context.perform {
                action()
            }
        }

        return d
    }

    
}

protocol Storable {
    associatedtype Stored: NSManagedObject

    func stored(in: NSManagedObjectContext) -> Stored
}

extension TwitterUser: Storable {

    func stored(in context: NSManagedObjectContext) -> Lead {
        let newLead = Lead(entity: Lead.entity(), insertInto: context)
        newLead.id = self.id.string
        newLead.name = self.name
        newLead.screenName = self.screenName
        newLead.profilePicture = self.profileImage?.absoluteString

        return newLead
    }
}


enum CoreDataError: Error {
    case loadingError(Error)
}

extension Reactive where Base: NSPersistentContainer {

    func load() -> SignalProducer<NSPersistentContainer, CoreDataError> {
        return SignalProducer { [base = self.base] sink, _ in
            base.loadPersistentStores { description, error in
                if let error = error {
                    sink.send(error: .loadingError(error))
                    return
                }

                sink.send(value: base)
                sink.sendCompleted()
            }
        }
    }
}