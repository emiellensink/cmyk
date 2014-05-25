//
//  Shader.fsh
//  glsltest
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#extension GL_EXT_shader_framebuffer_fetch : require

uniform lowp vec4 color;

void main()
{
	lowp vec4 c = color;
	lowp vec4 src = gl_LastFragData[0].rgba;
	
	c = color;
	if (color.r < 0.1 && color.g > 0.9 && color.b < 0.1) c.rgba = vec4(1, 1, 0, 1);

	// red
	if (src.r > 0.7 && src.g < 0.3 && src.b < 0.3)
	{
		if (c.r > 0.9 && c.g < 0.1 && c.b < 0.1) c.rgba = vec4(1, 0, 0, 1);
		if (c.r > 0.9 && c.g > 0.9 && c.b < 0.1) c.rgba = vec4(1, 0.5, 0, 1);
		if (c.r < 0.1 && c.g < 0.1 && c.b > 0.9) c.rgba = vec4(0.65, 0, 1, 1);
	}
	
	// yellow
	if (src.r > 0.7 && src.g > 0.7 && src.b < 0.3)
	{
		if (c.r > 0.9 && c.g < 0.1 && c.b < 0.1) c.rgba = vec4(1, 0.5, 0, 1);
		if (c.r > 0.9 && c.g > 0.9 && c.b < 0.1) c.rgba = vec4(1, 1, 0, 1);
		if (c.r < 0.1 && c.g < 0.1 && c.b > 0.9) c.rgba = vec4(0, 1, 0, 1);
	}
	
	// blue
	if (src.r < 0.3 && src.g < 0.3 && src.b > 0.7)
	{
		if (c.r > 0.9 && c.g < 0.1 && c.b < 0.1) c.rgba = vec4(0.65, 0, 1, 1);
		if (c.r > 0.9 && c.g > 0.9 && c.b < 0.1) c.rgba = vec4(0, 1, 0, 1);
		if (c.r < 0.1 && c.g < 0.1 && c.b > 0.9) c.rgba = vec4(0, 0, 1, 1);
	}

	// orange
	if (src.r > 0.7 && src.g > 0.3 && src.g < 0.7 && src.b < 0.3)
	{
		if (c.r > 0.9 && c.g < 0.1 && c.b < 0.1) c.rgba = vec4(1, 0, 0, 1);
		if (c.r > 0.9 && c.g > 0.9 && c.b < 0.1) c.rgba = vec4(1, 1, 0, 1);
		if (c.r < 0.1 && c.g < 0.1 && c.b > 0.9) c.rgba = vec4(0, 0, 0, 1);
	}
	
	// green
	if (src.r < 0.3 && src.g > 0.7 && src.b < 0.3)
	{
		if (c.r > 0.9 && c.g < 0.1 && c.b < 0.1) c.rgba = vec4(0, 0, 0, 1);
		if (c.r > 0.9 && c.g > 0.9 && c.b < 0.1) c.rgba = vec4(1, 1, 0, 1);
		if (c.r < 0.1 && c.g < 0.1 && c.b > 0.9) c.rgba = vec4(0, 0, 1, 1);
	}

	// purple
	if (src.r > 0.3 && src.r < 0.7 && src.g < 0.3 && src.b > 0.7)
	{
		if (c.r > 0.9 && c.g < 0.1 && c.b < 0.1) c.rgba = vec4(1, 0, 0, 1);
		if (c.r > 0.9 && c.g > 0.9 && c.b < 0.1) c.rgba = vec4(0, 0, 0, 1);
		if (c.r < 0.1 && c.g < 0.1 && c.b > 0.9) c.rgba = vec4(0, 0, 1, 1);
	}

	c.a = 1.0;
	
    gl_FragColor = c;
}
