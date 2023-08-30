// thank you bjonrbytes
// https://gist.githubusercontent.com/bjornbytes/5c29123bc1aa62e774b56a56165b7e37/raw/d2fdee0abf95df7bbc72026c1ceeb3ff12988a8d/stereo-mirror.lua

layout(set = 2, binding = 0) uniform texture2DArray canvas;

vec4 lovrmain() {
    vec2 eyeUV = UV * vec2(2, 1);
    float eyeIndex = floor(UV.x * 2.);
    return Color * getPixel(canvas, eyeUV, eyeIndex);
}