//
//  Texture.m
//  OPjective
//
//  Created by Kirk Roerig on 8/21/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Texture.h"
#import "Mesh.h"

@interface Texture()

@end

@implementation Texture

static Texture* currentTexture = nil;

#pragma mark - Static helpers
+ (id) create2DWithWidth: (GLint)width andHeight:(GLint)height usingData:(void*)data
{
    Texture* tex = [[Texture alloc] init];
    
    // generate the texture
    GLuint texId;
    glGenTextures(1, &texId);
    glBindTexture(GL_TEXTURE_2D, texId);
    tex.textureId = texId;
    
    // set the texture's data and properties
    [tex updateWidth:width andHeight:height usingData:data];
    
    return tex;
}

#pragma mark - Class methods
- (void) updateWidth:(GLint)width andHeight:(GLint)height usingData:(const void *)data
{
    // bind the texture if it's not already
    if(currentTexture != self){
        glBindTexture(GL_TEXTURE_2D, _textureId);
        currentTexture = self;
    }
    
    // set the texture's data and properties
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    [self shouldWrap:YES];
    [self isSmooth:YES];
}

- (void) isSmooth:(BOOL)smooth;
{
    if(smooth){
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    }
    else{
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    }
}

- (void) shouldWrap:(BOOL)wrap
{
    if(wrap){
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    }
    else{
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
}

@end
