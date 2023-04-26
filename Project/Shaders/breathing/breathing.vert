Constants {
    float time;
};


vec4 lovrmain() {
    vec4 vertexPos = Projection * View * Transform *  VertexPosition;
    vertexPos.x *=  1 + (.03 * sin(time));
    vertexPos.y *=  1 + (.04 * cos(time * vertexPos.y * vertexPos.y));
    
    // * vertexPos.y;
    return vertexPos;
}
