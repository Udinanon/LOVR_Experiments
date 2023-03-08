---@diagnostic disable: deprecated

Utils = require "Utils"
Graphs = require "Graphs"

-- run on boot of the program, where all the setup happes
function lovr.load()
  print("LODR LOAD")
  -- prepare for the color wheel thing
  color = {0, 1, 1, 1}
  -- this runs the physics, here we also set some global constants
  world = lovr.physics.newWorld()
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)
  -- generate the floor, Kinematic means infinite mass kinda
  local width, depth = lovr.headset.getBoundsDimensions()

  walls = 1
  
  SolarSystem = require "SolarSystem"
  
  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false}
  function State:isNormal ()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end

  lovr.graphics.setBackgroundColor(.1, .1, .1, 1)


  Graph = Graphs:new()
  Graph:setVisible()
  Graph:drawAxes()
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
  
  if not State["B"]then
    SolarSystem:applyGravity()
  end

  if State:isNormal() then
    if lovr.headset.wasPressed("right", 'trigger') then
      local curr_color = Utils.shallowCopy(color)
      local body = SolarSystem:new(curr_color, lovr.math.newVec3(lovr.headset.getPosition("right")),
      lovr.math.newVec3(lovr.headset.getVelocity("right")))
      Utils.addVector(lovr.math.newVec3(lovr.headset.getPosition("right")),
      lovr.math.newVec3(lovr.headset.getVelocity("right")), curr_color, true)
      -- create cube there with color and shift it slightly
      color[1] = color[1]+40
      
      table.insert(SolarSystem.bodies, body)
    end 
      
      -- if left trigger is pressed
    if lovr.headset.wasPressed("left", "trigger") then
      print("Left Click")
      --[[
        local sun_pos = lovr.math.newVec3(sun.collider:getPosition())
      local hand_pos = vec3(lovr.headset.getPosition("left"))
      local hand_quat = quat(lovr.headset.getOrientation("left"))
      local x_axis = lovr.math.newVec3(-1, 0, 0)

      x_axis = hand_quat:mul(x_axis):normalize()
      local distance_vec = (sun_pos-hand_pos):normalize()
      local speed_vec = distance_vec:cross(x_axis)
      local speed_mod = math.sqrt(.01 * (sun.mass + 1) / distance_vec:length()) 
      local curr_color = Utils.shallowCopy(color)

      
      local body = SolarSystem:new(curr_color, lovr.math.newVec3(lovr.headset.getPosition("left")),
      speed_vec:mul(speed_mod))
      body.draw_force = false
      body:compute_orbit(x_axis)
      body.draw_orbit = true

      print("HERE")
      color[1] = color[1] + 40

      table.insert(SolarSystem.bodies, body)
      Utils.addLabel("HERE", lovr.math.newVec3(lovr.headset.getPosition("left")))
      ]]
      Graph:reposition()
    end
  end

  -- update blackboard
  local time = lovr.timer.getTime()
  for i, body in ipairs(SolarSystem.bodies) do
    local x_pix = body:get_position().x
    local y_pix = body:get_position().z
    Graph:drawPoint({x_pix, y_pix}, body.color)
  end
  


  -- when both grips are pressed, kinda finnicky but ok
  if lovr.headset.wasPressed("left", 'grip') and lovr.headset.wasPressed("right", 'grip') then
    -- clear all
      SolarSystem.destroyBodies()
      Graph:clean()
  end

  if lovr.headset.wasPressed("right", "a") then
    State["A"] = not State["A"]
    if State["A"] then

      
    end
  end
  if lovr.headset.wasPressed("right", "b") then
    State["B"] = not State["B"]
    if State["B"] then


    end
  end

end

-- this draws obv
function lovr.draw(pass)

  Utils.drawVectors(pass)
  --Utils.drawLabels(pass)

  
  -- draw sun and bodies
  SolarSystem.drawSun(pass)
  SolarSystem.drawBodies(pass)

  -- draw hands
  if State:isNormal() then
    Utils.drawHands(pass, 0xffffff)
  end
  if State["A"] then
    Utils.drawHands(pass, 0x0000ff)
  end
  if State["B"] then
    Utils.drawHands(pass, 0x00ff00)
  end
  -- draw blackboard
  local transfer_pass = lovr.graphics.getPass("transfer")
  Graphs:drawAll(pass, transfer_pass)
  Utils.drawBounds(pass)
  Utils.drawAxes(pass)
  

  Utils.drawBoxes(pass)
  return lovr.graphics.submit({ pass, transfer_pass })
end
