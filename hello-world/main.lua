---@diagnostic disable: deprecated



-- run on boot of the program, where all the setup happes
function lovr.load()
  -- prepare for the color wheel thing
  color = {0, 1, 1, 1}
  -- this runs the physics, here we also set some global constants
  world = lovr.physics.newWorld()
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)
  -- generate the floor, Kinematic means infinite mass kinda
  local width, depth = lovr.headset.getBoundsDimensions()
  print("LODR LOAD")
  print(width)
  print(depth)
  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
  -- cubes are the wireframe, boxes the physical ones
  boxes = {}
  cubes = {}
  boundaries = {}
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false}
  function State:isNormal ()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end

end

-- runs at each dt interval, where you do input and physics
function lovr.update(dt)
  -- update physics, like magic
  world:update(dt)
  if State["A"] then

    --[[ if lovr.headset.wasPressed("right", 'trigger') or lovr.headset.wasPressed("left", "trigger") then
      local l_pos = vec3(lovr.headset.getPosition("left"))
      local r_pos = vec3(lovr.headset.getPosition("right"))
      print("R POS")
      print(r_pos)
      local avg_point = r_pos:add(l_pos):div(2) -- get avg point between the two 
      print("AVG POINT")
      print(avg_point)
      local center_y = avg_point[2]/2
      local box_height = avg_point[2]
      
      avg_point = vec2(avg_point[1], avg_point[3]) -- vec2
      local diff_vec = r_pos:sub(l_pos)
      local depth_vec = diff_vec:cross(vec3(0, 1, 0)) --- vec3
      depth_vec = vec2(depth_vec[1], depth_vec[3]) -- vec2
      -- local box_width = depth_vec:length()
      depth_vec=depth_vec:normalize()

      local angle = math.atan2(r_pos[1]-l_pos[1], r_pos[3]-l_pos[3])  -- radians
      --[[print("DEPTH VECTOR")
      print(depth_vec)
      local width, height = lovr.headset.getBoundsDimensions() -- x, z vec
      print("BOUNDS DIMS")
      print(width, height)
      print("R POS")
      print(r_pos)]]

      --[[local true_pos = vec2(r_pos[1]+(width/2), r_pos[3]+(height/2))
      print("TRUE POS")
      print(true_pos)
      local min_component = math.min(true_pos:unpack())
      local angle = 0
      if min_component == true_pos[1] then
        angle = math.atan(true_pos[2]/true_pos[1])
      else 
        angle = math.atan(true_pos[1]/true_pos[2])
      end
      print("ANGLE")
      print(angle)
      local box_depth = min_component/math.cos(angle)
      print("BOX DEPTH")
      print(box_depth)
      local box_x, tmp, box_z = depth_vec:mul(box_depth):unpack() -- unpacked vec3
      --print("BOX VALUES")
      --print(box_x, box_y, box_z)
      local box_depth = 5
      
      local box_width = diff_vec:length()
      local center_x, center_z = avg_point:unpack()--:add(depth_vec:mul(-2.5)):unpack()
      -- local center_x, center_y, center_z = lovr.headset.getPosition("right")
      local volume = {["center"]={center_x, center_y, center_z}, 
                      ["size"]={box_width, box_height, .1},
                      ["rotation"]=angle}
      print("VOLUME")
      print(volume["center"][1], volume["center"][2], volume["center"][3])
      print(volume["size"][1], volume["size"][2], volume["size"][3])
      print(volume["rotation"])

      table.insert(boundaries, volume)
    end ]]
  end
  if State:isNormal() then
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
      local x, y, z = lovr.headset.getPosition("left")
      local box = world:newBoxCollider(x, y, z, .10)
      -- the velocity thing feels weird but tehre is no headset.getAccelleration
      -- maybe making a custom function but eh
      local vx, vy, vz = lovr.headset.getVelocity("left")
      box:setLinearVelocity(vx, vy, vz)
      table.insert(boxes, box)
    end
  end

  -- when both grips are pressed, kinda finnicky but ok
  if lovr.headset.wasPressed("left", 'grip') and lovr.headset.wasPressed("right", 'grip') then
      -- remove all boxes and cubes
      cubes = {}
      boxes = {}
  end

  if lovr.headset.wasPressed("right", "a") then
    State["A"] = not State["A"]
    if State["A"] then
      local width, depth = lovr.headset.getBoundsDimensions()

      world:newBoxCollider(width/2, 2, 0, 0.1, 4, depth):setKinematic(true)
      world:newBoxCollider(-width/2, 2, 0, 0.1, 4, depth):setKinematic(true)
      world:newBoxCollider(0, 2, depth/2, width, 4, 0.1):setKinematic(true)
      world:newBoxCollider(0, 2, -depth/2, width, 4, 0.1):setKinematic(true)
      
    end
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
      local x_axis = lovr.math.newVec3(-1, 0, 0)
      local y_axis = lovr.math.newVec3(0, -1, 0)
      local z_axis = lovr.math.newVec3(0, 0, -1)
      x_axis = hand_quat:mul(x_axis)
      y_axis = hand_quat:mul(y_axis)
      z_axis = hand_quat:mul(z_axis)
      if hand == "hand/right" then
        lovr.graphics.line(position, position + z_axis * .05)
        lovr.graphics.line(position, position + x_axis * .05)
        lovr.graphics.line(position, position + y_axis * .05)
      elseif hand == "hand/left" then
        lovr.graphics.line(position, position + z_axis * .05)
        lovr.graphics.line(position, position - x_axis * .05)
        lovr.graphics.line(position, position + y_axis * .05)
      end
    end
  end

  -- draw the boxes
  for i, box in ipairs(boxes) do
    local x, y, z = box:getPosition()
    lovr.graphics.setColor(0.8, 0.8, 0.8)
    lovr.graphics.cube('fill', x, y, z, .1, box:getOrientation())
  end

  -- draw the cubes
  for i, cube in ipairs(cubes) do
    local cube_color=cube["color"]
    local position=cube["pos"]
    local r, g, b, a=HSVToRGB(unpack(cube_color))
    lovr.graphics.setColor(r, g, b, a)
    lovr.graphics.cube("line", unpack(position))
  end

  if State["A"] then
    -- get hand positions
    local r_pos = vec3(lovr.headset.getPosition("right"))
    local l_pos = vec3(lovr.headset.getPosition("left"))

    -- draw connecting line
    lovr.graphics.setColor(1, 1, 0)
    lovr.graphics.line({r_pos, l_pos})
  
    -- get average point
    local avg_point = r_pos:add(l_pos):div(2)
    local avg_point_2 = vec3(avg_point)
    local height = avg_point[2]
    -- this edits r_pos
    -- draw average point
    lovr.graphics.setColor(1, 1, 1)
    lovr.graphics.sphere(avg_point, .01)

    -- get depth vector
    local r_pos = vec3(lovr.headset.getPosition("right"))
    local diff_vec = r_pos:sub(l_pos)
    local diff_bckp = vec3(diff_vec)
    --r_pos is no longer the same
    local depth_vec = diff_vec:cross(vec3(0, -1, 0)):normalize()
    local depth_point = avg_point_2:add(depth_vec:mul(0.5))

    lovr.graphics.setColor(1, 0, 1)
    lovr.graphics.line({avg_point, depth_point})
    
    -- use raycast to find depth
    avg_point_2 = vec3(avg_point)
    depth_vec:normalize() -- reset depth_vec to have module 1
    local max_dim = math.max(lovr.headset.getBoundsDimensions())
    local end_point = avg_point_2:add(depth_vec:mul(max_dim))
    local collision_point = lovr.math.newVec3()
    local closest = math.huge
    avg_point_2 = vec3(avg_point)
    world:raycast(avg_point, end_point, 
      function(shape, x, y, z, nx, ny, nz)
        closest = math.min(closest, avg_point_2:distance(vec3(x,y,z)))
        collision_point:set(x, y, z)
      end)
    --print("COLLISION ", collision_point:unpack())
    local depth = collision_point:distance(avg_point)
    --local depth = 4
    -- calculate volume center
    local volume_center = lovr.math.newVec3()
    avg_point_2 = vec3(avg_point)
    depth_vec:normalize()
    local rotation = quat(depth_vec)
    avg_point_2:add(depth_vec:mul(depth/2))
    volume_center = avg_point_2:mul(vec3(1, .5, 1)) -- set volume centerbto be avg_p_2 with half the height
    
    
    lovr.graphics.setColor(0, 1, 1)
    lovr.graphics.sphere(volume_center, 0.03)

    lovr.graphics.box("line", volume_center, diff_bckp:length(), height, depth, rotation)
  
  end


  -- draw axes
  lovr.graphics.setColor(0, 1, 0)
  lovr.graphics.line(0, 0, 0, 1, 0, 0)
  lovr.graphics.setColor(0, 0, 1)
  lovr.graphics.line(0, 0, 0, 0, 1, 0)
  lovr.graphics.setColor(1, 0, 0)
  lovr.graphics.line(0, 0, 0, 0, 0, 1)

  -- local world_pos = world:getPosition()
  local width, height = lovr.headset.getBoundsDimensions()
  lovr.graphics.setColor(0.1, 0.1, 0.11)
  lovr.graphics.box("line", 0, 0, 0, width, .05, height)

  lovr.graphics.setColor(1, 1, 1)
  lovr.graphics.box("line", width/2, 2, 0, 0.1, 4, height)
  lovr.graphics.box("line", -width/2, 2, 0, 0.1, 4, height)
  lovr.graphics.box("line", 0, 2, height/2, width, 4, 0.1)
  lovr.graphics.box("line", 0, 2, -height/2, width, 4, 0.1)

  -- lovr.graphics.line(0, 0, 0, 0, 2, 0)

  --[[ local points = lovr.headset.getBoundsGeometry()
  lovr.graphics.setColor(0, 1, 0)
  lovr.graphics.print(#points, 0, 3, 3) ]]
  --[[ for i, point in ipairs(points) do
    lovr.graphics.sphere(point, .05)
  end ]]

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