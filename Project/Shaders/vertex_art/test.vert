vec4 lovrmain(){
    gl_PointSize = 100.;
    float x = mod(vertexId, 10.);
    float y = floor(vertexId/10.);
    v_color = vec4(1, 1, 1, 1);
    return Projection * View * Transform * vec4(x/9., y/9., 0, 1); 
}