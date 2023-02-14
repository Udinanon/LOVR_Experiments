SolarSystem = {
    bodies = {},
    sun = {
        collider = world:newSphereCollider(0, 1, 0, 0.08),
        color = 0xffff99,
        size = 0.08,
        mass = 100
    }
    
} 

SolarSystem.sun.collider:setKinematic(true)

function SolarSystem.new(self, color, position, speed) --define generating method
    local ball = world:newSphereCollider(position, .02)
    ball:setKinematic(false)
    ball:setGravityIgnored(true)
    ball:setLinearDamping(0.000)
    ball:setMass(1)
    ball:setLinearVelocity(speed)

    local instance = {
        color = color,
        radius = 0.02,
        collider = ball,
        draw_speed = true,
        draw_force = true,
        draw_orbit = false,
    } -- crate table for instance and fill with datas

    --instance.position = self:get_position()
    
    setmetatable(instance, { __index = SolarSystem }) --associate the instance with the class object and inherit the methods and properties
    local key = #SolarSystem.bodies + 1
    SolarSystem.bodies[key] = instance
    instance.key = key
    return instance -- return the instance, not the class
end

function SolarSystem:get_position()
    return vec3(self.collider:getPosition())
end

function SolarSystem:apply_force(sun_position)
    local force = self:compute_force(sun_position)
    self.collider:applyForce(force)
end

function SolarSystem:compute_force(sun_position)
    local body_position = lovr.math.newVec3(self.collider:getPosition())

    local relative_pos = body_position - sun_position
    local distance = relative_pos:length()
    local gravity = -.01 * SolarSystem.sun.mass * self.collider:getMass() / (distance * distance)

    return relative_pos:mul(gravity)
end

function SolarSystem:compute_orbit(axis)
    local sun_pos = vec3(SolarSystem.sun.collider:getPosition())
    local self_pos = vec3(self.collider:getPosition())
    local sun_dist = (self_pos:sub(sun_pos)):length()
    -- pass to Utils add_vector
    --table.insert(to_draw, {start = lovr.math.newVec3(lovr.headset.getPosition("left")), fin = lovr.math.newVec3(lovr.headset.getPosition("left")):add(axis), color = self.color})

    self.orbit_data = {lovr.math.newVec3(SolarSystem.SolarSystem.suncollider:getPosition()), sun_dist, lovr.math.newQuat(axis)}
    print(unpack(self.orbit_data))

end

function SolarSystem:draw(sun_position, pass)
    self:draw_sphere(pass)
    if self.draw_speed then
        self:draw_speed_vec(pass)
    end
    if self.draw_force then
        self:draw_force_vec(sun_position, pass)
    end
    if self.draw_orbit then
        self:draw_orbit_(pass)
    end
end

function SolarSystem:draw_sphere(pass)
    pass:setColor(Utils.HSVAToRGBA(unpack(self.color)))
    pass:sphere(vec3(self.collider:getPosition()), self.radius)
end

function SolarSystem:draw_speed_vec(pass)
    local speed = vec3(self.collider:getLinearVelocity())
    local speed_mod = speed:length()
    
    local h, s, v = unpack(self.color)
    local r, g, b, a = Utils.HSVAToRGBA(h, speed_mod, v)
    pass:setColor(r, g, b, a)

    pass:line(vec3(self.collider:getPosition()), vec3(self.collider:getPosition()) + speed:normalize():div(8))
end

function SolarSystem:draw_force_vec(sun_position, pass)
    local force = self:compute_force(sun_position)
    local force_mod = force:length()

    local h, s, v = unpack(self.color)
    local r, g, b, a = Utils.HSVAToRGBA(h, force_mod, v)
    pass:setColor(r, g, b, a)

    pass:line(vec3(self.collider:getPosition()), (vec3(self.collider:getPosition()) + force:normalize():div(8)))
end

function SolarSystem:draw_orbit_(pass)
    local h, s, v = unpack(self.color)
    local r, g, b, a = Utils.HSVAToRGBA(h, s, v)
    pass:setColor(r, g, b, a)

    pass:circle("line", unpack(self.orbit_data))
end

-- Class functions

function SolarSystem.applyGravity()
    local sun_pos = lovr.math.newVec3(SolarSystem.sun.collider:getPosition())
    for i, body in ipairs(SolarSystem.bodies) do
        body:apply_force(sun_pos)
    end
end

function SolarSystem.drawSun(pass)
    pass:setColor(1, 1, 1, 1)
    pass:setColor(SolarSystem.sun.color)
    pass:sphere(vec3(SolarSystem.sun.collider:getPosition()), SolarSystem.sun.size)
    pass:setColor(1, 1, 1)
end

function SolarSystem.drawBodies(pass)
    local sun_position = vec3(SolarSystem.sun.collider:getPosition())
    for i, body in ipairs(SolarSystem.bodies) do
        body:draw(sun_position, pass)
    end
end

function SolarSystem.destroyBodies()
    SolarSystem.bodies = {}
end

return SolarSystem