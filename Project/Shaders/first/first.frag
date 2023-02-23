in vec3 pos;
vec4 lovrmain() {
    return vec4(abs(PositionWorld.x), abs(PositionWorld.y), abs(PositionWorld.z),1.0);
}
