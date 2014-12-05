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
@property (nonatomic) GLuint indexBuffer;
@property (nonatomic) struct vertexAttribute* attributes;
@property (nonatomic) GLuint attributeCount;
@property (nonatomic) GLuint nextOffset;
@property (nonatomic) GLuint vertices;
@property (nonatomic) BOOL usingIndexBuffer;

@end

@implementation Mesh

static Shader* lastShader = nil;

-(void)checkError{
    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"Error: %x", err);
    assert(err == GL_NO_ERROR);
}

- (id) init
{
    if(!self){
        self = [super init];
    }
    
    _attributeCount = 0;
    _nextOffset = 0;
    _usingIndexBuffer = NO;
    
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
    memcpy(_attributes[_attributeCount].name, name, strlen(name) + 1);
    
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

- (void) updateData:(void*)data ofSize:(GLsizeiptr)dsize andIndicies:(GLuint*)indices ofSize:(GLsizeiptr)isize
{
    if(!_usingIndexBuffer){
        glGenBuffers(1, &_indexBuffer);
        _usingIndexBuffer = YES;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, dsize, data, GL_DYNAMIC_DRAW);
    
    [self checkError];

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, isize, indices, GL_DYNAMIC_DRAW);
    
    [self checkError];
    
    _vertices = (GLuint)isize / sizeof(GLuint);
    
    [self checkError];
}

- (void) bindWithShader:(Shader *)shader{
    [shader bind];
    lastShader = shader;
    
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    
    if(_usingIndexBuffer){
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    }
    
    [self checkError];
    
    long offset = 0;
    for(int i = 0; i < _attributeCount; ++i){
        GLint loc = glGetAttribLocation(shader.programId, _attributes[i].name);
        [self checkError];
        
        if(loc < 0){
            NSString* msg = [NSString stringWithFormat:@"Attribute '%s' couldn't be found for current shader", _attributes[i].name];
            NSAssert(NO, msg);
        }
            
        assert(loc <= GL_MAX_VERTEX_ATTRIBS);
        
        glEnableVertexAttribArray(loc);
        [self checkError];
        glVertexAttribPointer(
                              loc,
                              _attributes[i].elements,
                              GL_FLOAT,
                              GL_FALSE,
                              _nextOffset,
                              (void*)offset
        );
        offset += sizeof(GLfloat) * _attributes[i].elements;
        [self checkError];
    }
    
}

- (void) drawAs:(GLenum)type{
    [self checkError];
    
    if(_usingIndexBuffer){
        glDrawElements(type, _vertices, GL_UNSIGNED_INT, (void*)0);
    }
    else{
        glDrawArrays(type, 0, _vertices);
    }
    lastShader.drawn = YES;
    [self checkError];
}

@end
