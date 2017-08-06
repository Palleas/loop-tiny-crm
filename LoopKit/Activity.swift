import Foundation

/// Represents a task to be completed
public enum Activity: String {
    case call
    case coffee
    case tshirt
    case talent
    case sales
    case interview
    case event
    case priority
    case partnership
}

extension Activity: AutoList {}
