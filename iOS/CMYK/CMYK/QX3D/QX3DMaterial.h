//
//  QX3DMaterial.h
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

@import Foundation;
@import GLKit;

@interface QX3DMaterial : NSObject

+ (instancetype)materialWithVertexProgram:(NSString *)vertexName pixelProgram:(NSString *)pixelName attributes:(NSDictionary *)attribLocations;
- (instancetype)initWithVertexProgram:(NSString *)vertexName pixelProgram:(NSString *)pixelName attributes:(NSDictionary *)attribLocations;

- (GLint)uniformForParameter:(NSString *)name;

- (void)activate;

@end
