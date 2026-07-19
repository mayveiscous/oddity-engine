local function typeName(v)
    if type(v) == "table" then
        local s = rawget(v, "_state")
        if s then
            if s._isVector3 then return "Vector3" end
            if s._isVector2 then return "Vector2" end
            if s._isColor3 then return "Color3" end
            if s.ClassName then return "Instance" end
        end
    end
    return type(v)
end

return { typeName = typeName }