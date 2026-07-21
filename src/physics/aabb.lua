local AABB = {}

function AABB.fromBlock(block)
    assert(block, "Block is nil")
    assert(block.Position, "Block has no Position")
    assert(block.Size, "Block has no Size")
    
    local pos, size = block.Position, block.Size
    return {
        minX = pos.X - size.X / 2, maxX = pos.X + size.X / 2,
        minY = pos.Y - size.Y / 2, maxY = pos.Y + size.Y / 2,
        minZ = pos.Z - size.Z / 2, maxZ = pos.Z + size.Z / 2,
    }
end

function AABB.overlaps(a, b)
    return a.minX < b.maxX and a.maxX > b.minX
       and a.minY < b.maxY and a.maxY > b.minY
       and a.minZ < b.maxZ and a.maxZ > b.minZ
end

return AABB