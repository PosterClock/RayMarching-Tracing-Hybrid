// Author:
// Title:

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


vec2 DE(vec3 pos){
    float distSphere = sdSphere(pos);
    float distPlane = sdPlane(pos);

    if (distSphere < distPlane){
        return vec2(distSphere, 1);
    }

    return vec2(distPlane, 2);
}

vec3 norm( in vec3 p ) // For GLSL / HLSL raymarching
{
    const float h = 0.0001; // Small offset value
    const vec2 k = vec2(1.0, -1.0);
    
    return normalize( k.xyy * DE( p + k.xyy*h ).x + 
                      k.yyx * DE( p + k.yyx*h ).x + 
                      k.yxy * DE( p + k.yxy*h ).x + 
                      k.xxx * DE( p + k.xxx*h ).x );
}


void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;

    vec3 rayDirection = normalize(vec3(st.x-0.5, st.y-0.5, -1.0));
    vec3 startPosition = vec3(0, 1, 5);
    vec3 color = vec3(0.0);
    float r = 0.0;
    
    vec3 lightPosition = vec3(sin(u_time)*2.0, 1, cos(u_time)*2.0);
    vec3 lightColour = vec3(0.907,1.000,0.892);
    
    float distanceTravelled = 0.; 
    vec3 currentPosition;
    vec3 intersectionPoint =vec3(100000.0);
    
    
    for (int i = 0; i<1000; i++){
        currentPosition = startPosition +rayDirection*r;
        vec2 d = DE(currentPosition);
        
        
        if (d.x < HIT_EPSILON){
            if (d.y == 2.){ // hit plane, easy reflection
             reflect(rayDirection, norm(currentPosition));
             intersectionPoint = currentPosition;
            }
            
            else if (d.y == 1.){ // simulate glass
                
              if (d.x <= 0.0){ // inside
               r+=(-d.x);    
              }
              else {
               reflect(rayDirection, -norm(currentPosition));
              }
                
            }
        }
        
        if (distance(currentPosition, lightPosition) < HIT_EPSILON){
            break;
        }
        
        
        r+=d.x;
        distanceTravelled += d.x;
        
    }
 //   distance*=10.0;
    if (intersectionPoint != vec3(100000.0)){
     color = vec3(lightColour/((distance(lightPosition, intersectionPoint)*distance(lightPosition, intersectionPoint)) ));
    }
        
    gl_FragColor = vec4(color,1.0);
}
