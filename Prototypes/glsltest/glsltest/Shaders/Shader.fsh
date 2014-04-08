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
	c = gl_LastFragData[0].rgba - color;
	
    gl_FragColor = c;
}
