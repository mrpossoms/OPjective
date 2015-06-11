//
//  Sound.m
//  OPjective
//
//  Created by Kirk Roerig on 8/22/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Sound.h"
#import <OpenAL/alc.h>
#include <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>
#include "fmod.h"

#define NUM_COLUMNS 50
#define NUM_ROWS 25

struct AudioSources{
    ALuint sources[16];
    int currentSource;
    int count;
};

@interface Sound()

@property FMOD_SOUND*   sound;
@property FMOD_CHANNEL* channel;

@end

@implementation Sound

NSMutableString *gOutputBuffer;
bool gSuspendState;

FMOD_SYSTEM* FMOD_SYS;

static ALCdevice*  ALC_DEV = nil;
static ALCcontext* ALC_CTX = nil;

void interruptionListenerCallback(void *inUserData, UInt32 interruptionState)
{
    if (interruptionState == kAudioSessionBeginInterruption)
    {
        gSuspendState = true;
    }
    else if (interruptionState == kAudioSessionEndInterruption)
    {
        UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
        AudioSessionSetActive(true);
        
        gSuspendState = false;
    }
}

+ (void)initialize
{
    void* extradriverdata;
    
    gSuspendState = false;
    gOutputBuffer = [NSMutableString stringWithCapacity:(NUM_COLUMNS * NUM_ROWS)];
    
    AudioSessionInitialize(NULL, NULL, interruptionListenerCallback, NULL);
    
    // Default to 'play and record' so we have recording available for examples that use it
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    AudioSessionSetActive(true);
    
    FMOD_System_Create(&FMOD_SYS);
    FMOD_System_Init(FMOD_SYS, 32, FMOD_INIT_NORMAL, extradriverdata);
}

- (instancetype)init
{
    self = [super init];
    
    return self;
}

- (instancetype)initWithFile:(const char*)path
{
    self = [super init];
    
    const char* fullPath = [[NSString stringWithFormat:@"%@/media/%s", [[NSBundle mainBundle] resourcePath], path] UTF8String];
    FMOD_System_CreateSound(FMOD_SYS, fullPath, FMOD_DEFAULT, 0, &_sound);
    
    return self;
}

- (id) initWithData:(void*)data ofLength:(ALsizei)length asStereo:(BOOL)isStereo withSoundCount:(unsigned int)sounds
{
    self = [super init];
    
    FMOD_CREATESOUNDEXINFO info = {
        .cbsize = sizeof(FMOD_CREATESOUNDEXINFO),
        .length = length,
        .numchannels = 1,
        .defaultfrequency = SOUND_STREAM_BUFFER_SAMPLES,
        .format = FMOD_SOUND_FORMAT_PCM16
    };
    
    if(FMOD_System_CreateSound(FMOD_SYS, data, FMOD_OPENRAW | FMOD_OPENMEMORY_POINT, &info, &_sound) != FMOD_OK){
        return nil;
    }
    
    
    return self;
}

- (void) clearBuffers
{

}

- (BOOL) queueBuffer:(ALshort *)pcm
{
    return YES;
}

- (void) play
{
    FMOD_System_PlaySound(FMOD_SYS, _sound, NULL, false, &_channel);
}

- (void) stop{
}

- (void) pause{
}

+ (void) updateWithTimeElapsed:(double)dt
{
    FMOD_System_Update(FMOD_SYS);
}

+ (void) setListenerLocation:(ALfloat*)location withForward:(ALfloat*)forward andUp:(ALfloat*)up
{
    ALfloat forwardUp[] = {
        forward[0], forward[1], forward[2],
        up[0], up[1], up[2]
    };
    
    alListenerfv(AL_POSITION, location);
    alListenerfv(AL_ORIENTATION, forwardUp);
}

- (void) setLocation:(ALfloat*)location
{
    FMOD_VECTOR pos = { location[0], location[1], location[2] };
    FMOD_VECTOR zero = {};
    FMOD_Channel_Set3DAttributes(_channel, &pos, &zero, NULL);
}

- (void) setVolume:(float)volume
{
    FMOD_Channel_SetVolume(_channel, volume);
}

- (void) setPitch: (float)pitch
{
    FMOD_Channel_SetPitch(_channel, pitch);
}

@end
