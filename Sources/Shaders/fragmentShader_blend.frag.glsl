

varying lowp vec4 oColor;
varying highp vec2 oTexCoord;

uniform sampler2D tex;
uniform sampler2D tex2;
uniform mediump float t;


void kore() {
	gl_FragColor = (t * texture2D(tex, oTexCoord) + (1.0 - t) * texture2D(tex2, oTexCoord)) * oColor;
}
