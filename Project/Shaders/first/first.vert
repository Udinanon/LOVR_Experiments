out vec3 pos;
vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
    pos = lovrPosition.xyz;
    return projection * transform * vertex;
}