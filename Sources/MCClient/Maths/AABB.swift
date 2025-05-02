import cglm

fileprivate func closeRound(_ value: Float, threshold: Float = 0.1) -> Float
{
    if abs(floorf(value) - value) <= threshold {
        return roundf(value)
    }
    return value
}

struct AABB
{
    let min: Vector3
    let max: Vector3

    init(min: Vector3, max: Vector3)
    {
        assert(min.x < max.x)
        assert(min.y < max.y)
        assert(min.z < max.z)

        self.min = Vector3(closeRound(min.x), closeRound(min.y), closeRound(min.z))
        self.max = Vector3(closeRound(max.x), closeRound(max.y), closeRound(max.z))
    }

    func intersects(other: AABB) -> Bool
    {
        return min.x < other.max.x && max.x > other.min.x && min.y < other.max.y && max.y > other.min.y && min.z < other.max.z && max.z > other.min.z
    }

    func intersects(others: [AABB]) -> Bool
    {
        for aabb in others {
            if intersects(other: aabb) {
                return true
            }
        }
        return false
    }
}
