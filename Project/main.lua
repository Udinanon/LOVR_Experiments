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
  
  
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false}
  function State:isNormal ()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end

  lovr.graphics.setBackgroundColor(.1, .1, .1, 1)

  Graph = Graphs:new()
  Graph:setVisible()

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
      print("HERE")
      
      Graph:reposition()
    end
  end

  -- update blackboard
  local time = lovr.timer.getTime()
  for i, hand in ipairs(lovr.headset.getHands()) do
    local position = lovr.headset.getPosition(hand)
    Graph:drawPoint({position.x, position.z}, {i*100, 1, 1, 1})
  end
  


  -- when both grips are pressed, kinda finnicky but ok
  if lovr.headset.wasPressed("left", 'grip') and lovr.headset.wasPressed("right", 'grip') then
    -- clear all
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
function lovr.draw()

  Utils.drawVectors()
  Utils.drawLabels()

  -- draw blackboard
  Graphs:drawAll()
  
  -- draw hands
  if State:isNormal() then
    Utils.drawHands(0xffffff)
  end
  if State["A"] then
    Utils.drawHands(0x0000ff)
  end
  if State["B"] then
    Utils.drawHands(0x00ff00)
  end

  Utils.drawBoxes()
  Utils.drawVolumes()
  Utils.drawAxes()
  Utils.drawBounds()
end
