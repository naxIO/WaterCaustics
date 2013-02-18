vertex:

attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec2 vTexCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

varying vec2 texCoord;

varying vec3 normal;
varying vec3 position;
varying float fogFactor;

void main(){

    //OpenGL uses column-major operator on left (P*V*M * v1 = v2) convention. 
    // (MVP * position)
    //Same as row-major operator on right (v1 * M*V*P = v2)
    position = vPosition;
    normal = vNormal;
    gl_Position = view * model * vec4(vPosition,1.0);
    fogFactor = min(-gl_Position.z/300.0, 1.0);
    gl_Position = projection * gl_Position;

    texCoord = vTexCoord;
}

fragment:

const float e = 2.71828182845904523536028747135266249;
const vec4 waterColour = vec4(0.0, 0.49, 1.0, 1.0);

varying vec2 texCoord;
varying float fogFactor;

uniform sampler2D texture; 
uniform sampler2D caustics; 

uniform float depth; 
  
vec4 fog(vec4 color, vec4 fcolor, float depth, float density)
{
   float f=pow(e, -pow(depth*density, 2));
   return mix(fcolor, color, f);
}

void main()
{
    vec4 fragColour;
    
    fragColour = texture2D(texture, texCoord);
	fragColour = fragColour * (1.0-fogFactor) + waterColour * (fogFactor);

    vec4 caustic = vec4(texture2D(caustics, texCoord)) * (1.0-fogFactor);
    
    fragColour += caustic;
    fragColour.a = 1.0;

    gl_FragColor = fragColour;
}