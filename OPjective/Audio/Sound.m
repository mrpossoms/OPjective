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

#define NUM_COLUMNS 50
#define NUM_ROWS 25

const float DISTANCEFACTOR = 50.0f;          // Units per meter.  I.e feet would = 3.28.  centimeters would = 100.

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
    FMOD_System_Init(FMOD_SYS, 100, FMOD_INIT_NORMAL, extradriverdata);

    assert(FMOD_System_Set3DSettings(FMOD_SYS, 1.0, DISTANCEFACTOR, 1.0) == FMOD_OK);
}

- (instancetype)init
{
    self = [super init];
    
    return self;
}

- (instancetype)initWithFile:(const char*)path fmodFlags:(FMOD_MODE)flags
{
    self = [super init];
    
    const char* fullPath = [[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s", path] ofType:@"wav" inDirectory:@""] UTF8String];
    
    if(!fullPath){
        fullPath = [[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s", path] ofType:@"mp3" inDirectory:@""] UTF8String];
    }
    
    FMOD_System_CreateSound(FMOD_SYS, fullPath, FMOD_DEFAULT | flags, 0, &_sound);
    if(flags & FMOD_3D){
        FMOD_Sound_Set3DMinMaxDistance(_sound, 0.5f * DISTANCEFACTOR, 5000.0f * DISTANCEFACTOR);
    }
    
    volume = pitch = 1;

    return self;
}

- (id) initWithData:(void*)data ofLength:(ALsizei)length asStereo:(BOOL)isStereo fmodFlags:(FMOD_MODE)flags
{
    self = [super init];
    
    FMOD_CREATESOUNDEXINFO info = {
        .cbsize = sizeof(FMOD_CREATESOUNDEXINFO),
        .length = length,
        .numchannels = 1,
        .defaultfrequency = SOUND_STREAM_BUFFER_SAMPLES,
        .decodebuffersize = SOUND_STREAM_BUFFER_SAMPLES,
        .format = FMOD_SOUND_FORMAT_PCM16
    };
    
    if(FMOD_System_CreateSound(
       FMOD_SYS,
       data,
       FMOD_OPENRAW | FMOD_OPENMEMORY_POINT | flags,
       &info,
       &_sound) != FMOD_OK)
    {
        return nil;
    }
    
    if(flags & FMOD_3D){
        FMOD_Sound_Set3DMinMaxDistance(_sound, 0.5f * DISTANCEFACTOR, 5000.0f * DISTANCEFACTOR);
    }
    
    volume = pitch = 1;
    
    return self;
}

- (void) clearBuffers
{

}

- (BOOL) queueBuffer:(ALshort *)pcm
{
    return YES;
}

- (void)playPaused
{
    FMOD_System_PlaySound(FMOD_SYS, _sound, NULL, true, &_channel);
    FMOD_Channel_SetVolume(_channel, volume);
    FMOD_Channel_SetPitch(_channel, pitch);
}

- (void) play
{
    [self playPaused];
    FMOD_Channel_SetPaused(_channel, false);
}

- (void) playAtLocation:(ALfloat*)location
{
    [self playPaused];
    
    FMOD_VECTOR pos = { location[0], location[1], location[2] };
    FMOD_VECTOR zero = {};
    FMOD_Channel_Set3DAttributes(_channel, &pos, &zero, NULL);
    FMOD_Channel_SetPaused(_channel, false);
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
    FMOD_VECTOR pos = { location[0], location[1], location[2] };
    FMOD_VECTOR f   = {-forward[0], -forward[1], -forward[2] };
    FMOD_VECTOR u   = { up[0], up[1], up[2] };
    FMOD_VECTOR vel = {};
    
    assert(FMOD_System_Set3DListenerAttributes(FMOD_SYS, 0, &pos, &vel, &f, &u) == FMOD_OK);
}

- (void) setLocation:(ALfloat*)location
{
    FMOD_VECTOR pos = { location[0], location[1], location[2] };
    FMOD_VECTOR zero = {};
    FMOD_Channel_Set3DAttributes(_channel, &pos, &zero, NULL);
    FMOD_Channel_SetPaused(_channel, false);
}

@end
