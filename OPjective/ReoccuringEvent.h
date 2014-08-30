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

+ (void) updateWithTimeElapsed:(double)dt;

- (id) initWithCallback:(id)callback andInterval:(float)seconds;
- (void) unregister;

@end
