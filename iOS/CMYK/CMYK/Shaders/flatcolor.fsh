//
//  Shader.fsh
//  glsltest
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

uniform lowp vec4 color;

void main()
{
	lowp vec4 c = color;
    gl_FragColor = c;
}
