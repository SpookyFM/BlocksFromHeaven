attribute vec3 Position;

void kore()
{
  gl_Position = vec4(Position.x, Position.y, Position.z, 1.0);
}
