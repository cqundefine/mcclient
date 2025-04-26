#version 330 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 color;
out vec4 fragColor;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

void main()
{
    gl_Position = projection * view * model * vec4(position, 1.0);
    // fragColor = vec4(position / 5.0, 1.0) + 0.5;
    fragColor = vec4(color, 1.0);
}
