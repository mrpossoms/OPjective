//
//  Sound.h
//  OPjective
//
//  Created by Kirk Roerig on 8/22/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>

#define SOUND_SAMPLES_PER_SEC 22050
#define SOUND_STREAM_BUFFER_SAMPLES 22050
//4096

@interface Sound : NSObject{
    @private
    ALuint buffers[3];
    ALshort streamBuffs[SOUND_STREAM_BUFFER_SAMPLES][3];
    ALuint availableBuffers;
}

- (id) initWithData:(void*)data ofLength:(ALsizei)length  asStereo:(BOOL)isStereo withSoundCount:(unsigned int)sounds;
- (instancetype)initWithFile:(const char*)path;

- (void) play;
- (void) stop;
- (void) pause;
- (void) setLocation:(ALfloat*)location;
- (void) setVolume:(float)volume;
- (void) setPitch: (float)pitch;
- (BOOL) queueBuffer:(ALshort*)pcm;
- (void) clearBuffers;

+ (void) updateWithTimeElapsed:(double)dt;
+ (void) setListenerLocation:(ALfloat*)location withForward:(ALfloat*)forward andUp:(ALfloat*)up;
+ (void) initialize;

@end
