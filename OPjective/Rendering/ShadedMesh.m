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
    
    return self;
}

- (void) withAttributeName:(const char*)name andElements:(int)elements
{
    [_mesh withAttributeName:name andElements:elements];
    [_attribs addObject:[NSString stringWithUTF8String:name]];
}

- (void) buildWithVertexProg:(NSString*)vertex andFragmentProg:(NSString*)frag
{
    _shader = [[Shader alloc] initShaderWithVertex:vertex withFragment:frag withAttributes:_attribs];
    [_shader bind];
}

- (void) drawAs:(GLenum)drawType
{
    [self checkError];
    [self.mesh bindWithShader:self.shader];
    [self checkError];
    [self.mesh drawAs:drawType];
}

@end
