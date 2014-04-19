//
//  Shader.fsh
//  glsltest
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

uniform sampler2D colorTexture;
varying lowp vec2 vtc;

void main()
{
	gl_FragColor = texture2D(colorTexture, vtc);
}
