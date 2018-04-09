#version 120

uniform sampler2D tex;

vec4 effect(sampler2D tex, vec2 texCoord);

void main() {
  gl_FragColor = effect(tex, gl_TexCoord[0].xy);
}

vec4 effect(sampler2D tex, vec2 texCoord) {
	// return vec4(texCoord, 1.0, 1.0);
	return texture2D(tex, texCoord);
	// return texture2D(tex, texCoord) + vec4(texCoord, 1.0, 1.0);
}