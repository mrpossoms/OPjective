//
//  PostEffect.h
//  OPjective
//
//  Created by Kirk Roerig on 12/19/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "ShadedMesh.h"
#import "Shader.h"
#import "./../Protocols/Drawable.h"
#import "./../Protocols/Ranked.h"

@interface PostEffect : Shader <Drawable, Ranked>

- (instancetype)initWithShader:(NSString*)fragmentShader;
+ (void)setVertexShader:(NSString*)path;

@end
