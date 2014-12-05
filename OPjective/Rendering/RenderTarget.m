//
//  RenderTarget.m
//  OPjective
//
//  Created by Kirk Roerig on 12/5/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "RenderTarget.h"

@implementation RenderTarget

- (instancetype)initWithWidth:(GLsizei)width andHeight:(GLsizei)height andFlags:(unsigned int)flags
{
    self = [super init];
    
    if(self){
        glGenFramebuffers(1, &_fboId);
        glBindFramebuffer(GL_FRAMEBUFFER, _fboId);
        
        if(flags & RENDER_TARGET_COLOR){
            _color = [Texture create2DWithWidth:width andHeight:height usingData:NULL];
            glFramebufferTexture2D(
                                   GL_FRAMEBUFFER,
                                   GL_COLOR_ATTACHMENT0,
                                   GL_TEXTURE_2D,
                                   _color.textureId,
                                   0
            );
        }
        
        if(flags & RENDER_TARGET_DEPTH){
            _depth = [Texture create2DWithWidth:width andHeight:height usingData:NULL];
            glFramebufferTexture2D(
                                   GL_FRAMEBUFFER,
                                   GL_DEPTH_ATTACHMENT,
                                   GL_TEXTURE_2D,
                                   _depth.textureId,
                                   0
            );
        }
    }
    
    return self;
}

- (void)dealloc
{
    glDeleteFramebuffers(1, &_fboId);
}

@end
