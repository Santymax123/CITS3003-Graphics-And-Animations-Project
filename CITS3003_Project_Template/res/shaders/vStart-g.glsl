attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec2 vTexCoord;

//Vertex variables for fragment shader to utilize
varying vec2 texCoord;
varying vec4 position;
varying vec3 norm;

uniform mat4 ModelView;
uniform mat4 Projection;

void main()
{
    vec4 vpos = vec4(vPosition, 1.0);

    texCoord = vTexCoord;
    norm = vNormal;
    position = vpos;

    gl_Position = Projection * ModelView * vpos;

}
