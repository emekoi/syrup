#version 120

attribute vec2 sp_Position;
attribute vec2 sp_TexCoord;

void main() {
  gl_Position = vec4(sp_Position, 0.0, 1.0);
  gl_TexCoord[0] = vec4(sp_TexCoord, 0.0, 0.0);
}