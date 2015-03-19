// See http://www.sunsetlakesoftware.com/2013/10/21/optimizing-gaussian-blurs-mobile-gpu

attribute vec3 Position;
attribute vec2 TexCoord;
attribute vec4 VertexColor;


uniform float texelWidthOffset;
uniform float texelHeightOffset;
 
varying vec2 blurCoordinates[5];
 
void kore()
{
	gl_Position = vec4(Position.x, Position.y, Position.z, 1.0);
 
	vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
	blurCoordinates[0] = TexCoord.xy;
	blurCoordinates[1] = TexCoord.xy + singleStepOffset * 1.407333;
	blurCoordinates[2] = TexCoord.xy - singleStepOffset * 1.407333;
	blurCoordinates[3] = TexCoord.xy + singleStepOffset * 3.294215;
	blurCoordinates[4] = TexCoord.xy - singleStepOffset * 3.294215;
}