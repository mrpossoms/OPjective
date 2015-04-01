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
- (void)receiveCustomSwipe:(GLKVector2)swipeDirection;

+ (void)switchToState:(GameState*)state;
+ (void)sendTouches:(NSSet*)touches;
+ (void)sendTouchesEnded:(NSSet*)touches;
+ (void)sendGesture:(UIGestureRecognizer*)gesture;
+ (void)sendCustomSwipe:(GLKVector2)swipeDirection;
+ (double)updateActive; // returns time elapsed
+ (GameState*)getActive;

@end
