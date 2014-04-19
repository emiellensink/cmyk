//
//  Shader.vsh
//  glsltest
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

attribute vec4 position;
attribute vec2 texturecoordinate;

uniform mat4 modelViewProjectionMatrix;

varying vec2 vtc;

void main()
{
    gl_Position = modelViewProjectionMatrix * position;
	vtc = texturecoordinate;
}
