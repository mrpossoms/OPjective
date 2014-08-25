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


struct AudioSources{
    ALuint sources[16];
    int currentSource;
    int count;
};

@interface Sound()

@property (nonatomic) struct AudioSources sources;
@property (nonatomic) ALuint buffer;

@end

@implementation Sound

static ALCdevice*  ALC_DEV = nil;
static ALCcontext* ALC_CTX = nil;

- (ALCdevice*) device
{
    if(!ALC_DEV){
        // setup audio session
        NSError *error = nil;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        NSAssert(error == nil, @"Failed to set audio session category.");
        
        // Make sure the sounds don't play out the headphone jack
        OSStatus propertySetError = 0;
        UInt32 doChangeDefaultRoute = true;
        propertySetError = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
        NSAssert(propertySetError == 0, @"Failed to set audio session property: OverrideCategoryDefaultToSpeaker");
        

        
        ALC_DEV = alcOpenDevice(NULL);
        ALC_CTX = alcCreateContext(ALC_DEV, NULL);
        alcMakeContextCurrent(ALC_CTX);
    }
    
    return ALC_DEV;
}

- (id) initWithData:(ALshort*)data ofLength:(ALsizei)length asStereo:(BOOL)isStereo withSoundCount:(int)sounds
{
    self = [super init];
    [self device];
    
    bzero(&_sources, sizeof(struct AudioSources));
    _sources.count = sounds;
    
    alGenSources(sounds, _sources.sources);
    
    alGenBuffers(1, &_buffer);
    alBufferData(
                 _buffer,
                 isStereo ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16,
                 data,
                 length,
                 22100
    );
    
    for(;sounds--;){
        alSourcef(_sources.sources[sounds], AL_PITCH, 1.0f);
        alSourcef(_sources.sources[sounds], AL_GAIN, 1.0f);
        alSourcei(_sources.sources[sounds], AL_BUFFER, _buffer);
    }
    
    return self;
}

- (void) play
{
    int i = _sources.currentSource;
    alSourcePlay(_sources.sources[i]);
    _sources.currentSource = (++_sources.currentSource % _sources.count);
}

- (void) stop{
    int i = _sources.currentSource;
    alSourceStop(_sources.sources[i]);
}

- (void) pause{
    int i = _sources.currentSource;
    alSourcePause(_sources.sources[i]);
}

- (void) setVolume:(float)volume
{
    int i = _sources.currentSource;
    alSourcef(_sources.sources[i], AL_GAIN, volume);
}

- (void) setPitch: (float)pitch
{
    int i = _sources.currentSource;
    alSourcef(_sources.sources[i], AL_PITCH, pitch);
}

@end
