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
    
    // Calculate darkness factor based on Y position
    float darkness = clamp((position.y - 50.0) / 30.0, 0.0, 1.0); // 50-80 range maps to 0-1
    
    // Apply darkness to color
    fragColor = vec4(color * darkness, 1.0);
}
