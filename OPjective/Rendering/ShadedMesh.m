//
//  ShadedMesh.m
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "ShadedMesh.h"

@interface ShadedMesh()

@property (strong, nonatomic) NSMutableArray* attribs;

@end

@implementation ShadedMesh

-(void)checkError{
    GLenum err = glGetError();
    if(err != GL_NO_ERROR)
        NSLog(@"Error: %x", err);
    assert(err == GL_NO_ERROR);
}

- (id) init
{
    self = [super init];
    
    _mesh = [[Mesh alloc] init];
    _attribs = [[NSMutableArray alloc] init];
    _shaders = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)withExplicitStride:(unsigned int)stride
{
    [_mesh withExplicitStride:stride];
}

- (void) withAttributeName:(const char*)name andElements:(int)elements
{
    [_mesh withAttributeName:name andElements:elements];
    [_attribs addObject:[NSString stringWithUTF8String:name]];
}

- (unsigned int) buildWithVertexProg:(NSString*)vertex andFragmentProg:(NSString*)frag
{
    Shader* shader = [[Shader alloc] initShaderWithVertex:vertex withFragment:frag withAttributes:_attribs];
    
    if(!shader) return 1;
    
    [self.shaders addObject:shader];
    [shader bind];
    
    return 0;
}

- (void) drawAs:(GLenum)drawType
{
    [self checkError];
    [self.mesh bindWithShader:[self.shaders firstObject]];
    [self checkError];
    [self.mesh drawAs:drawType];
}

@end
