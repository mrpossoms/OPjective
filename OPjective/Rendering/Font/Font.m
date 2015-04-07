//
//  Font.m
//  OPjective
//
//  Created by Kirk Roerig on 4/6/15.
//  Copyright (c) 2015 OPifex. All rights reserved.
//

#import "Font.h"
#import "ft2build.h"
#include "freetype/freetype.h"
#include "freetype/ftglyph.h"
#include "freetype/ftoutln.h"

#define SCALE_FACTOR 26.6

struct Glyph{
    vec2 tempPositions[500];
    GLuint tempIndices[1000];
    GLsizei positionCount, indexCount;
    FT_Vector lastPosition;
};

@interface Font()

@property struct Glyph glyph;

@end

@implementation Font

#pragma mark - Curve rendering

static void bezier_2nd_order(vec2 r, FT_Vector* points, float t)
{
    vec2 inter[3] = {};
    vec2 p[3] = {
        { points[0].x, points[0].y },
        { points[1].x, points[1].y },
        { points[2].x, points[2].y },
    };
    float omt = 1 - t;
    
    vec2_scale(inter[0], p[0], omt * omt);
    vec2_scale(inter[1], p[1], 2 * omt * t);
    vec2_scale(inter[2], p[2], t * t);
    
    vec2_add(r, inter[0], inter[1]);
    vec2_add(r, r, inter[2]);
    
    vec2_scale(r, r, 1.0 / SCALE_FACTOR);
}

static void bezier_3rd_order(vec2 r, FT_Vector* points, float t)
{
    vec2 inter[4] = {};
    vec2 p[4] = {
        { points[0].x, points[0].y },
        { points[1].x, points[1].y },
        { points[2].x, points[2].y },
        { points[3].x, points[3].y },
    };
    float omt = 1 - t;
    
    vec2_scale(inter[0], p[0], omt * omt * omt);
    vec2_scale(inter[1], p[1], 3 * omt * omt * t);
    vec2_scale(inter[2], p[2], 3 * omt * t * t);
    vec2_scale(inter[3], p[3], t * t * t);
    
    vec2_add(r, inter[0], inter[1]);
    vec2_add(r, r, inter[2]);
    vec2_add(r, r, inter[3]);
    
    vec2_scale(r, r, 1.0 / SCALE_FACTOR);
}

#pragma mark - Vector outline decompose callbacks

int moveTo(const FT_Vector* to, void* user)
{
    ((struct Glyph*)user)->lastPosition = *to;
    
    return 0;
}

int lineTo(const FT_Vector* to, void* user)
{
    struct Glyph* glyph = user;
    vec2 v1 = { glyph->lastPosition.x / SCALE_FACTOR, glyph->lastPosition.y / SCALE_FACTOR };
    vec2 v2 = { to->x / SCALE_FACTOR, to->y / SCALE_FACTOR};
    
    
    memcpy(&glyph->tempPositions[glyph->positionCount++], v1, sizeof(vec2));
    memcpy(&glyph->tempPositions[glyph->positionCount++], v2, sizeof(vec2));
    
    glyph->tempIndices[glyph->indexCount] = glyph->indexCount++;
    glyph->tempIndices[glyph->indexCount] = glyph->indexCount++;
    
    glyph->lastPosition = *to;
    
    return 0;
}

int secondOrder(const FT_Vector* control, const FT_Vector* to, void* user)
{
    struct Glyph* glyph = user;
    FT_Vector points[3] = {
        glyph->lastPosition,
        *control,
        *to
    };
    vec2 last = { glyph->lastPosition.x / SCALE_FACTOR, glyph->lastPosition.y / SCALE_FACTOR};
    
    for(int j = 0; j <= 10; ++j){
        float t = j / 10.0f;
        vec2 p = { 0, 0 };
        bezier_2nd_order(p, points, t);

        memcpy(glyph->tempPositions + glyph->positionCount, last, sizeof(vec2));
        glyph->tempIndices[glyph->indexCount++] = glyph->positionCount++;
        
        memcpy(glyph->tempPositions + glyph->positionCount, p, sizeof(vec2));
        glyph->tempIndices[glyph->indexCount++] = glyph->positionCount++;
        
        last[0] = p[0];
        last[1] = p[1];
    }

    glyph->lastPosition = *to;
    last[0] = to->x / SCALE_FACTOR;
    last[1] = to->y / SCALE_FACTOR;
    
    return 0;
}

int thirdOrder(const FT_Vector* control1, const FT_Vector* control2, const FT_Vector* to, void* user)
{
    struct Glyph* glyph = user;
    FT_Vector points[4] = {
        glyph->lastPosition,
        *control1,
        *control2,
        *to
    };
    vec2 last = { glyph->lastPosition.x, glyph->lastPosition.y };
    
    for(int j = 1; j < 20; ++j){
        float t = j / 20.0f;
        vec2 p;
        bezier_3rd_order(p, points, t);

        memcpy(&glyph->tempPositions[glyph->positionCount++], p, sizeof(vec2));
        glyph->tempIndices[glyph->indexCount] = glyph->indexCount++;
        
        memcpy(last, p, sizeof(vec2));
    }
    
    glyph->lastPosition = *to;
    
    return 0;
}

#pragma mark - Font loading

void
extractOutlines(
     const char *path,
     struct Letter *_letters,
     GLsizei *_indexCount_p,
     GLuint **_indices_p,
     GLsizei *_positionCount_p,
     vec2 **_positions_p)
{
    const FT_Outline_Funcs outlineFuncs = {
        .move_to = moveTo,
        .line_to = lineTo,
        .conic_to = secondOrder,
        .cubic_to = thirdOrder,
        .shift = 0
    };
    
    FT_Library library;
    FT_Face    face;
    
    FT_Init_FreeType(&library);
    FT_New_Face(library, path, 0, &face);
    
    int size = 1;
    FT_Set_Char_Size(face, size << 6, size << 6, 90, 90);
    
    
    for(unsigned char c = 0; c < 0x7F; ++c){
        struct Glyph currentGlyph = {};
        FT_Load_Char(face, c, FT_LOAD_NO_BITMAP);
        
        if(face->glyph->format == FT_GLYPH_FORMAT_OUTLINE){
            FT_Glyph glyph;
            FT_Get_Glyph(face->glyph, &glyph);
            
            FT_OutlineGlyph outlineGlyph = (FT_OutlineGlyph)glyph;
            FT_Outline outline = outlineGlyph->outline;
            
            FT_Outline_Decompose(&outline, &outlineFuncs, &currentGlyph);
            
            *_positions_p = realloc(*_positions_p, (*_positionCount_p + currentGlyph.positionCount) * sizeof(vec2));
            memcpy(*_positions_p + *_positionCount_p, currentGlyph.tempPositions, sizeof(vec2) * currentGlyph.positionCount);
            *_positionCount_p += currentGlyph.positionCount;
            
            _letters[c].character = c;
            _letters[c].start = *_indexCount_p;
            _letters[c].advance = face->glyph->metrics.horiAdvance / SCALE_FACTOR;
            
            *_indices_p = realloc(*_indices_p, (*_indexCount_p + currentGlyph.indexCount) * sizeof(GLuint));
            memcpy(*_indices_p + *_indexCount_p, currentGlyph.tempIndices, currentGlyph.indexCount * sizeof(GLuint));
            *_indexCount_p += currentGlyph.indexCount;
            
            _letters[c].end = *_indexCount_p;
            _letters[c].length = _letters[c].end - _letters[c].start;
            
            FT_Done_Glyph(glyph);
        }
    }
    
    FT_Done_Face(face);
    FT_Done_FreeType(library);
}

#pragma mark - Init / dealloc

- (instancetype)initWithFont:(NSString*)font
{
    self = [super init];
    if(!self) return self;
  
    _letters = malloc(sizeof(struct Letter) * 0x80);
    
    const char* path = [[[NSBundle mainBundle] pathForResource:font ofType:@"ttf"] UTF8String];
    extractOutlines(path, _letters, &_indexCount, &_indices, &_positionCount, &_positions);
    
    return self;
}

- (void)dealloc
{
    free(_letters);
    free(_positions);
    free(_indices);
}


@end
