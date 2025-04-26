func ceilingDivision<T: BinaryInteger>(_ a: T, _ b: T) -> T
{
    var result = a / b
    if a % b != 0 && (a > 0) == (b > 0) {
        result += 1
    }
    return result
}

func bitMask<T: FixedWidthInteger>(bits: Int) -> T
{
    return (1 << bits) - 1
}

func bitCut<T: FixedWidthInteger>(_ value: T, position: Int, count: Int) -> T
{
    return (value >> position) & bitMask(bits: count)
}

func signExtend(_ value: UInt64, bits: Int) -> Int64
{
    return Int64(bitPattern: value << (64 - bits)) >> (64 - bits)
}
