// Buffers allow for large masses of data to be moved
layout(set = 2, binding = 0) uniform Positions {
  vec4 lights[5];
};
//Constants are faster and cheaper to move but are seriously memory limited
Constants {
  vec3 ambience;  
  vec3 lightColor;
  int n_lights;
};

vec4 lovrmain(){    
    //diffuse
    vec3 norm = normalize(Normal);
    vec3 diffuse = vec3(0.0);
    for( int i = 0; i < 5; i++){
      vec3 pos = lights[i].xyz;  
      vec3 lightDir = normalize(pos - PositionWorld); // unit vector of vertex-light  
      float diff = max(dot(norm, lightDir), 0.0); // represent how exposes the fragment is
      diffuse += diff * lightColor/n_lights; //apply to color
    }
    return vec4(diffuse, 1.); //apply ligth and ambiance
}