//
//  Shader.h
//  OPjective
//
//  Created by Kirk Roerig on 8/20/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Texture.h"

enum ShaderArrayType{
    floatArray,
    vec2Array,
    vec3Array,
    vec4Array,
    mat3Array,
};

@interface Shader : NSObject

@property GLint programId;
@property BOOL  drawn;

- (id) initShaderWithVertex:(NSString*) vertex
               withFragment:(NSString*) fragment
             withAttributes:(NSArray*) attributes;
- (BOOL) bind;

- (void) usingTexture:(Texture *)texture withName:(const char*)name;
- (void) usingFloat:(GLfloat*)vector ofLength:(int)length withName:(const char*)name;
- (void) usingArray:(GLvoid*)array ofLength:(int)length andType:(enum ShaderArrayType)type withName:(const char*)name;
- (void) usingMat4x4:(GLKMatrix4*)matrix withName:(const char*)name;


@end

