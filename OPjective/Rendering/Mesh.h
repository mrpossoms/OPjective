//
//  Mesh.h
//  OPjective
//
//  Created by Kirk Roerig on 8/20/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Shader.h"

struct vertexAttribute{
    char    name[32];
    int     elements;
    int     offset;
    GLenum  dataType;
    GLsizei elementSize;
};

@interface Mesh : NSObject

@property (nonatomic) GLuint vertices;

- (id) withAttributeName:(const char*)name andElements:(int)elements;
- (id) withAttributeName:(const char*)name andElements:(int)elements ofDataType:(GLenum)type;
- (void) withExplicitStride:(unsigned int)stride;
- (unsigned int)stride;
- (void) updateData:(void*)data ofSize:(GLsizeiptr)size;
- (void) updateData:(void*)data ofSize:(GLsizeiptr)dsize andIndicies:(GLuint*)indices ofSize:(GLsizeiptr)isize;
- (void) bindWithShader:(Shader *)shader;
- (void) drawAs:(GLenum)type;

@end
