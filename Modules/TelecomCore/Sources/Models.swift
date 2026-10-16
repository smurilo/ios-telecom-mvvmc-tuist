import Foundation

public struct PlanUsage: Equatable, Sendable {
    public let planName: String
    public let msisdn: String
    public let dataTotalMB: Int
    public let dataUsedMB: Int
    public let renewsOn: Date

    public init(planName: String, msisdn: String, dataTotalMB: Int, dataUsedMB: Int, renewsOn: Date) {
        self.planName = planName
        self.msisdn = msisdn
        self.dataTotalMB = dataTotalMB
        self.dataUsedMB = dataUsedMB
        self.renewsOn = renewsOn
    }

    public var usedRatio: Double { dataTotalMB == 0 ? 0 : min(1, Double(dataUsedMB) / Double(dataTotalMB)) }
    public var remainingMB: Int { max(0, dataTotalMB - dataUsedMB) }
}

public struct Invoice: Equatable, Sendable, Identifiable {
    public enum Status: String, Sendable { case open, paid, overdue }
    public let id: String
    public let month: String
    public let amount: Decimal
    public let dueDate: Date
    public let status: Status
    public let barcode: String

    public init(id: String, month: String, amount: Decimal, dueDate: Date, status: Status, barcode: String) {
        self.id = id
        self.month = month
        self.amount = amount
        self.dueDate = dueDate
        self.status = status
        self.barcode = barcode
    }
}

public struct Offer: Equatable, Sendable, Identifiable {
    public let id: String
    public let title: String
    public let extraMB: Int
    public let price: Decimal

    public init(id: String, title: String, extraMB: Int, price: Decimal) {
        self.id = id
        self.title = title
        self.extraMB = extraMB
        self.price = price
    }
}

public enum TelecomError: Error, Equatable {
    case network
    case insufficientCredit
}
