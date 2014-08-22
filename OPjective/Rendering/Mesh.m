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
@property (nonatomic) GLint* attributeSizes;
@property (nonatomic) GLuint attributeCount;
@property (nonatomic) GLuint nextOffset;
@property (nonatomic) GLuint vertices;

@end

@implementation Mesh

static Shader* lastShader = nil;

-(void)checkError{
    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"Error: %dx", err);
    assert(err == GL_NO_ERROR);
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

- (id) initWithVertexDescription: (struct vertexAttribute*)description withAttributeCount:(int)count
             usingData:(void*)data
            withLength:(GLsizeiptr)len
{
    self = [super init];
    
    // generate buffers allocate space for the attribute counts
    glGenBuffers(1, &_buffer);
    _attributeSizes = malloc(sizeof(GLint) * (_attributeCount = count));
    
    // copy data to the buffer
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, len, data, GL_DYNAMIC_DRAW);
    
    // enable and bind the vertex attributes
    // keep attribute counts
    for(int i = 0; i < count; i++){
        glEnableVertexAttribArray(i);
        glVertexAttribPointer(
            i,
            description[i].elements,
            GL_FLOAT,
            GL_FALSE,
            description[i].offset,
            NULL
        );
        _attributeSizes[i] = description[i].elements;
    }
    
    return self;
}

- (id) withAttributeName:(const char*)name andElements:(int)elements
{
    _attributeSizes = (GLint*)realloc(_attributeSizes, sizeof(GLint) * (_attributeCount + 1));
    _attributeSizes[_attributeCount] = elements;
    ++_attributeCount;
 
    _nextOffset += elements * sizeof(GLfloat);
    
    [self checkError];
    
    return self;
}

- (void) updateData:(void *)data ofSize:(GLsizeiptr)size{
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, size, data, GL_DYNAMIC_DRAW);
    
    int offset = 0;
    for(int i = 0; i < _attributeCount; ++i){
        glEnableVertexAttribArray(i);
        glVertexAttribPointer(
                              i,
                              _attributeSizes[i],
                              GL_FLOAT,
                              GL_FALSE,
                              _nextOffset,
                              (const void*)offset
                              );
        offset += sizeof(GLfloat) * _attributeSizes[i];;
    }
    
    _vertices = size / _nextOffset;
}

- (void) bindWithShader:(Shader *)shader{
    int i = _attributeCount;
    
    [shader bind];
    lastShader = shader;
    
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    for(;i--;){
        glEnableVertexAttribArray(i);
    }
}

- (void) drawAs:(GLenum)type{
    glDrawArrays(type, 0, _vertices);
    lastShader.drawn = YES;
}

@end
