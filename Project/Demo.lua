-- Heavily inspired and borrows from https://github.com/jmiskovic/syncset

-- nomenclature: 
--- Host: recorder
--- Playback: player

local Demo = {}

local serpent = serpent or require("serpent")

function Demo:init_enums()
    -- this is local in main in the Playback, so local here is problematic
    -- moved to Demo.?? 
    buttons = { 'trigger', 'thumbstick', 'touchpad', 'grip', 'menu', 'a', 'b', 'x', 'y', 'proximity' }
    axes = { 'trigger', 'thumbstick', 'touchpad', 'grip' }
    headsetData = {
    hands = {},
    tracked = {},
    angularVelocity = {
      head           = {0,0,0},
    },
    pose = {
      head           = {0,0,0,0,0,0,0},
    },
    velocity = {
      head           = {0,0,0,0,0,0,0},
    },
    isTouched = {},
    isDown = {},
    wasPressed = {},
    wasReleased = {},
    axes = {},
    skeleton = {},
    }
    offset = lovr.math.newVec3(0, 0.2, -0.7)
end

Demo:init_enums()

function Demo:init_writing(filename)
    local filename = filename or "demo.txt"
    -- might want to chek for file existance before?
    --onl works on PC    
    --local file = assert(io.open(filename, "w+"))
    lovr.filesystem.write(filename, "")
    print("Opened demo.txt")
    Demo.file = filename
end

function Demo:record_state()
    headsetData.hands = lovr.headset.getHands()
    headsetData.tracked = {}
    headsetData.velocity['head'] = { lovr.headset.getVelocity('head') }
    headsetData.angularVelocity['head'] = { lovr.headset.getAngularVelocity('head') }
    headsetData.pose['head'] = { lovr.headset.getPose('head') }
    for i, hand in ipairs(headsetData.hands) do
        headsetData.tracked[hand] = lovr.headset.isTracked(hand) or nil
        headsetData.velocity[hand] = { lovr.headset.getVelocity(hand) }
        headsetData.angularVelocity[hand] = { lovr.headset.getAngularVelocity(hand) }
        headsetData.pose[hand] = { lovr.headset.getPose(hand) }
        local handpoint = hand .. '/point'
        headsetData.pose[handpoint] = { lovr.headset.getPose(handpoint) }
        headsetData.isTouched[hand] = {}
        headsetData.isDown[hand] = {}
        headsetData.wasPressed[hand] = {}
        headsetData.wasReleased[hand] = {}
        for _, button in ipairs(buttons) do
            headsetData.isTouched[hand][button] = lovr.headset.isTouched(hand, button) or nil
            headsetData.isDown[hand][button] = lovr.headset.isDown(hand, button) or nil
            headsetData.wasPressed[hand][button] = lovr.headset.wasPressed(hand, button) or nil
            headsetData.wasReleased[hand][button] = lovr.headset.wasReleased(hand, button) or nil
        end
        headsetData.axes[hand] = {}
        for _, axis in ipairs(axes) do
            headsetData.axes[hand][axis] = { lovr.headset.getAxis(hand, axis) }
        end
        headsetData.skeleton[hand] = lovr.headset.getSkeleton(hand)
    end
    local dump = serpent.dump(headsetData)
    lovr.filesystem.append(Demo.file, dump .. "\n")
    -- only works on linux
    --Demo.file:write(dump.."\n")
    --Demo.file:flush() --flush buffer to avoid missing data in case of crash
    -- vould be moved to errhandler or something idk


end

function Demo:init_read(filename)
    local filename = filename or "demo.txt"
    -- might want to chek for file existance before?
    local file = assert(io.open(filename, "r"))
    print("Opened demo.txt")
    Demo.file = file
    Demo:update_inputs()
    print(serpent.dump(headsetData))
end

function Demo:setup_inputs()

    -- monkey-patch LOVR headset functions so they return data from actual headset

    --main weakness is lack of defaults. if something was not recorderd or not available, the program fails
    -- either we return some fdefaults or we learn howt o say "unavailable"

    -- normally, if a device is not available, false is returned
    -- for unpacks, we read from the data, and if missing, the nil is substituted with a 0 position
    -- but others instad have the issue that delving deep into non existing tables fails instead of returning nil
    -- for these we use if guards. the implied return now is empty. not nil
    -- so we retunr a false or { 0  0}
    -- lovr.headset.getOrientation is missing!
    lovr.headset.getHands = function()
        return headsetData.hands
    end
    lovr.headset.isTracked = function(device)
        return headsetData.tracked[device] or false
    end
    lovr.headset.getPose = function(device)
        if device == "left" then
            device = "hand/left"
        elseif device == "right" then
            device = "hand/left"
        end
        local data = headsetData.pose[device or 'head'] or {0, 0, 0, 0, 0, 0, 0}
        local x, y, z, angle, ax, ay, az = unpack(data)
        x = x + offset.x
        y = y + offset.y
        z = z + offset.z
        return x, y, z, angle, ax, ay, az
    end
    lovr.headset.getPosition = function(device)
        if device == "left" then
            device = "hand/left"
        elseif device == "right" then
            device = "hand/left"
        end
        local data = headsetData.pose[device or 'head'] or { 0, 0, 0, 0, 0, 0, 0 }
        local x, y, z = unpack(data)
        x = x + offset.x
        y = y + offset.y
        z = z + offset.z
        return x, y, z
    end
    lovr.headset.getVelocity = function(device)
        if device == "left" then
            device = "hand/left"
        elseif device == "right" then
            device = "hand/left"
        end
        local data = headsetData.velocity[device or 'head'] or {0, 0, 0}
        return unpack(data)
    end
    lovr.headset.getAngularVelocity = function(device)
        if device == "left" then
            device = "hand/left"
        elseif device == "right" then
            device = "hand/left"
        end
        local data = headsetData.angularVelocity[device or 'head'] or { 0, 0, 0 }
        return unpack(data)
    end
    lovr.headset.getSkeleton = function(device)
        if device == "left" then
            device = "hand/left"
        elseif device == "right" then
            device = "hand/left"
        end
        return headsetData.skeleton[device]
    end
    lovr.headset.isTouched = function(device, button)
        if device == "left" then
            device = "hand/left"
        elseif device == "right" then
            device = "hand/left"
        end
        if headsetData.isTouched[device] then
            return headsetData.isTouched[device][button] or false
        end
        return false
    end
    lovr.headset.isDown = function(device, button)
        if device == "left" then
            device = "hand/left"
        elseif device == "right" then
            device = "hand/left"
        end
        if headsetData.isDown[device] then
            return headsetData.isDown[device][button] or false
        end
        return false
    end
    lovr.headset.wasPressed = function(device, button)
        if device == "left" then
            device = "hand/left"
        elseif device == "right" then
            device = "hand/left"
        end
        if headsetData.wasPressed[device] then
            return headsetData.wasPressed[device][button] or false
        end
        return false
    end
    lovr.headset.wasReleased = function(device, button)
        if device == "left" then
            device = "hand/left"
        elseif device == "right" then
            device = "hand/left"
        end
        if headsetData.wasReleased[device] then
            return headsetData.wasReleased[device][button] or false
        end
        return false
    end
    lovr.headset.getAxis = function(device, axis)
        if device == "left" then
            device = "hand/left"
        elseif device == "right" then
            device = "hand/left"
        end
        if headsetData.axes[device] then
            return unpack(headsetData.axes[device][axis])
        end
        return 0, 0 -- guard aganist unavailables axes, as all are 1D or 2D
    end
end

function Demo:update_inputs()
    _, headsetData = serpent.load(Demo.file:read("*l"))
end

function Demo:test_inputs()
    -- on some cases, isDown and isTouched can return nothing. not nil, nothing
    print("Types")
    print(type(lovr.headset.getHands()))
    print(type(lovr.headset.isTracked("hand/right")))          -- boolean
    print(type(lovr.headset.getPose("hand/right")))            -- 7 number
    print(type(lovr.headset.getPosition("hand/right")))        -- 3 numb
    print(type(lovr.headset.getVelocity("hand/right")))        -- 3 numb
    print(type(lovr.headset.getAngularVelocity("hand/right"))) --
    print(type(lovr.headset.getSkeleton("hand/right")))        -- nil
    print(type(lovr.headset.wasPressed("hand/right", "a")))
    print(type(lovr.headset.wasReleased("hand/right", "a")))
    print(type(lovr.headset.getAxis("hand/right", "thumbstick")))

    print("Values")
    print(lovr.headset.getHands()) -- table
    print(lovr.headset.isTracked("hand/right")) -- boolean
    print(lovr.headset.getPose("hand/right")) -- 7 number
    print(lovr.headset.getPosition("hand/right")) -- 3 number
    print(lovr.headset.getVelocity("hand/right")) -- 3 number
    print(lovr.headset.getAngularVelocity("hand/right")) -- 3 number
    print(lovr.headset.getSkeleton("hand/right")) -- nil
    print(lovr.headset.isTouched("hand/right", "a"))  -- empty
    print(lovr.headset.isDown("hand/right", "a")) -- empty
    print(lovr.headset.wasPressed("hand/right", "a")) --boolean
    print(lovr.headset.wasReleased("hand/right", "a")) -- boolean
    print(lovr.headset.getAxis("hand/right", "thumbstick")) -- 2 number


end

return Demo