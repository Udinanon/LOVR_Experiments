out vec3 pos;
vec4 lovrmain() {
    pos = VertexNormal.xyz;
    return Projection * View * Transform * VertexPosition;
}