---@diagnostic disable: redundant-parameter

require "GrabPoint"

Teapot_controller = {
    utah = {
        model = lovr.graphics.newModel("Assets/utah.stl"),
        position = lovr.math.newVec3(0.0),
        velocity = lovr.math.newVec3(0.0),
        k1 = 1.0,
        k2 = 2.0,
        k3 = 3.0,
        graph = nil
    },

    board = {
        rotation = lovr.math.newQuat(),
        position = lovr.math.newVec3(),
        visible = false,
        size = {.8, .6},
        material = lovr.graphics.newMaterial(),
        knob_offset = { h = lovr.math.newVec3(0.1, 0, 0), v = lovr.math.newVec3(0, -0.35, 0) },
        knob_size = lovr.math.newVec3(.1, .04, 10),
        grab_points = { GrabPoint:new(lovr.math.newVec3(), 0.02),
            GrabPoint:new(lovr.math.newVec3(), 0.02), 
            GrabPoint:new(lovr.math.newVec3(), 0.02)
        }
    },
}



function Teapot_controller:generate_board_image()
    local image = lovr.data.newImage(800, 600, "rgb", nil) -- empty image
    local x = 0
    local dx = 0
    local y = 0
    local dy = 0
    local ddy = 0

    local px_zero = 500
    local px_scale = 250
    local dt = 0.1 -- 10 ms ????
    for i = 0, 799 do
        -- x
        if i < 300 then
            --before the step
            image:setPixel(i, px_zero, 1, 0, 0)
        else if i == 300 then
                -- draw a nice step
                for j = px_zero, px_zero - px_scale do
                    image:setPixel(i, j, 1, 0, 0)
                end
                x = 1
                dx = 1
            else
                if dx == 1 then
                    dx = 0
                end
                -- after
                image:setPixel(i, px_zero - px_scale, 1, 0, 0)
            end
        end
        -- compute y
        y = y + dy * dt
        ddy = (x + dx * self.utah.k3 - y - dy * self.utah.k1) / self.utah.k2
        dy = dy + ddy * dt

        -- 0 ==  px_zero
        -- 1 ==  px_zero - 1 * px_scale
        local px_y = px_zero - y * px_scale
        px_y = math.min(math.max(px_y, 0), 600)
        image:setPixel(i, px_y, 0, 1, 0)
    end
    local texture = lovr.graphics.newTexture(image, { format = "rgb", mipmaps = false })
    self.utah.graph = texture
    self.board.material:setTexture(texture)
end

function Teapot_controller.board:move_and_invert_board()
    self.visible = not self.visible
    local device = "hand/right"
    self.position = lovr.math.newVec3(lovr.headset.getPosition(device))
    self.rotation = lovr.math.newQuat(lovr.headset.getOrientation(device))
    for i = -1, 1 do
        local point_pos = self.position + self.rotation:mul(self.knob_offset.v + i * self.knob_offset.h)
        self.grab_points[i+2]:set_pos(point_pos)
    end

end

function Teapot_controller:draw_all()
    self.utah.model:draw(self.utah.position, .01)
    if self.board.visible then
        self.board:draw_board()
    end
end

function Teapot_controller.board:draw_board()
    local w, h = unpack(self.size)
    lovr.graphics.plane(self.material, self.position, w, h, self.rotation)
    for i= -1, 1 do
        local cube_pos = self.position  + self.rotation:mul(self.knob_offset.v + i * self.knob_offset.h)
        lovr.graphics.setColor(.6, .6, .6)
        --lovr.graphics.cube("fill", cube_pos, 0.05, self.rotation)
        lovr.graphics.setColor(1, 1, 1)
    end
    for _, point in ipairs(self.grab_points) do
        point:draw()
    end
end

function Teapot_controller.utah:update(dt)
    local device = "hand/left"
    local hand_pos = vec3(lovr.headset.getPosition(device))
    local hand_speed = vec3(lovr.headset.getVelocity(device))
    self.position = lovr.math.newVec3(self.position + self.velocity * dt)
    local acceleration = lovr.math.vec3(hand_pos + hand_speed * self.k3 - self.position - self.velocity * self.k1) / self.k2
    self.velocity = lovr.math.newVec3(self.velocity + acceleration * dt)
end

