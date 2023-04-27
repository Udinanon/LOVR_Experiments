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
    -- lovr.headset.getOrientation is missing!
    lovr.headset.getHands = function()
        return headsetData.hands
    end
    lovr.headset.isTracked = function(device)
        return headsetData.tracked[device] or false
    end
    lovr.headset.getPose = function(device)
        local x, y, z, angle, ax, ay, az = unpack(headsetData.pose[device or 'head'])
        x = x + offset.x
        y = y + offset.y
        z = z + offset.z
        return x, y, z, angle, ax, ay, az
    end
    lovr.headset.getPosition = function(device)
        local x, y, z = unpack(headsetData.pose[device or 'head'] or {0, 0, 0})
        x = x + offset.x
        y = y + offset.y
        z = z + offset.z
        return x, y, z
    end
    lovr.headset.getVelocity = function(device)
        return unpack(headsetData.velocity[device or 'head'])
    end
    lovr.headset.getAngularVelocity = function(device)
        return unpack(headsetData.angularVelocity[device or 'head'])
    end
    lovr.headset.getSkeleton = function(hand)
        return headsetData.skeleton[hand]
    end
    lovr.headset.isTouched = function(hand, button)
        return headsetData.isTouched[hand][button] or false
    end
    lovr.headset.isDown = function(hand, button)
        return headsetData.isDown[hand][button] or false
    end
    lovr.headset.wasPressed = function(hand, button)
        return headsetData.wasPressed[hand][button] or false
    end
    lovr.headset.wasReleased = function(hand, button)
        return headsetData.wasReleased[hand][button] or false
    end
    lovr.headset.getAxis = function(hand, axis)
        if headsetData.axes[hand] then
            return unpack(headsetData.axes[hand][axis])
        end
    end
end

function Demo:update_inputs()
    _, headsetData = serpent.load(Demo.file:read("*l"))
end

return Demo