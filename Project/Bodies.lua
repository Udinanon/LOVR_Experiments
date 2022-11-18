bodies = {}
sun = {
    collider = world:newSphereCollider(0, 1, 0, 0.08),
    color = 0xffff99,
    size = 0.08,
    mass = 100
}
sun.collider:setKinematic(true)


Body = {} -- empty table used by class

function Body.new(self, color, position, speed) --define generating method
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
        draw_orbit = false
    } -- crate table for instance and fill with datas

    setmetatable(instance, { __index = Body }) --associate the instance with the class object and inherit the methods and properties
    return instance -- return the instance, not the class
end

function Body:apply_force(sun_position)
    local force = self:compute_force(sun_position)
    self.collider:applyForce(force)
end

function Body:compute_force(sun_position)
    local body_position = lovr.math.newVec3(self.collider:getPosition())

    local relative_pos = body_position - sun_position
    local distance = relative_pos:length()
    local gravity = -.01 * sun.mass * self.collider:getMass() / (distance * distance)

    return relative_pos:mul(gravity)
end

function Body:compute_orbit(axis)
    local sun_pos = vec3(sun.collider:getPosition())
    local self_pos = vec3(self.collider:getPosition())
    local sun_dist = (self_pos:sub(sun_pos)):length()
    table.insert(to_draw, {start = lovr.math.newVec3(lovr.headset.getPosition("left")), fin = lovr.math.newVec3(lovr.headset.getPosition("left")):add(axis), color = self.color})

    self.orbit_data = {lovr.math.newVec3(sun.collider:getPosition()), sun_dist, lovr.math.newQuat(axis)}
    print(unpack(self.orbit_data))

end

function Body:draw(sun_position)
    self:draw_sphere()
    if self.draw_speed then
        self:draw_speed_vec()
    end
    if self.draw_force then
        self:draw_force_vec(sun_position)
    end
    if self.draw_orbit then
        self:draw_orbit_()
    end
end

function Body:draw_sphere()
    local r, g, b, a = HSVToRGB(unpack(self.color))
    lovr.graphics.setColor(r, g, b, a)
    lovr.graphics.sphere(vec3(self.collider:getPosition()), self.radius)
end

function Body:draw_speed_vec()
    local speed = vec3(self.collider:getLinearVelocity())
    local speed_mod = speed:length()
    
    local h, s, v = unpack(self.color)
    local r, g, b, a = HSVToRGB(h, speed_mod, v)
    lovr.graphics.setColor(r, g, b, a)

    lovr.graphics.line(vec3(self.collider:getPosition()), vec3(self.collider:getPosition()) + speed:normalize():div(8))
end

function Body:draw_force_vec(sun_position)
    local force = self:compute_force(sun_position)
    local force_mod = force:length()

    local h, s, v = unpack(self.color)
    local r, g, b, a = HSVToRGB(h, force_mod, v)
    lovr.graphics.setColor(r, g, b, a)

    lovr.graphics.line(vec3(self.collider:getPosition()), (vec3(self.collider:getPosition()) + force:normalize():div(8)))
end

function Body:draw_orbit_()
    local h, s, v = unpack(self.color)
    local r, g, b, a = HSVToRGB(h, s, v)
    lovr.graphics.setColor(r, g, b, a)

    lovr.graphics.circle("line", unpack(self.orbit_data))
end