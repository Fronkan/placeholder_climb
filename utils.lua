function sign(val)
    if val < 0 then
        return -1
    else
        return 1
    end

end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end

function clamp_abs(val, max)
    if math.abs(val) <= math.abs(max) then
        return val
    else
        return sign(val) * max
    end
end
