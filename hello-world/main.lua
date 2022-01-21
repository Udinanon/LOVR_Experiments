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

  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
  -- cubes are the wireframe, boxes the physical ones
  view_tablet = false
  tablet = {
    pos = lovr.math.newVec3(), 
    rot = lovr.math.newQuat(), 
    size = nil, 
    material = nil,
    page = 0 
  }
  volumes = {}
  walls = 0
  drag = {
    active = false,
    hand = nil,
    offset = lovr.math.newVec3(),
    in_range = false
  }
  --used to track if buttons were pressed
  State = {["A"] = false}
  function State:isNormal ()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end
  
  canvas = lovr.graphics.newCanvas(4096, 4096, { stereo = false })
  -- material = lovr.graphics.newMaterial(canvas:getTexture())
  
  files = lovr.filesystem.getDirectoryItems("/comic/")
  print(#files)

  image = lovr.data.newImage("gatt.jpg")
  tablet.material = lovr.graphics.newMaterial(genTexture(image))
  -- updateCanvas(image)

  shader = lovr.graphics.newShader('unlit', {      normalMap = false,
      indirectLighting = true,
      occlusion = true,
      emissive = true,
      skipTonemap = false})
  shader:send('lovrLightDirection', { -1, -1, -1 })
  shader:send('lovrLightColor', { .9, .9, .8, 1.0 })
  
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
      -- create a tablet there 
      
      local th_x, th_y = lovr.headset.getAxis('right', 'thumbstick')
      local x, y, z, angle, ax, ay, az = lovr.headset.getPose("right")

      tablet.pos:set(x, y, z)
      tablet.rot:set(angle, ax, ay, az) 
      tablet.size = 1
      view_tablet = true
    end 
  end

  if lovr.headset.wasPressed("right", "grip") and view_tablet then
    local offset = tablet.pos - vec3(lovr.headset.getPosition("right"))
    local halfSize = 1.189 / (1.414 ^ tablet.size)
    local x, y, z = offset:unpack()
    if math.abs(x) < halfSize and math.abs(y) < halfSize and math.abs(z) < halfSize then
      drag.active = true
      drag.hand = "right"
      drag.offset:set(offset)
    end
  end


  if drag.active then
    local handPosition = vec3(lovr.headset.getPosition(drag.hand))
    tablet.pos:set(handPosition + drag.offset)

    if lovr.headset.wasReleased(drag.hand, 'grip') then
      drag.active = false
    end
  end

  if lovr.headset.wasPressed("right", "thumbstick") then
    tablet.size = tablet.size + 1
    if tablet.size > 6 then
      tablet.size = 1
    end
  end 

  if lovr.headset.wasPressed("right", "a") then
    -- go to next image
      -- add some safeguards on this
    tablet.page = tablet.page + 1
    image = lovr.data.newImage("/comic/" .. files[tablet.page])
    tablet.material = lovr.graphics.newMaterial(genTexture(image))
  end


  if lovr.headset.wasPressed("right", "b") then
    -- go to next image
      -- add some safeguards on this
    if tablet.page > 1 then 
      tablet.page = tablet.page - 1
      image = lovr.data.newImage("/comic/" .. files[tablet.page])
      tablet.material = lovr.graphics.newMaterial(genTexture(image))
    end
  end

  if lovr.headset.wasPressed("left", "thumbstick") then
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
      if drag.active then
        lovr.graphics.setColor(0.3, 0.3, 1)
      end
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

  -- draw the tablet
  -- lovr.graphics.setShader(shader)
  if view_tablet then
    local position = tablet.pos
    local rotation = tablet.rot
    local size = 1.189 / (1.414 ^ tablet.size)
    
    lovr.graphics.setColor(1, 1, 1)
    lovr.graphics.plane(tablet.material, position, size / 1.414, size, rotation)
  end
 --  lovr.graphics.setShader()


  -- A state, add collider volumes mode
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
    local depth = collision_point:distance(avg_point)
    -- calculate volume center
    local volume_center = lovr.math.newVec3()
    avg_point_2 = vec3(avg_point)
    depth_vec:normalize()
    local rotation = quat(depth_vec)
    avg_point_2:add(depth_vec:mul(depth/2))
    volume_center = avg_point_2:mul(vec3(1, .5, 1)) -- set volume centerbto be avg_p_2 with half the height
    
    
    lovr.graphics.setColor(0, 1, 1)
    lovr.graphics.sphere(volume_center, 0.03)
    local width = diff_bckp:length()

    lovr.graphics.box("line", volume_center, width, height, depth, rotation)
    if lovr.headset.wasPressed("right", 'trigger') then
      local volume = world:newBoxCollider((volume_center), width, height, depth)
      volume:setKinematic(true)
      volume:setOrientation(rotation)
      table.insert(volumes, volume)
      end
  
  end

  -- draw collider volumes
  for i, volume in ipairs(volumes) do
    local x, y, z = volume:getPosition()
    local vol_shape = volume:getShapes()[1]
    local width, height, depth = vol_shape:getDimensions()
    lovr.graphics.setColor(0, 0.1, 0.12)
    lovr.graphics.box('fill', x, y, z, width, height, depth, volume:getOrientation())
  end

  -- draw axes
  lovr.graphics.setColor(0, 1, 0)
  lovr.graphics.line(0, 0, 0, 1, 0, 0)
  lovr.graphics.setColor(0, 0, 1)
  lovr.graphics.line(0, 0, 0, 0, 1, 0)
  lovr.graphics.setColor(1, 0, 0)
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


function genTexture(image)
  local dim1, dim2 = image:getDimensions()
  print("img dim")
  print(dim1 .. " " .. dim2)
  print("img ratio " .. dim2/dim1)
  local max_dim = math.max(dim1, dim2)
  local base_img = nil
  local off1, off2 = nil, nil  
  
  if dim2/dim1 >= 1.414 then
    -- the image is longer than standard paper
    base_img = lovr.data.newImage(max_dim/1.414, max_dim)
    print("base dim")
    print(max_dim/1.414 .. " " .. max_dim)
    off1 = (max_dim/1.414 - dim1)
    off2 = (max_dim - dim2)
  else 
    base_img = lovr.data.newImage(max_dim, max_dim*1.414)
    print("base dim")
    print(max_dim .. " " .. max_dim*1.414)
    off1 = (max_dim - dim1) / 2 
    off2 = (max_dim*1.414 - dim2) / 2
  end
  
  print("off")
  print(off1 .. " " .. off2)


  base_img:paste(image, off1, off2)

  local texture = lovr.graphics.newTexture(base_img, {mipmaps = false, msaa = 64})
  return texture
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