//
//  Updateable.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Updateable <NSObject>

- (void) updateWithTimeElapsed:(double) dt;

@end
