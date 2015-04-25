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
@property (nonatomic) BOOL usingIndexBuffer, boundOnce;
@property (nonatomic) unsigned int explicitStride;

@end

@implementation Mesh

static Shader* lastShader = nil;

- (id) init
{
    if(!self){
        self = [super init];
    }
    
    _attributeCount = 0;
    _nextOffset = 0;
    _usingIndexBuffer = NO;
    _boundOnce = NO;
    
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
    return [self withAttributeName:name andElements:elements ofDataType:GL_FLOAT];
}

- (id) withAttributeName:(const char*)name andElements:(int)elements ofDataType:(GLenum)type
{
    GL_CHECK_ERR
    
    _attributes = (struct vertexAttribute*)realloc(
                                                   _attributes,
                                                   sizeof(struct vertexAttribute) * (_attributeCount + 1)
                                                   );
    
    _attributes[_attributeCount].elements = elements;
    _attributes[_attributeCount].offset   = _nextOffset;
    _attributes[_attributeCount].dataType = type;
    memcpy(_attributes[_attributeCount].name, name, strlen(name) + 1);
    
    switch (type) {
        case GL_UNSIGNED_BYTE:
            _nextOffset += elements * sizeof(GLubyte);
            _attributes[_attributeCount].elementSize = sizeof(GLubyte);
            break;
        case GL_FLOAT:
        default:
            _nextOffset += elements * sizeof(GLfloat);
            _attributes[_attributeCount].elementSize = sizeof(GLfloat);
            break;
    }
    
    GL_CHECK_ERR
    ++_attributeCount;
    
    return self;
}

- (unsigned int)stride
{
    return _explicitStride ? _explicitStride : _nextOffset;
}

- (void)withExplicitStride:(unsigned int)stride
{
    _explicitStride = stride;
}

- (void) updateData:(void *)data ofSize:(GLsizeiptr)size{
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, size, data, GL_DYNAMIC_DRAW);
    
    GL_CHECK_ERR
    
    _vertices = (GLuint)size / [self stride];
    
    GL_CHECK_ERR
}

- (void) updateData:(void*)data ofSize:(GLsizeiptr)dsize andIndicies:(GLuint*)indices ofSize:(GLsizeiptr)isize
{
    if(!_usingIndexBuffer){
        glGenBuffers(1, &_indexBuffer);
        _usingIndexBuffer = YES;
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, dsize, data, GL_DYNAMIC_DRAW);
    
    GL_CHECK_ERR

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, isize, indices, GL_DYNAMIC_DRAW);
    
    GL_CHECK_ERR
    
    _vertices = (GLuint)isize / sizeof(GLuint);
    
    GL_CHECK_ERR
}

- (void) bindWithShader:(Shader *)shader{
    [shader bind];
    lastShader = shader;
    
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    
    if(_usingIndexBuffer){
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    }
    
    GL_CHECK_ERR
    
    long offset = 0;
    unsigned int stride = [self stride];
    for(int i = 0; i < _attributeCount; ++i){
        GLint loc = glGetAttribLocation(shader.programId, _attributes[i].name);
        
        GL_CHECK_ERR
        
#ifdef DEBUG
        if(loc < 0){
            NSString* msg = [NSString stringWithFormat:@"Attribute '%s' couldn't be found for current shader", _attributes[i].name];
            NSAssert(NO, msg);
        }
#endif
            
        assert(loc <= GL_MAX_VERTEX_ATTRIBS);
        
        if(!_boundOnce){
            glEnableVertexAttribArray(loc);
        }
        
        GL_CHECK_ERR
        glVertexAttribPointer(
                              loc,
                              _attributes[i].elements,
                              _attributes[i].dataType,
                              GL_FALSE,
                              stride,
                              (void*)offset
        );
        offset += _attributes[i].elementSize * _attributes[i].elements;
        GL_CHECK_ERR
    }
    
    if(!_boundOnce) _boundOnce = YES;
    
}

- (void) drawAs:(GLenum)type{
    if(!_vertices) return;
    
    GL_CHECK_ERR
    
    if(_usingIndexBuffer){
        glDrawElements(type, _vertices, GL_UNSIGNED_INT, (void*)0);
    }
    else{
        glDrawArrays(type, 0, _vertices);
    }
    lastShader.drawn = YES;
    GL_CHECK_ERR
}

@end
