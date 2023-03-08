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
  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false}
  function State:isNormal ()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end

  lovr.graphics.setBackgroundColor(.1, .1, .1, 1)

  animation_play = true
  orbit_motion = {
    pose = lovr.math.newMat4(), -- Transformation in VR initialized to origin (0,0,0) looking down -Z
    thumbstickDeadzone = 0.3, -- Smaller thumbstick displacements are ignored (too much noise)
    -- Smooth orbit_motion parameters
    walkingSpeed = 2,
    scaleSpeed = 0.02
  }
  
  local cassini = lovr.filesystem.read("cassini_pos.txt")
  --"([^\n]*)\n?"


  cassini_pos = {}
  cassini_index = 0
  local offset = mat4(vec3(0, 1, 0), vec3(2, 2, 2), quat())
  for line in Utils.gsplit(cassini, "\n") do
    local pos = lovr.math.newVec3(unpack(Utils.map(Utils.split(line, " ", true), tonumber)))
    pos = offset:mul(pos)
    table.insert(cassini_pos, pos)
  end
  print(cassini_pos[1])
  print(cassini_pos[4000])
  print(#cassini_pos)

  Graph = Graphs:new()
  Graph:setVisible()
  Graph:drawAxes()

  BlackBoard = Graphs:new(1, 4)
--  BlackBoard:drawPoint({1, 1}, {1, 1, 1, 1})
  BlackBoard:setVisible()
  BlackBoard:drawAxes()
  BlackBoard:setPose(mat4(vec3(0, 1.5, 1), quat(0, 0, 0, 1)))

end

-- runs at each dt interval, where you do input and physics
function lovr.update(dt)
  -- update physics, like magic
  world:update(dt)

  if State:isNormal() then

    if lovr.headset.isTracked('left') then
      local x, y = lovr.headset.getAxis('left', 'thumbstick')
      local head_quat = quat()

      -- Smooth strafe movement
      if math.abs(x) > orbit_motion.thumbstickDeadzone then
        local strafeVector = head_quat:mul(vec3(1, 0, 0))
        orbit_motion.pose:translate(strafeVector * x * orbit_motion.walkingSpeed * dt)
      end
      -- Smooth Forward/backward movement
      if math.abs(y) > orbit_motion.thumbstickDeadzone then
        orbit_motion.pose:translate(head_quat:direction() * y * orbit_motion.walkingSpeed * dt)
      end
      -- if left trigger is pressed
      if lovr.headset.isDown("left", "trigger") then
          local vertVector = head_quat:mul(vec3(0, 1, 0))
          orbit_motion.pose:translate(vertVector * 0.5 * orbit_motion.walkingSpeed * dt)
      end
      -- if left trigger is pressed
      if lovr.headset.isDown("left", "grip") then
        local vertVector = head_quat:mul(vec3(0, 1, 0))
        orbit_motion.pose:translate(vertVector * -0.5 * orbit_motion.walkingSpeed * dt)
      end
    end
    if lovr.headset.isTracked('right') then
      local x, y = lovr.headset.getAxis('right', 'thumbstick')
      
      -- Smooth scaling of orbit data
      if math.abs(y) > orbit_motion.thumbstickDeadzone then
        orbit_motion.scale = 1.+ orbit_motion.scaleSpeed * Utils.sign(y)
        orbit_motion.pose:scale(orbit_motion.scale)
      end
    end

    if lovr.headset.wasPressed("right", 'trigger') then
      print("c")
    end 

    if lovr.headset.wasPressed("right", "a") then
      print("b")
      animation_play = not animation_play
      print("a", animation_play)
    end
   
  end



  -- update blackboard
  for i, hand in ipairs(lovr.headset.getHands()) do
    local position = lovr.math.vec3(lovr.headset.getPosition(hand))
    Graph:drawPoint({position.x, position.z}, {10, 1, 1, 1})
  end

  -- when both grips are pressed, kinda finnicky but ok
  if lovr.headset.wasPressed("left", 'grip') and lovr.headset.wasPressed("right", 'grip') then
    -- clear all
      Graph:clean()
      BlackBoard:clean()
      Utils.boxes = {}
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
  Utils.drawHands(pass, 0xffffff)
  

  pass:transform(mat4(orbit_motion.pose))
  -- odd flickeringnin v16 from tables, fixed later
  pass:setColor(0xA66300)
  local saturn_transform = mat4(vec3(0, 1, 0), vec3(0.05), quat())
  pass:sphere(saturn_transform)

  pass:setColor(0xFFFFFF)
  pass:line(cassini_pos)

  pass:setColor(0x6D7582)
  if animation_play then 
    cassini_index = (cassini_index % #cassini_pos) + 1
  end
  local sat_transform = mat4()
  sat_transform:translate(cassini_pos[cassini_index])
  sat_transform:scale(0.02)
  pass:sphere(sat_transform)
  pass:origin()


  Utils.drawVectors(pass)
  --Utils.drawLabels(pass)

  -- draw blackboard
  local transfer_pass = lovr.graphics.getPass("transfer")
  --Graphs:drawAll(pass, transfer_pass)
  Utils.drawBounds(pass)
  Utils.drawAxes(pass)
  

  Utils.drawBoxes(pass)
  return lovr.graphics.submit({ pass, transfer_pass })
end
