---@diagnostic disable: deprecated, redundant-parameter, lowercase-global
world = lovr.physics.newWorld()

require "TeaPot"
local icosphere = require 'icosphere'


-- run on boot of the program, where all the setup happes
function lovr.load()
  -- this runs the physics, here we also set some global constants
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)
  -- generate the floor, Kinematic means infinite mass kinda
  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
  -- cubes are the wireframe, boxes the physical ones
  walls = 0
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false}
  function State:isNormal ()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end

  teapot = Teapot_controller
  teapot:generate_board_image()

  shader = lovr.graphics.newShader('unlit', {})
  lovr.graphics.setShader(shader)

  vertices, indices = icosphere(2)
  
  mesh = lovr.graphics.newMesh(vertices, "lines", "static")
  mesh:setVertexMap(indices)


  end


-- runs at each dt interval, where you do input and physics
function lovr.update(dt)
  -- update physics, like magic
  
  world:update(dt)
  if walls == 0 then
      local width, depth = lovr.headset.getBoundsDimensions()
      world:newBoxCollider(width/2, 2, 0, 0.1, 4, depth):setKinematic(true)
      world:newBoxCollider(-width/2, 2, 0, 0.1, 4, depth):setKinematic(true)
      world:newBoxCollider(0, 2, depth/2, width, 4, 0.1):setKinematic(true)
      world:newBoxCollider(0, 2, -depth/2, width, 4, 0.1):setKinematic(true)
      walls = 1
  end

  if State:isNormal() then
    -- https://www.youtube.com/watch?v=KPoeNZZ6H4s
    -- semi implicit Euler thord to integrate y + y' * k1 + y'' * k2 = x + x' * k3
    -- x is hand, y is utah
    teapot.utah:update(dt)

    -- if left trigger is pressed
    if lovr.headset.wasPressed("right", "trigger") then
      teapot.board:move_and_invert_board()
    end

    if lovr.headset.wasPressed("right", "grip") then
      teapot:randomize()

    end


    if lovr.headset.wasPressed("left", "trigger") then
      teapot.utah:teleport(lovr.math.newVec3(lovr.headset.getPosition("hand/left")))

    end


  end


  if lovr.headset.wasPressed("right", "a") then
    State["A"] = not State["A"]
    if State["A"] then

      
    end
  end


end

-- this draws obv
function lovr.draw()
  
  -- call the teapot to draw its compponents
  teapot:draw_all()
  
  -- draw white spheres for the hands
  for i, hand in ipairs(lovr.headset.getHands()) do
    local position = vec3(lovr.headset.getPosition(hand))
    local hand_quat = quat(lovr.headset.getOrientation(hand))

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
---@diagnostic disable-next-line: missing-parameter
    if State.isNormal() then
      lovr.graphics.setColor(1, 1, 1)
      --lovr.graphics.sphere(position, .01)
      mesh:draw(position, .011)

      
      
    elseif State["A"] then
      lovr.graphics.setColor(1, 0, 0)
      lovr.graphics.sphere(position, .01)

    end
  end
  
  


  -- draw axes
  lovr.graphics.setColor(0, 1, 0) -- G in/out x
  lovr.graphics.line(0, 0, 0, 1, 0, 0) 
  lovr.graphics.setColor(0, 0, 1) -- B vert y
  lovr.graphics.line(0, 0, 0, 0, 1, 0)
  lovr.graphics.setColor(1, 0, 0) -- R l/r z
  lovr.graphics.line(0, 0, 0, 0, 0, 1)

  local width, height = lovr.headset.getBoundsDimensions()
  lovr.graphics.setColor(0.1, 0.1, 0.11)
  lovr.graphics.box("line", 0, 0, 0, width, .05, height)

  lovr.graphics.setColor(1, 1, 1)
  lovr.graphics.box("line", width/2, 2, 0, 0.1, 4, height)
  lovr.graphics.box("line", -width/2, 2, 0, 0.1, 4, height)
  lovr.graphics.box("line", 0, 2, height/2, width, 4, 0.1)
  lovr.graphics.box("line", 0, 2, -height/2, width, 4, 0.1)
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