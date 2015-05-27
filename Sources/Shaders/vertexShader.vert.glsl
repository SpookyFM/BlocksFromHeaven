uniform mat4 Mvpm;
attribute vec3 Position;
attribute vec2 TexCoord;
attribute vec4 VertexColor;


//uniform mediump vec4 UniformColor;
varying  lowp vec4 oColor;
varying highp vec2 oTexCoord;

// For blurring
uniform float texelWidthOffset;
uniform float texelHeightOffset;
 
varying vec2 blurCoordinates[5];

void kore()
{
  gl_Position = Mvpm * vec4(Position.x, Position.y, Position.z, 1.0);
  oTexCoord = TexCoord;
  //oColor = UniformColor;
  oColor = VertexColor;
  
  // For blurring
  vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
	blurCoordinates[0] = TexCoord.xy;
	blurCoordinates[1] = TexCoord.xy + singleStepOffset * 1.407333;
	blurCoordinates[2] = TexCoord.xy - singleStepOffset * 1.407333;
	blurCoordinates[3] = TexCoord.xy + singleStepOffset * 3.294215;
	blurCoordinates[4] = TexCoord.xy - singleStepOffset * 3.294215;
  
}
