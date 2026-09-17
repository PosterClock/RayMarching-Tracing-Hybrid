#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define HIT_EPSILON 0.0001

float sdSphere( vec3 p)
{
  vec3 tetraPos = vec3(0, 1, 0);  
    p-=tetraPos;
  // n must be normalized
  return length(p)-1.;
}

float sdPlane( vec3 p)
{
  // n must be normalized
  return p.y;
}


float DE(vec3 pos){
    return min(sdSphere(pos), sdPlane(pos));
}

vec3 norm( in vec3 p ) // For GLSL / HLSL raymarching
{
    const float h = 0.0001; // Small offset value
    const vec2 k = vec2(1.0, -1.0);
    
    return normalize( k.xyy * DE( p + k.xyy*h ) + 
                      k.yyx * DE( p + k.yyx*h ) + 
                      k.yxy * DE( p + k.yxy*h ) + 
                      k.xxx * DE( p + k.xxx*h ) );
}


void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;

    vec3 rayDirection = normalize(vec3(st.x-0.5, st.y-0.5, -1.0));
    vec3 startPosition = vec3(0, 1, 5);
    vec3 color = vec3(0.0);
    float r = 0.0;
    
    vec3 lightPosition = vec3(u_mouse.x/u_resolution.x*2.0-1.0, u_mouse.y/u_resolution.y*2.0-1.0, cos(u_time)*2.0);
    vec3 lightColour = vec3(1.000,0.950,0.981);
    
    float distanceTravelled = 0.; 
    vec3 currentPosition;
    vec3 intersectionPoint = vec3(0.566,0.905,0.244);
    
    for (int i = 0; i<1000; i++){
        currentPosition = startPosition +rayDirection*r;
        float d = DE(currentPosition);
        
        
        if (d < HIT_EPSILON){
            reflect(rayDirection, norm(currentPosition));
            intersectionPoint = currentPosition;
            break; 
        }
        
        
        r+=d;
        distanceTravelled += d;
        
    }
 //   distance*=10.0;
    if (intersectionPoint != vec3(100000.0)){
     color = vec3(lightColour/((distance(lightPosition, intersectionPoint)*distance(lightPosition, intersectionPoint)) ));
    }
        
    gl_FragColor = vec4(color,1.0);
}
