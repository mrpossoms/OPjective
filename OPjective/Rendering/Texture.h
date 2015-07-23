//
//  Texture.h
//  OPjective
//
//  Created by Kirk Roerig on 8/21/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Texture : NSObject

@property (nonatomic) GLuint textureId;

+ (id) create2DWithWidth: (GLint)width andHeight:(GLint)height usingData:(void*)data;
+ (id) createDepthWithWidth: (GLint)width andHeight:(GLint)height usingData:(void*)data;


- (void) updateWidth: (GLint)width andHeight:(GLint)height usingData:(const void*)data asDepthTexture:(BOOL)isDepth;
- (void) isSmooth:(BOOL)smooth;
- (void) shouldWrap:(BOOL)wrap;
@end
