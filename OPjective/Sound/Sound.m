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

@interface Sound()

@property (nonatomic) ALuint source;
@property (nonatomic) ALuint buffer;

@end

@implementation Sound

static ALCdevice*  ALC_DEV = nil;
static ALCcontext* ALC_CTX = nil;

- (ALCdevice*) device
{
    if(!ALC_DEV){
        ALC_DEV = alcOpenDevice(NULL);
        ALC_CTX = alcCreateContext(ALC_DEV, NULL);
        alcMakeContextCurrent(ALC_CTX);
    }
    
    return ALC_DEV;
}

- (id) initWithData:(ALshort*)data ofLength:(ALsizei)length asStereo:(BOOL)isStereo
{
    self = [super init];
    [self device];
    
    alGenSources(1, &_source);
    
    alGenBuffers(1, &_buffer);
    alBufferData(
                 _buffer,
                 isStereo ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16,
                 data,
                 length,
                 22100
    );
    
    alSourcef(_source, AL_PITCH, 1.0f);
    alSourcef(_source, AL_GAIN, 1.0f);
    alSourcei(_source, AL_BUFFER, _buffer);
    
    return self;
}

- (void) play
{
    alSourcePlay(_source);
}

- (void) stop{
    alSourceStop(_source);
}

- (void) pause{
    alSourcePause(_source);
}

- (void) setVolume:(float)volume
{
    alSourcef(_source, AL_GAIN, volume);
}

- (void) setPitch: (float)pitch
{
    alSourcef(_source, AL_PITCH, pitch);
}

@end
