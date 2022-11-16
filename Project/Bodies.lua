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
        draw_force = true       
    } -- crate table for instance and fill with datas

    setmetatable(instance, { __index = Body }) --associate the instance with the class object and inherit the methods and properties
    return instance -- return the instance, not the class
end

function Body.apply_force(self, sun_position)
    local force = self:compute_force(sun_position)
    self.collider:applyForce(force)
end

function Body.compute_force(self, sun_position)
    local body_position = lovr.math.newVec3(self.collider:getPosition())

    local relative_pos = body_position - sun_position
    local distance = relative_pos:length()
    local gravity = -.01 * sun.mass * self.collider:getMass() / (distance * distance)

    return relative_pos:mul(gravity)
end

function Body:draw_sphere()
    local r, g, b, a = HSVToRGB(unpack(self.color))
    lovr.graphics.setColor(r, g, b, a)
    lovr.graphics.sphere(vec3(self.collider:getPosition()), self.radius)
end

function Body:draw_speed_vec()
    local r, g, b, a = HSVToRGB(unpack(self.color))
    lovr.graphics.setColor(r, g, b, a)

    local speed = vec3(self.collider:getLinearVelocity())
    lovr.graphics.line(vec3(self.collider:getPosition()), vec3(self.collider:getPosition())+speed)

end

function Body:draw_force_vec(sun_position)
    local r, g, b, a = HSVToRGB(unpack(self.color))
    lovr.graphics.setColor(r, g, b, a)

    local force = self:compute_force(sun_position)

    lovr.graphics.line(vec3(self.collider:getPosition()), (vec3(self.collider:getPosition())+force))


end
