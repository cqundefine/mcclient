struct VarInt: ExpressibleByIntegerLiteral, Equatable
{
    var value: UInt32

    typealias IntegerLiteralType = UInt32

    init(integerLiteral value: UInt32)
    {
        self.value = value
    }

    init(_ value: UInt32)
    {
        self.value = value
    }

    var size: UInt32 {
        var remaining = value
        var count: UInt32 = 0
        while true {
            count += 1

            if (remaining & ~0x7F) == 0 {
                break
            }

            remaining >>= 7
        }
        return count
    }
}
