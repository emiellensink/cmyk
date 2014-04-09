//
//  Shader.vsh
//  glsltest
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    gl_Position = modelViewProjectionMatrix * position;
}
