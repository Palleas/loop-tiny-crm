import Foundation
import ReactiveSwift
import Result
import CoreData
import BirdNest
import os.log

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

    func list<T: Storable>() -> Result<[T], Error> {
        return Result<[T], Error> {
            let request = T.Stored.fetchRequest()
            let results: [T.Stored] = try container.viewContext.fetch(request) as! [T.Stored] // meh
            return try results.map(T.init)
        }

    }
}

class CoreDataScheduler: Scheduler {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func schedule(_ action: @escaping () -> Void) -> Disposable? {
        let d = AnyDisposable()

        context.perform {
            guard !d.isDisposed else {
                os_log("CoreDataScheduler is disposed")
                return
            }

            action()
        }

        return d
    }
}

protocol Storable {
    associatedtype Stored: NSManagedObject

    init(from: Stored) throws

    func stored(in context: NSManagedObjectContext) -> Stored
}

//extension TwitterUser: Storable {

//    init(from lead: Lead) throws {
//        guard let id = lead.id else {
//            throw CoreDataError.missingKey("id")
//        }
//
//        // TODO: store INT in database
//        let f = NumberFormatter()
//        self.id = ID<TwitterUser>(from: f.number(from: id)?.intValue ?? 0)
//
//        guard let screenName = lead.screenName else {
//            throw CoreDataError.missingKey("screenName")
//        }
//        self.screenName = screenName
//
//        guard let name = lead.name else {
//            throw CoreDataError.missingKey("name")
//        }
//        self.name = name
//
//        if let picture = lead.profilePicture, let url = URL(string: picture) {
//            self.profileImage = url
//        } else {
//            self.profileImage = nil
//        }
//    }

//    func stored(in context: NSManagedObjectContext) -> Lead {
//        let newLead = Lead(entity: Lead.entity(), insertInto: context)
////        newLead.id = self.id.string
////        newLead.name = self.name
////        newLead.screenName = self.screenName
////        newLead.profilePicture = self.profileImage?.absoluteString
//
//        return newLead
//    }
//}

enum CoreDataError: Error {
    case loadingError(Error)
    case missingKey(String)
}

extension Reactive where Base: NSPersistentContainer {

    func load() -> SignalProducer<NSPersistentContainer, CoreDataError> {
        return SignalProducer { [base = self.base] sink, _ in
            base.loadPersistentStores { _, error in
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
