uniform mat4 Mvpm;
attribute vec3 Position;
attribute vec2 TexCoord;
attribute vec4 VertexColor;


//uniform mediump vec4 UniformColor;
varying  lowp vec4 oColor;
varying highp vec2 oTexCoord;

void kore()
{
  gl_Position = Mvpm * vec4(Position.x, Position.y, Position.z, 1.0);
  oTexCoord = TexCoord;
  //oColor = UniformColor;
  oColor = VertexColor;
}
