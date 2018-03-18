#version 120

attribute vec4 sp_Position;
attribute vec4 sp_TexCoord;

void main() {
  gl_Position = sp_Position;
  gl_TexCoord[0] = sp_TexCoord;
}