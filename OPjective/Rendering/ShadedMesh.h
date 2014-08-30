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
@property (strong, nonatomic) Shader* shader;

- (void) withAttributeName:(const char*)name andElements:(int)elements;
- (void) buildWithVertexProg:(NSString*)vertex andFragmentProg:(NSString*)frag;
- (void) drawAs:(GLenum) drawType;

- (void) checkError;

@end
