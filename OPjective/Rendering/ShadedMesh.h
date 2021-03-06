//
//  ShadedMesh.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OPjective.h"

@interface ShadedMesh : NSObject

@property (strong, nonatomic) Mesh* mesh;
@property (strong, nonatomic) NSMutableArray* meshes;
@property (strong, nonatomic) NSMutableArray* shaders;

- (void)withExplicitStride:(unsigned int)stride;
- (void)withAttributeName:(const char*)name andElements:(int)elements;
- (void)withAttributeName:(const char*)name andElements:(int)elements ofDataType:(GLenum)type;
- (unsigned int) buildWithVertexProg:(NSString*)vertex andFragmentProg:(NSString*)frag;
- (void) drawAs:(GLenum)drawType withStart:(GLsizei)offset andLength:(GLsizei)len;
- (void) drawAs:(GLenum)drawType;

@end
