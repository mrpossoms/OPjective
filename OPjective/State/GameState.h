//
//  GameState.h
//  OPjective
//
//  Created by Kirk Roerig on 12/18/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols/Updateable.h"
#import "Protocols/Drawable.h"
#import "Protocols/Ranked.h"

@interface GameState : NSObject <Updateable, Drawable>

- (void)enterFromState:(GameState*)last;
- (void)exitToState:(GameState*)next;
- (void)updateWithTimeElapsed:(double)dt;
- (void)receiveTouches:(NSSet*)touches;
- (void)receiveTouchesEnded:(NSSet*)touches;
- (void)receiveGesture:(UIGestureRecognizer*)gesture;

+ (void)switchToState:(GameState*)state;
+ (void)sendTouches:(NSSet*)touches;
+ (void)sendTouchesEnded:(NSSet*)touches;
+ (void)updateActive;
+ (GameState*)getActive;

@end
