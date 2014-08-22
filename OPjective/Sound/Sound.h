//
//  Sound.h
//  OPjective
//
//  Created by Kirk Roerig on 8/22/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>

@interface Sound : NSObject

- (id) initWithData:(ALshort*)data ofLength:(ALsizei)length  asStereo:(BOOL)isStereo;

- (void) play;
- (void) stop;
- (void) pause;
- (void) setVolume:(float)volume;
- (void) setPitch: (float)pitch;

@end
