uniform sampler2D tex;

uniform highp float texelWidthOffset;
uniform highp float texelHeightOffset;
 

varying highp vec2 blurCoordinates[5];
 
void kore()
{
	lowp vec4 sum = vec4(0.0);
	sum += texture2D(tex, blurCoordinates[0]) * 0.204164;
	sum += texture2D(tex, blurCoordinates[1]) * 0.304005;
	sum += texture2D(tex, blurCoordinates[2]) * 0.304005;
	sum += texture2D(tex, blurCoordinates[3]) * 0.093913;
	sum += texture2D(tex, blurCoordinates[4]) * 0.093913;
	gl_FragColor = sum;
}