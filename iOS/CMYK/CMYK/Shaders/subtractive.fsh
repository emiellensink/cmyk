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
	
	if (src.r < 0.5 && src.g < 0.5 && src.b < 0.5) src.rgba = vec4(1, 1, 1, 1);
	
	c = src - color;
	
    gl_FragColor = c;
}
