//
//  Font.h
//  OPjective
//
//  Created by Kirk Roerig on 4/6/15.
//  Copyright (c) 2015 OPifex. All rights reserved.
//

#import "ShadedMesh.h"

@interface Font : ShadedMesh

@property vec2* positions;
@property GLuint* indices;
@property GLsizei positionCount, indexCount;
@property struct Letter* letters;

- (instancetype)initWithFont:(NSString*)font;

@end
