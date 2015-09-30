//
//  RenderTarget.m
//  OPjective
//
//  Created by Kirk Roerig on 12/5/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "RenderTarget.h"

BOOL RENDERING_TO_TEXTURE = NO;

@interface RenderTarget(){
    GLsizei rtWidth, rtHeight;
}

@end

@implementation RenderTarget

- (instancetype)initWithWidth:(GLsizei)width andHeight:(GLsizei)height andFlags:(unsigned int)flags
{
    self = [super init];
    
    if(self){
        glGenFramebuffers(1, &_fboId);
        glBindFramebuffer(GL_FRAMEBUFFER, _fboId);
        
        rtWidth = width;
        rtHeight = height;
        
        if(flags & RENDER_TARGET_COLOR){
            _color = [Texture create2DWithWidth:width andHeight:height usingData:NULL];
            [_color shouldWrap:NO];
            glFramebufferTexture2D(
                                   GL_FRAMEBUFFER,
                                   GL_COLOR_ATTACHMENT0,
                                   GL_TEXTURE_2D,
                                   _color.textureId,
                                   0
            );
        }
        
        if(flags & RENDER_TARGET_DEPTH){
            _depth = [Texture createDepthWithWidth:width andHeight:height usingData:NULL];
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depth.textureId);
        }
        
        assert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE);
    }
    
    return self;
}

- (void)bind
{
    RENDERING_TO_TEXTURE = YES;
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, _fboId);
    GLcheckError();
}

- (void)unbind
{
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    GLcheckError();

    RENDERING_TO_TEXTURE = NO;
}

- (void)dealloc
{
    glDeleteFramebuffers(1, &_fboId);
}

@end
