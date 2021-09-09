---@diagnostic disable: deprecated
-- Module instantiation
local cjson = require "cjson"
local cjson2 = cjson.new()
local request = require("luajit-request")

-- run on boot of the program, where all the setup happes
function lovr.load()
  -- this runs the physics, here we also set some global constants
  world = lovr.physics.newWorld()
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)
  -- generate the floor, Kinematic means infinite mass kinda
  ground = world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)

  screen = nil
  username = "DottorMarcus"
  URL = "https://e621.net/"
  
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false, ["LS"]=false, ["RS"]=false}
  function State:isNormal ()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end
  canvas = lovr.graphics.newCanvas(4096, 4096, { stereo = false })
  image = lovr.data.newImage("paris.jpg")
  material = lovr.graphics.newMaterial(canvas:getTexture())
end

-- runs at each dt interval, where you do input and physics
function lovr.update(dt)
  -- update physics, like magic
  world:update(dt)
  if State["RS"] then
    local head_pos = vec3(lovr.headset.getPosition("head"))
    local vision_vec = lovr.math.newQuat()
    vision_vec:set(lovr.headset.getOrientation("head")):normalize()
    local plane_pos = head_pos:add((vision_vec:direction()):mul(2))
    
    screen = {["pos"] = {plane_pos:unpack()}}
    screen["rotation"] = {vision_vec:unpack()}
    screen["material"] = material
  end

  if State:isNormal() then
    if lovr.headset.wasPressed("right", "trigger") then
          local response_json = request.send(URL+"posts/random.json?tags=fav:"+username).body
          local response = cjson.decode(response_json)
          local image_data= response["posts"][1]
          local blob = lovr.data.newBlob(image_data)
          local image = lovr.graphics.newImage(blob)
          updateCanvas(image)
    end
  end


  if lovr.headset.wasPressed("right", "thumbstick") then
    State["RS"] = not State["RS"]

  end
end

-- this draws obv
function lovr.draw()
  -- draw white spheres for the hands
  for i, hand in ipairs(lovr.headset.getHands()) do
    local position = vec3(lovr.headset.getPosition(hand))
    local hand_quat = quat(lovr.headset.getOrientation(hand))
    if State.isNormal() or State["RS"] then
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

function updateCanvas(image)
    canvas:renderTo(function()
      lovr.graphics.clear()
      lovr.graphics.setColor(1, 1, 1)
      local fov = math.rad(67)
      --local ortho = lovr.math.mat4():orthographic(2, 2, 2, 2, 0, -6)
      lovr.graphics.setProjection(1, fov, fov, fov, fov)
      lovr.graphics.setViewPose(1, 0, 0, 0, 0, 0, -1, 0)
      local max_dim = math.max(image:getDimensions())
      local base_img = lovr.data.newImage(max_dim, max_dim)
      --local clear_img = lovr.data.newImage(max_dim, max_dim)
      base_img:paste(image)
      local texture = lovr.graphics.newTexture(base_img)
      lovr.graphics.fill(texture)
    end)
end