//
//  Font.h
//  OPjective
//
//  Created by Kirk Roerig on 4/6/15.
//  Copyright (c) 2015 OPifex. All rights reserved.
//

#import "ShadedMesh.h"

enum FontJustification{
    FONT_LEFT,
    FONT_CENTER,
    FONT_RIGHT
};

struct Letter{
    char character;
    GLuint start, end;
    GLuint length;
    GLfloat advance;
};

struct GlyphVertex{
    vec2    position;
    GLfloat percent;
};

@interface Font : ShadedMesh

@property struct GlyphVertex* positions;
@property GLuint* indices;
@property GLsizei positionCount, indexCount;
@property struct Letter* letters;

- (instancetype)initWithFont:(NSString*)font;

@end
