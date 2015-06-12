//
//  Sound.h
//  OPjective
//
//  Created by Kirk Roerig on 8/22/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#include "fmod.h"

#define SOUND_SAMPLES_PER_SEC 22050
#define SOUND_STREAM_BUFFER_SAMPLES 22050
//4096

@interface Sound : NSObject{
    @public
    float volume, pitch;
}

- (id) initWithData:(void*)data ofLength:(ALsizei)length asStereo:(BOOL)isStereo fmodFlags:(FMOD_MODE)flags;
- (instancetype)initWithFile:(const char*)path fmodFlags:(FMOD_MODE)flags;

- (void) play;
- (void) playAtLocation:(ALfloat*)location;
- (void) stop;
- (void) pause;
- (void) setLocation:(ALfloat*)location;
- (void) setLooping;
- (BOOL) queueBuffer:(ALshort*)pcm;
- (void) clearBuffers;

+ (void) updateWithTimeElapsed:(double)dt;
+ (void) setListenerLocation:(ALfloat*)location withForward:(ALfloat*)forward andUp:(ALfloat*)up;
+ (void) initialize;

@end
