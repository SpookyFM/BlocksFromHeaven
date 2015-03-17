uniform mediump vec4 uStartColor;
uniform mediump vec4 uEndColor;
uniform mediump float uT;

void kore() {
	gl_FragColor = uStartColor * uT + uEndColor * (1.0 - uT);
}

