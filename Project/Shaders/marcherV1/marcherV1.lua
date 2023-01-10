shader = lovr.graphics.newShader(lovr.filesystem.read("shader.vert"), lovr.filesystem.read("shader.frag"))
flight = {
    viewOffset = lovr.math.newVec3(0, 0, 0),
    thumbstickDeadzone = 0.3,
    speed = 1
}
shader:send('viewOffset', { flight.viewOffset:unpack() })
scale = 1.
max_scale = 32
shader:send("scale", scale)
shader:send("time", 0.0)
palette = lovr.graphics.newTexture("./Assets/Palette1.png")
shader:send("palette", palette)
State["B"] = true

function flight()
    local x, y = lovr.headset.getAxis('right', 'thumbstick')
    local direction = quat(lovr.headset.getOrientation("head")):direction()
    if math.abs(x) > flight.thumbstickDeadzone then
      local strafeVector = quat(-math.pi / 2, 0, 1, 0):mul(vec3(direction))
      flight.viewOffset:add(strafeVector * x * flight.speed * dt)
    end
    if math.abs(y) > flight.thumbstickDeadzone then
      flight.viewOffset:add(direction * y * flight.speed * dt)
    end
    shader:send('viewOffset', {flight.viewOffset:unpack()})
end

function rescale()
    scale = scale * 2
    if scale > max_scale then
        scale = 1
    end
    shader:send("scale", scale)
end
