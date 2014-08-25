//
//  Mesh.m
//  OPjective
//
//  Created by Kirk Roerig on 8/20/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Mesh.h"

@interface Mesh()

@property (nonatomic) GLuint buffer;
@property (nonatomic) struct vertexAttribute* attributes;
@property (nonatomic) GLuint attributeCount;
@property (nonatomic) GLuint nextOffset;
@property (nonatomic) GLuint vertices;

@end

@implementation Mesh

static Shader* lastShader = nil;

-(void)checkError{
    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"Error: %x", err);
    //assert(err == GL_NO_ERROR);
}

- (id) init
{
    if(!self){
        self = [super init];
    }
    
    _attributeCount = 0;
    _nextOffset = 0;
    
    // generate buffers allocate space for the attribute counts
    glGenBuffers(1, &_buffer);
    
    return self;
}

- (void) dealloc
{
    glDeleteBuffers(1, &_buffer);
    free(_attributes);
}

- (id) withAttributeName:(const char*)name andElements:(int)elements
{
    [self checkError];
    
    _attributes = (struct vertexAttribute*)realloc(
                                                   _attributes,
                                                   sizeof(struct vertexAttribute) * (_attributeCount + 1)
    );
    
    _attributes[_attributeCount].elements = elements;
    _attributes[_attributeCount].offset   = _nextOffset;
    memcpy(_attributes[_attributeCount].name, name, strlen(name));
    
    ++_attributeCount;
    _nextOffset += elements * sizeof(GLfloat);
    
    [self checkError];
    
    return self;
}

- (void) updateData:(void *)data ofSize:(GLsizeiptr)size{
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, size, data, GL_DYNAMIC_DRAW);
    
    [self checkError];
    
    _vertices = (GLuint)size / _nextOffset;
    
    [self checkError];
}

- (void) bindWithShader:(Shader *)shader{
    int i = _attributeCount;
    
    [shader bind];
    lastShader = shader;
    
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    
    long offset = 0;
    for(int i = 0; i < _attributeCount; ++i){
        GLint loc = glGetAttribLocation(shader.programId, _attributes[i].name);
        glEnableVertexAttribArray(loc);
        glVertexAttribPointer(
                              loc,
                              _attributes[i].elements,
                              GL_FLOAT,
                              GL_FALSE,
                              _nextOffset,
                              (void*)offset
        );
        offset += sizeof(GLfloat) * _attributes[i].elements;
    }
    
}

- (void) drawAs:(GLenum)type{
    [self checkError];
    glDrawArrays(type, 0, _vertices);
    lastShader.drawn = YES;
    [self checkError];
}

@end
