# ALL WE LEARNED
## help
https://app.slack.com/client/T59PJ1KCJ/C59QZ4V6Y

## ADB
we use adb, which is actually neat

connect via usb, give permission adn give adb permission

    $ adb tcpip 5555
    restarting in TCP mode port: 5555
    $ adb connect <ip>:5555
    connected to 192.168.1.193:5555

and you're wireless!

to udapte the  code use

    adb push --sync <local-path>/. /sdcard/Android/data/org.lovr.app/files

and for LODR

    adb push --sync <local-path>/. /sdcard/Android/data/org.lovr.hotswap/files/.lodr


If your program contains print statements, you can view them with:

    adb logcat | grep -i lovr


## LOVR and LODR
LOVR is the base, LODR give hotswapping, making it possible to almost litteraly code on the fly

## Lua
lua-users.org/files/wiki_insecure/users/thomasl/luarefv51.pdf
https://stackoverflow.com/questions/53990332/how-to-get-an-actual-copy-of-a-table-in-lua


## want
- i want a class/functipojn that gives me all pressed buttons and joystick positions
can0t find anything specific un the docs

DeviceButton 

    Buttons on an input device.
    Value	Description
    trigger	The trigger button.
    thumbstick	The thumbstick.
    touchpad	The touchpad.
    grip	The grip button.
    menu	The menu button.
    a	The A button.
    b	The B button.
    x	The X button.
    y	The Y button.
    proximity	The proximity sensor on a headset.

- see if Canvases can be used for 2d animation/videos

- automate sync and grep woth vscode

- button to add vertices of sofa and other mobilia

## Math

Quaternions are cool but i need to wathc some more 3b1b now
They represent rotations, so they have also an axis of rotation 
you can also multiply a 3d vector by them and rotate it, if you mmultiply a cooridnate vector you get that vector rotated by that quaternion, or inversly that direction in the coordinate system define by the quaternion. Magic

## Theater
 
### 2D Images
planes are much comfier than boxes and don't need cubemaps
Canvases can render 3d things in a different place, project them onside the canvas and display as a  texture. Neat
using graphics.fill we can also just push a Image inside. this image is streched
we use a blank Image, paste our content, fill the canvas woith it and use that maybe

I want to then test some basics in moving the box around, maybe the pointer library could be useful
the UX of placing the screen isn't as easy as i envisioned but now thta i understand the isseus i can try some versions
ok netflix's version is easier and seems comfy, i hope there aren0t many hidden mechanics

perhaps more interesting content would help us
### moar
next is loading images from interesting sources

then we could test some audio reproduction

The end goal is a 3D media room with mobile seating and screen and some basic media selection and playback control
Should handle both video audio and images, from local sources and maybe something more

## Graphics
rendering tetures on 2d objects needs shaders, which is shit
BUT we can use canvases to generate the textures, apply the caonvas to a Material and then we don0t need them!
better

printing single color blobs didn0t work, maybe writing them to disk will be better
this can be done with
    lovr.filesystem.write("whatever.txt", blob)
and then 
    adb pull /sdcard/Android/data/org.lovr.hotswap/files/whatever.txt

## rotations
planes have defalt normal towards 0, 0, 1
idea 1: get direction between head and left hand and sue that for the center, easy to aim and to adjust, always normal to vision field
how the fuck do unpack work