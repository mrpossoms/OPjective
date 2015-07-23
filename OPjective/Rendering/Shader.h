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

enum ShaderVectorType{
    vec2Type,
    vec3Type,
    vec4Type,
};

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

- (void) usingTexture:(const Texture *)texture withName:(const char*)name;
- (void) usingFloat:(const GLfloat*)f ofLength:(int)length withName:(const char*)name;
- (void) usingInt:(const GLint*)i ofLength:(int)length withName:(const char*)name;
- (void) usingArray:(const GLvoid*)array ofLength:(int)length andType:(enum ShaderArrayType)type withName:(const char*)name;
- (void) usingMat4x4:(const GLKMatrix4*)matrix withName:(const char*)name;

+ (GLchar*)sourceFromFile:(NSString*)path;

@end

