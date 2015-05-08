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

@end

@implementation Sound

static ALCdevice*  ALC_DEV = nil;
static ALCcontext* ALC_CTX = nil;

- (ALCdevice*) device
{
//    return nil;
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

- (instancetype)init
{
    self = [super init];
    [self device];

    bzero(&_sources, sizeof(struct AudioSources));
    _sources.count = 1;
    
    alGenSources(_sources.count, _sources.sources);
    alGenBuffers(3, buffers);
    
    availableBuffers = 3;
    
    return self;
}

- (id) initWithData:(ALshort*)data ofLength:(ALsizei)length asStereo:(BOOL)isStereo withSoundCount:(unsigned int)sounds
{
    self = [super init];
    [self device];
    
    bzero(&_sources, sizeof(struct AudioSources));
    _sources.count = sounds > 16 ? 16 : sounds;
    
    alGenSources(_sources.count, _sources.sources);
    
    alGenBuffers(1, buffers);
    alBufferData(
                 buffers[0],
                 isStereo ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16,
                 data,
                 length,
                 SOUND_SAMPLES_PER_SEC
    );
    
//    streamBuffs[0] = streamBuffs[1] = NULL;
    
    for(;sounds--;){
        alSourcef(_sources.sources[sounds], AL_PITCH, 1.0f);
        alSourcef(_sources.sources[sounds], AL_GAIN, 1.0f);
        alSourcei(_sources.sources[sounds], AL_BUFFER, buffers[0]);
    }
    
    return self;
}

- (BOOL) queueBuffer:(ALshort *)pcm
{
    ALint isStopped = 0, playedBuffers = 0;
    ALint src = _sources.sources[0];
    
    alGetSourcei(src, AL_SOURCE_STATE, &isStopped);
    
    if(isStopped == AL_STOPPED)
        NSLog(@"Stopped");
    
        ALuint nextBuffer = 0;
        ALint i = -1;
        
        alGetSourcei(src, AL_BUFFERS_PROCESSED, &playedBuffers);
        
        if(playedBuffers > 0){
            alSourceUnqueueBuffers(src, 1, &nextBuffer);

            if(buffers[0] == nextBuffer)
                i = 0;
            if(buffers[1] == nextBuffer)
                i = 1;
            if(buffers[2] == nextBuffer)
                i = 2;
        }
        else{
            if(availableBuffers){
                nextBuffer = buffers[i = (--availableBuffers)];
            }
            else{
                return NO;
            }
        }
    
        assert(i >= 0);
        assert(nextBuffer == buffers[i]);
    
        memcpy(streamBuffs[i], pcm, sizeof(ALshort) * SOUND_STREAM_BUFFER_SAMPLES);
        alBufferData(buffers[i],
                     AL_FORMAT_MONO16,
                     streamBuffs[i],
                     sizeof(ALshort) * SOUND_STREAM_BUFFER_SAMPLES,
                     SOUND_SAMPLES_PER_SEC << 1
                     );
    
        assert(buffers[i]);
    
        alSourceQueueBuffers(src, 1, buffers + i);

    return YES;
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
    int i = _sources.currentSource;
    alSourcefv(_sources.sources[i], AL_POSITION, location);
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
