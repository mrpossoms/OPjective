//
//  ReoccuringEvent.h
//  OPjective
//
//  Created by Kirk Roerig on 8/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols/Updateable.h"

@interface ReoccuringEvent : NSObject <Updateable>

@property id callback;

+ (void) updateWithTimeElapsed:(double)dt;

+ (id)addWithCallback:(id)callback andInterval:(float)seconds;
+ (void)unregisterEvent:(ReoccuringEvent*)event;

- (void) unregister;

@end
