import Foundation

public enum Formatters {
    public static func gigabytes(fromMB mb: Int) -> String {
        let gb = Double(mb) / 1024
        return gb >= 10 ? String(format: "%.0f GB", gb) : String(format: "%.1f GB", gb).replacingOccurrences(of: ".", with: ",")
    }

    public static func money(_ value: Decimal) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.decimalSeparator = ","
        f.groupingSeparator = "."
        return "R$ " + (f.string(from: value as NSDecimalNumber) ?? "0,00")
    }
}
