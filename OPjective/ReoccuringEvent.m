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

+ (ReoccuringEvent*)addWithCallback:(id)callback andInterval:(float)seconds
{
    ReoccuringEvent* newEvent = [[ReoccuringEvent alloc] init];
    
    newEvent.interval = seconds;
    newEvent.callback = callback;
    newEvent.elapsed  = 0;
    
    if(!events){
        events = [[NSMutableArray alloc] init];
    }
    
    [events addObject:newEvent];
    
    return newEvent;
}

+ (void)unregisterEvent:(ReoccuringEvent *)event
{
    [events removeObject:event];
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
