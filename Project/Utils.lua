-- utility function for the rainbow thing
function HSVToRGB(h, s, v, a)
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    h = h % 360
    if h < 60 then
        return c, x, 0, a
    elseif h < 120 then
        return x, c, 0, a
    elseif h < 180 then
        return 0, c, x, a
    elseif h < 240 then
        return 0, x, c, a
    elseif h < 300 then
        return x, 0, c, a
    else
        return c, 0, x, a
    end
end

-- useful as LUA does the Python thing of not copying stuff
function shallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function drawHands(color)
    -- draw colored spheres for the hands
    for i, hand in ipairs(lovr.headset.getHands()) do
        local position = vec3(lovr.headset.getPosition(hand))
        local hand_quat = quat(lovr.headset.getOrientation(hand))
        lovr.graphics.setColor(color)
        lovr.graphics.sphere(position, .01)

        local x_axis = lovr.math.newVec3(-1, 0, 0)
        local y_axis = lovr.math.newVec3(0, -1, 0)
        local z_axis = lovr.math.newVec3(0, 0, -1)

        x_axis = hand_quat:mul(x_axis)
        y_axis = hand_quat:mul(y_axis)
        z_axis = hand_quat:mul(z_axis)

        lovr.graphics.setColor(1, 0, 0)
        lovr.graphics.line(position, position + z_axis * .05)
        lovr.graphics.setColor(0, 1, 0)
        lovr.graphics.line(position, position + x_axis * .05)
        lovr.graphics.setColor(0, 0, 1)
        lovr.graphics.line(position, position + y_axis * .05)

    end
end

function addVolumes()
    -- get hand positions
    local r_pos = vec3(lovr.headset.getPosition("right"))
    local l_pos = vec3(lovr.headset.getPosition("left"))

    -- draw connecting line
    lovr.graphics.setColor(1, 1, 0)
    lovr.graphics.setColor(0, 1, 0)
    lovr.graphics.line(0, 0, 0, 1, 0, 0)
    lovr.graphics.setColor(0, 0, 1)
    lovr.graphics.line(0, 0, 0, 0, 1, 0)
    lovr.graphics.setColor(1, 0, 0)
    lovr.graphics.line(0, 0, 0, 0, 0, 1)

    local width, height = lovr.headset.getBoundsDimensions()
    lovr.graphics.setColor(0.1, 0.1, 0.11)
    lovr.graphics.box("line", 0, 0, 0, width, .05, height)

    lovr.graphics.setColor(1, 1, 1)
    lovr.graphics.box("line", width / 2, 2, 0, 0.1, 4, height)
    lovr.graphics.box("line", -width / 2, 2, 0, 0.1, 4, height)
    lovr.graphics.box("line", 0, 2, height / 2, width, 4, 0.1)
    lovr.graphics.box("line", 0, 2, -height / 2, width, 4, 0.1)

    lovr.graphics.line({ r_pos, l_pos })

    -- get average point
    local avg_point = r_pos:add(l_pos):div(2)
    local avg_point_2 = vec3(avg_point)
    local height = avg_point[2]
    -- this edits r_pos
    -- draw average point
    lovr.graphics.setColor(1, 1, 1)
    lovr.graphics.sphere(avg_point, .01)

    -- get depth vector
    local r_pos = vec3(lovr.headset.getPosition("right"))
    local diff_vec = r_pos:sub(l_pos)
    local diff_bckp = vec3(diff_vec)

    --r_pos is no longer the same
    local depth_vec = diff_vec:cross(vec3(0, -1, 0)):normalize()
    local depth_point = avg_point_2:add(depth_vec:mul(0.5))

    lovr.graphics.setColor(1, 0, 1)
    lovr.graphics.line({ avg_point, depth_point })

    -- use raycast to find depth
    avg_point_2 = vec3(avg_point)
    depth_vec:normalize() -- reset depth_vec to have module 1
    local max_dim = math.max(lovr.headset.getBoundsDimensions())
    local end_point = avg_point_2:add(depth_vec:mul(max_dim))
    local collision_point = lovr.math.newVec3()
    local closest = math.huge
    avg_point_2 = vec3(avg_point)
    world:raycast(avg_point, end_point,
        function(shape, x, y, z, nx, ny, nz)
            closest = math.min(closest, avg_point_2:distance(vec3(x, y, z)))
            collision_point:set(x, y, z)
        end)
    local depth = collision_point:distance(avg_point)
    -- calculate volume center
    local volume_center = lovr.math.newVec3()
    avg_point_2 = vec3(avg_point)
    depth_vec:normalize()
    local rotation = quat(depth_vec)
    avg_point_2:add(depth_vec:mul(depth / 2))
    volume_center = avg_point_2:mul(vec3(1, .5, 1)) -- set volume centerbto be avg_p_2 with half the height


    lovr.graphics.setColor(0, 1, 1)
    lovr.graphics.sphere(volume_center, 0.03)
    local width = diff_bckp:length()

    lovr.graphics.box("line", volume_center, width, height, depth, rotation)
    if lovr.headset.wasPressed("right", 'trigger') then
        local volume = world:newBoxCollider((volume_center), width, height, depth)
        volume:setKinematic(true)
        volume:setOrientation(rotation)
        table.insert(volumes, volume)
    end

end

function drawAxes()
    lovr.graphics.setColor(0, 1, 0)
    lovr.graphics.line(0, 0, 0, 1, 0, 0)
    lovr.graphics.setColor(0, 0, 1)
    lovr.graphics.line(0, 0, 0, 0, 1, 0)
    lovr.graphics.setColor(1, 0, 0)
    lovr.graphics.line(0, 0, 0, 0, 0, 1)
end 

function drawBounds()
    local width, height = lovr.headset.getBoundsDimensions()
    if width == 0 or height == 0 then
        return
    end
    lovr.graphics.setColor(0.1, 0.1, 0.11)
    lovr.graphics.box("line", 0, 0, 0, width, .05, height)

    lovr.graphics.setColor(1, 1, 1)
    lovr.graphics.box("line", width / 2, 2, 0, 0.1, 4, height)
    lovr.graphics.box("line", -width / 2, 2, 0, 0.1, 4, height)
    lovr.graphics.box("line", 0, 2, height / 2, width, 4, 0.1)
    lovr.graphics.box("line", 0, 2, -height / 2, width, 4, 0.1)
end
