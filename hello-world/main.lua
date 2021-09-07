---@diagnostic disable: deprecated

-- draw boxCollider quickly
local function drawBox(box, color)
  local x, y, z = box:getPosition()
  local dx, dy, dz = box:getShapeList()[1]:getDimensions()
  lovr.graphics.setColor(color)
  lovr.graphics.box('fill', x, y, z, dx, dy, dz, box:getOrientation())
end


-- run on boot of the program, where all the setup happes
function lovr.load()
  -- prepare for the color wheel thing
  color = {0, 1, 1, 1}
  -- this runs the physics, here we also set some global constants
  world = lovr.physics.newWorld()
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)
  -- generate the floor, Kinematic means infinite mass kinda
  ground = world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
  -- cubes are the wireframe, boxes the physical ones
  -- planes = {}
  cubes = {}

  screen = nil
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false}
  function State:isNormal ()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end
  canvas = lovr.graphics.newCanvas(4096, 4096, { stereo = false })
  material = lovr.graphics.newMaterial(canvas:getTexture())
end

-- runs at each dt interval, where you do input and physics
function lovr.update(dt)
  -- update physics, like magic
  world:update(dt)
  

  if State:isNormal() then
    -- if right hand trigger is pressed
    if lovr.headset.wasPressed("right", 'trigger') then
      -- create cube there with color and shift it slightly
      local th_x, th_y = lovr.headset.getAxis('right', 'thumbstick')
      local x, y, z, angle, ax, ay, az = lovr.headset.getPose("right")
      local curr_color = shallowCopy(color)
      local cube = {["pos"] = {x, y, z, .10, angle, ax, ay, az}, ["color"] = curr_color}
      color[1] = color[1]+2
      -- the th_x gives us multiple cube sizes
      if th_x >= 0.75 then
        cube["pos"][4]=.20
        table.insert(cubes, cube)
      elseif th_x <= -0.75 then
        cube["pos"][4]=.05
        table.insert(cubes, cube)
      else 
        table.insert(cubes, cube)
      end
    end 

    -- if left trigger is pressed
    if lovr.headset.wasPressed("left", "trigger") then
        -- generate a physics box there
      local hand_pos = {lovr.headset.getPosition("left")}
      print("HANDPOS ",unpack(hand_pos))
      local head_pos = vec3(lovr.headset.getPosition("head"))
      print("HEADPOS ", head_pos)
      local vision_vec = lovr.math.newQuat()
      -- vision_vec:set(lovr.headset.getOrientation("head"))

      local diff_vec = vec3(unpack(hand_pos)):sub(head_pos):normalize()
      print("DIFFVEC", diff_vec)
      local pos = vec3(unpack(hand_pos)):add(diff_vec:mul(1))
      print("POS", pos)
      vision_vec:set(diff_vec)
      
      screen = {["pos"] = {pos:unpack()}}
      screen["rotation"] = {vision_vec:unpack()}
      
      canvas:renderTo(function()
        lovr.graphics.clear()
        lovr.graphics.setColor(1, 1, 1)
        local fov = math.rad(67)
        --local ortho = lovr.math.mat4():orthographic(2, 2, 2, 2, 0, -6)
        lovr.graphics.setProjection(1, fov, fov, fov, fov)
        lovr.graphics.setViewPose(1, 0, 0, 0, 0, 0, -1, 0)
        local gatt_img = lovr.data.newImage("paris.jpg")
        local max_dim = math.max(gatt_img:getDimensions())
        local base_img = lovr.data.newImage(max_dim, max_dim)
        --local clear_img = lovr.data.newImage(max_dim, max_dim)
        base_img:paste(gatt_img)
        local texture = lovr.graphics.newTexture(base_img)
        lovr.graphics.fill(texture)
      end)
      
      screen["material"] = material
    end

    
    -- when both grips are pressed, kinda finnicky but ok
    if lovr.headset.wasPressed("left", 'grip') then
        if lovr.headset.wasPressed("right", 'grip') then
          -- remove all boxes and cubes
          cubes = {}
          boxes = {}
      end 
    end
  end

  if lovr.headset.wasPressed("right", "a") then
    State["A"] = not State["A"]
  end
end

-- this draws obv
function lovr.draw()
  -- draw white spheres for the hands
  for i, hand in ipairs(lovr.headset.getHands()) do
    local position = vec3(lovr.headset.getPosition(hand))
    local hand_quat = quat(lovr.headset.getOrientation(hand))
    if State.isNormal() then
      lovr.graphics.setColor(1, 1, 1)
      lovr.graphics.sphere(position, .01)

      lovr.graphics.setColor(1, 0, 0)
      local x_axis = lovr.math.newVec3(0, 0, -1)
      x_axis = hand_quat:mul(x_axis)
      lovr.graphics.line(position, position + x_axis * .05)

      lovr.graphics.setColor(0, 1, 0)
      local x_axis = lovr.math.newVec3(-1, 0, 0)
      x_axis = hand_quat:mul(x_axis)
      lovr.graphics.line(position, position + x_axis * .05)

      lovr.graphics.setColor(0, 0, 1)
      local x_axis = lovr.math.newVec3(0, -1, 0)
      x_axis = hand_quat:mul(x_axis)
      lovr.graphics.line(position, position + x_axis * .05)
    elseif State["A"] then
      lovr.graphics.setColor(1, 0, 0)
      lovr.graphics.sphere(position, .01)

      lovr.graphics.setColor(0, 0, 1)
      local x_axis = lovr.math.newVec3(0, 0, -1)
      x_axis = hand_quat:mul(x_axis)
      lovr.graphics.line(position, position + x_axis * .05)

      lovr.graphics.setColor(0, 0, 1)
      local x_axis = lovr.math.newVec3(-1, 0, 0)
      x_axis = hand_quat:mul(x_axis)
      lovr.graphics.line(position, position + x_axis * .05)

      lovr.graphics.setColor(0, 0, 1)
      local x_axis = lovr.math.newVec3(0, -1, 0)
      x_axis = hand_quat:mul(x_axis)
      lovr.graphics.line(position, position + x_axis * .05)
    end
  end

  -- draw the planes
  if screen then
    local x, y, z = unpack(screen["pos"])
    local angle, ax, ay, az  = unpack(screen["rotation"])
    local material = screen["material"]

    lovr.graphics.setColor(1, 1, 1)
    lovr.graphics.plane(material, x, y, z, 1, 1, angle, ax, ay, az)
  end

  -- draw the cubes
  for i, cube in ipairs(cubes) do
    local cube_color = cube["color"]
    local position = cube["pos"]
    local r, g, b, a=HSVToRGB(unpack(cube_color))
    lovr.graphics.setColor(r, g, b, a)
    lovr.graphics.cube("line", unpack(position))
  end

  -- drawBox(ground, {.15, .15, .17})

  -- draw axes
  lovr.graphics.setColor(0, 1, 0)
  lovr.graphics.line(0, 0, 0, 1, 0, 0)
  lovr.graphics.setColor(0, 0, 1)
  lovr.graphics.line(0, 0, 0, 0, 1, 0)
  lovr.graphics.setColor(1, 0, 0)
  lovr.graphics.line(0, 0, 0, 0, 0, 1)

end

-- utility function for the rainbow thing
function HSVToRGB(h, s, v, a)
  local c = v*s
  local x = c*(1-math.abs((h/60)%2-1))
  local m = v-c
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

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end