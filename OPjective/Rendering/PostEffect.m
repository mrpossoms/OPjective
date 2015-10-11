//
//  PostEffect.m
//  OPjective
//
//  Created by Kirk Roerig on 12/19/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "PostEffect.h"

@interface PostEffect()

@property (nonatomic) GLuint vbo;

@end

@implementation PostEffect : Shader

struct PostVertex{
    vec3 position;
    vec2 uv;
};

static NSString* POST_VERTEX_SHADER;
static struct PostVertex QUAD_VERTS[] = {
    {
        .position = { -1.0f, 1.0f, 0.0f },
        .uv = { 0.0f, 1.0f },
    },
    {
        .position = { 1.0f, 1.0f, 0.0f },
        .uv = { 1.0f, 1.0f },
    },
    {
        .position = { 1.0f, -1.0f, 0.0f },
        .uv = { 1.0f, 0.0f },
    },
    {
        .position = { -1.0f, -1.0f, 0.0f },
        .uv = { 0.0f, 0.0f },
    },
};

- (instancetype)initWithShader:(NSString*)fragmentShader
{
    self = [super initShaderWithVertex:POST_VERTEX_SHADER
                          withFragment:fragmentShader
                        withAttributes:@[@"aPosition", @"aUV"]
            ];
    
    if(!self) return nil;
    
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(QUAD_VERTS), QUAD_VERTS, GL_STATIC_DRAW);
    
    return self;
}

- (void)dealloc
{
    glDeleteBuffers(1, &_vbo);
}

- (int)updateRank
{
    return 0;
}

- (int)drawRank
{
    return 0;
}

- (void)batchDrawStartWithViewProjection:(const GLKMatrix4 *)vp
{}

- (void)batchDraw
{}

- (void)batchFinish
{}

- (void)drawWithViewProjection:(const GLKMatrix4 *)viewProjection
{
    GLcheckError();
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    
    GLuint posLoc = glGetAttribLocation(self.programId, "aPosition");
    GLuint uvLoc  = glGetAttribLocation(self.programId, "aUV");
    
    glEnableVertexAttribArray(posLoc);
    glEnableVertexAttribArray(uvLoc);
    
    glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, sizeof(struct PostVertex), (void*)0);
    glVertexAttribPointer(uvLoc,  2, GL_FLOAT, GL_FALSE, sizeof(struct PostVertex), (void*)sizeof(vec3));
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    GLcheckError();
}

+ (void)setVertexShader:(NSString *)path
{
    POST_VERTEX_SHADER = path;
}

@end