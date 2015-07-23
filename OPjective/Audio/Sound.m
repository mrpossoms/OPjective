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
#define MASTER_VOLUME 3

const float DISTANCEFACTOR = 1.5f;          // Units per meter.  I.e feet would = 3.28.  centimeters would = 100.

struct AudioSources{
    ALuint sources[16];
    int currentSource;
    int count;
};

@interface Sound()

@property FMOD_SOUND*   sound;
@property FMOD_CHANNEL* channel;
@property FMOD_DSP* dsp;
@property FMOD_CHANNELGROUP* group;
@property char* groupName;

@end

@implementation Sound

NSMutableString *gOutputBuffer;
bool gSuspendState;

FMOD_SYSTEM* FMOD_SYS;

+ (void)initialize
{
    gSuspendState = false;
    gOutputBuffer = [NSMutableString stringWithCapacity:(NUM_COLUMNS * NUM_ROWS)];
    
    AVAudioSession* session = [AVAudioSession sharedInstance];
    NSError* err;
    [session setCategory:AVAudioSessionCategoryAmbient error:&err];
    
    void* extradriverdata;
    
    FMOD_System_Create(&FMOD_SYS);
    FMOD_System_Init(FMOD_SYS, 100, FMOD_INIT_NORMAL, extradriverdata);

    
    FMOD_OUTPUTTYPE output;
    FMOD_System_GetOutput(FMOD_SYS, &output);
    
    
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
        FMOD_Sound_Set3DMinMaxDistance(_sound, 10.0f * DISTANCEFACTOR, 5000.0f * DISTANCEFACTOR);
    }
    
    volume = pitch = 1;

    return self;
}

static FMOD_RESULT F_CALLBACK SILENT_REF(FMOD_SOUND* sound, void* data, unsigned int length)
{
    short* pcm = data;
    
    for(int i = (length >> 1); i--; pcm[i] = SHRT_MAX); // set each sample to 1
    
    return FMOD_OK;
}

- (instancetype)initWithPcmCallback:(FMOD_DSP_READ_CALLBACK)pcmCallback
                andHouseKeepingData:(void *)userData
                          fmodFlags:(FMOD_MODE)flags
{
    self = [super init];
    
    FMOD_CREATESOUNDEXINFO info = {
        .cbsize = sizeof(FMOD_CREATESOUNDEXINFO),
        .length = SOUND_SAMPLES_PER_SEC * sizeof(ALshort) * 2,
        .numchannels = 1,
        .defaultfrequency = SOUND_SAMPLES_PER_SEC,
        .decodebuffersize = SOUND_SAMPLES_PER_SEC,
        .format = FMOD_SOUND_FORMAT_PCM16,
        .pcmreadcallback = SILENT_REF,
        .pcmsetposcallback = NULL,
    };
    
    if(FMOD_System_CreateSound(
                               FMOD_SYS,
                               NULL,
                               FMOD_OPENUSER | flags,
                               &info,
                               &_sound) != FMOD_OK)
    {
        return nil;
    }
    
    time_t now = time(NULL);
    _groupName = malloc(10);
    
    sprintf(_groupName, "%ld", now);
    
    if(flags & FMOD_3D){
        FMOD_Sound_Set3DMinMaxDistance(_sound, 10.0f * DISTANCEFACTOR, 5000.0f * DISTANCEFACTOR);
    }
    
    if(FMOD_System_CreateChannelGroup(FMOD_SYS, _groupName, &_group)){
        return nil;
    }
    
    
    FMOD_DSP_DESCRIPTION desc = {
        .version = 0x00010000,
        .numinputbuffers = 1,
        .numoutputbuffers = 1,
        .read = pcmCallback,
        .userdata = userData,
    };
    
    if(FMOD_System_CreateDSP(FMOD_SYS, &desc, &_dsp)){
        FMOD_Sound_Release(_sound);
        FMOD_ChannelGroup_Release(_group);
        return nil;
    }
    
    if(FMOD_ChannelGroup_AddDSP(_group, 0, _dsp)){
        FMOD_Sound_Release(_sound);
        FMOD_DSP_Release(_dsp);
        FMOD_ChannelGroup_Release(_group);
        return nil;
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
        .defaultfrequency = SOUND_SAMPLES_PER_SEC,
        .decodebuffersize = SOUND_SAMPLES_PER_SEC,
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
        FMOD_Sound_Set3DMinMaxDistance(_sound, 10.0f * DISTANCEFACTOR, 5000.0f * DISTANCEFACTOR);
    }
    
    volume = pitch = 1;
    
    return self;
}

- (void)dealloc
{
    free(_groupName);
    
    FMOD_Sound_Release(_sound);
    if(_group) FMOD_ChannelGroup_Release(_group);
    if(_dsp) FMOD_DSP_Release(_dsp);
}

- (BOOL) queueBuffer:(ALshort *)pcm
{
    return YES;
}

- (void)playPaused
{
    FMOD_System_PlaySound(FMOD_SYS, _sound, NULL, true, &_channel);
    FMOD_Channel_SetVolume(_channel, volume * MASTER_VOLUME);
    FMOD_Channel_SetPitch(_channel, pitch);

    if(_group) FMOD_Channel_SetChannelGroup(_channel, _group);
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
    FMOD_Channel_Stop(_channel);
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

- (void) setVolume:(ALfloat)vol
{
    FMOD_Channel_SetVolume(_channel, volume = vol);
}

@end
