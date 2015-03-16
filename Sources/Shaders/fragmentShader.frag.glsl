

varying lowp vec4 oColor;
varying highp vec2 oTexCoord;

uniform sampler2D tex;


void kore() {
	gl_FragColor = texture2D(tex, oTexCoord) * oColor;
}
