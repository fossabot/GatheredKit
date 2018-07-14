import Foundation

public struct GenericValue<ValueType, UnitType: Unit>: Value {

    public typealias UpdateListener = (_ sourceProperty: GenericValue<ValueType, UnitType>) -> Void

    /// A user-friendly name that represents the value, e.g. "Latitude", "Longitude"
    public let name: String

    /// The value powering this `GenericValue`
    public let backingValue: ValueType

    /// A human-friendly formatted value
    /// Note that this may differ from the result of `unit.formattedString(for:)`
    public let formattedValue: String?

    /// The unit the value is measured in
    public let unit: UnitType

    /// The date that the value was created
    /// If a system-provided date is available it is used
    public let date: Date

    internal init(
        name: String,
        backingValue: ValueType,
        formattedValue: String? = nil,
        unit: UnitType,
        date: Date = Date()
    ) {
        self.name = name
        self.backingValue = backingValue
        self.formattedValue = formattedValue
        self.unit = unit
        self.date = date
    }

    /**
     Updates the data backing this `SourceProperty`
     - parameter backingValue: The new value of the data
     - parameter formattedValue: The new human-friendly formatted value. Defaults to `nil`
     - parameter date: The date and time the `value` was recorded. Defaults to the current date and time
     */
    public mutating func update(backingValue: ValueType, formattedValue: String? = nil, date: Date = Date()) {
        self = GenericValue(name: name, backingValue: backingValue, formattedValue: formattedValue, unit: unit, date: date)
    }

}

extension GenericValue: Equatable where ValueType: Equatable {

    public static func == (lhs: GenericValue<ValueType, UnitType>, rhs: GenericValue<ValueType, UnitType>) -> Bool {
        return lhs.backingValue == rhs.backingValue
    }

}
