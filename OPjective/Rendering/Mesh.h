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
    const char* name;
    int         elements;
    int         offset;
};

@interface Mesh : NSObject

- (id) initWithVertexDescription:(struct vertexAttribute*)description withAttributeCount:(int)count usingData:(void*)data withLength:(GLsizeiptr)len;
- (id) withAttributeName:(const char*)name andElements:(int)elements;
- (void) updateData:(void*)data ofSize:(GLsizeiptr)size;
- (void) bindWithShader:(Shader *)shader;
- (void) drawAs:(GLenum)type;

@end
