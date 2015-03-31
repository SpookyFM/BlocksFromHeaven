#version 100

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D texActive;
uniform sampler2D texInactive;
uniform sampler2D texCutoff;

uniform float cutoff;


varying vec2 texCoord;


void kore() {
	vec4 activeTexcolor = texture2D(texActive, texCoord);
	vec4 inactiveTexcolor = texture2D(texInactive, texCoord);
	float cutoffTex = texture2D(texCutoff, texCoord).x;
	if (cutoffTex > cutoff) {
		gl_FragColor = inactiveTexcolor;
	} else {
		gl_FragColor = activeTexcolor;
	}
	
	//texcolor.rgb *= color.a;
	//gl_FragColor = texcolor;
}
