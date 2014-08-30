//
//  ReoccuringEvent.m
//  OPjective
//
//  Created by Kirk Roerig on 8/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "ReoccuringEvent.h"

@interface ReoccuringEvent(){

}

@property float interval;
@property float elapsed;
@property id callback;

@end

@interface NSObject(ReoccuringEvent)
- (void) tick:(float*)interval;
@end

static NSMutableArray* events;

@implementation ReoccuringEvent

+ (void) updateWithTimeElapsed:(double)dt
{
    for (ReoccuringEvent* event in events) {
        [event updateWithTimeElapsed:dt];
    }
}

- (id) initWithCallback:(id)callback andInterval:(float)seconds
{
    self = [super init];
    
    _interval = seconds;
    _callback = callback;
    _elapsed  = 0;
    
    if(!events){
        events = [[NSMutableArray alloc] init];
    }
    
    [events addObject:self];
    
    return self;
}

- (void) unregister
{
    [events removeObject:self];
}

- (void) updateWithTimeElapsed:(double)dt
{
    self.elapsed += dt;
    
    // if enough time has elapsed, then trigger
    // the callback and reset the elapsed time
    if(self.elapsed >= self.interval){
        [_callback tick:&_interval];
        self.elapsed = 0;
    }
}

@end
