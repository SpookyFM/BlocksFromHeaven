

varying lowp vec4 oColor;
varying highp vec2 oTexCoord;

uniform sampler2D tex;

uniform mediump float t;

// For blurring
uniform highp float texelWidthOffset;
uniform highp float texelHeightOffset;
 

varying highp vec2 blurCoordinates[5];


void kore() {
	
	// Compute the blurred pixel
	lowp vec4 sum = vec4(0.0);
	sum += texture2D(tex, blurCoordinates[0]) * 0.204164;
	sum += texture2D(tex, blurCoordinates[1]) * 0.304005;
	sum += texture2D(tex, blurCoordinates[2]) * 0.304005;
	sum += texture2D(tex, blurCoordinates[3]) * 0.093913;
	sum += texture2D(tex, blurCoordinates[4]) * 0.093913;
	
	
	gl_FragColor = (t * texture2D(tex, oTexCoord) + (1.0 - t) * sum) * oColor;
}
