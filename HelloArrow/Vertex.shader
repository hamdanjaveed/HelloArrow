attribute vec4 position;
attribute vec4 sourceColor;
varying vec4 destinationColor;
uniform mat4 projection;
uniform mat4 modelView;

void main() {
    destinationColor = sourceColor;
    gl_Position = projection * modelView *position;
}