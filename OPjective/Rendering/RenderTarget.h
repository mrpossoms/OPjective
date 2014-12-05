//
//  RenderTarget.h
//  OPjective
//
//  Created by Kirk Roerig on 12/5/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Texture.h"

#define RENDER_TARGET_COLOR 0x01
#define RENDER_TARGET_DEPTH 0x02

@interface RenderTarget : NSObject

@property (nonatomic) GLuint fboId;
@property (nonatomic) Texture* color;
@property (nonatomic) Texture* depth;

- (instancetype)initWithWidth:(GLsizei)width andHeight:(GLsizei)height andFlags:(unsigned int)flags;

@end
