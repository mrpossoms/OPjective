//
//  GameState.m
//  OPjective
//
//  Created by Kirk Roerig on 12/18/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "GameState.h"

static GameState* GAMESTATE_ACTIVE;


@implementation GameState

- (void)updateWithTimeElapsed:(double)dt{}
- (void)drawWithViewProjection:(const GLKMatrix4 *)viewProjection{}
- (void)receiveTouches:(NSSet*)touches{}
- (void)receiveTouchesEnded:(NSSet *)touches{}
- (void)receiveGesture:(UIGestureRecognizer *)gesture{}
- (void)receiveCustomSwipe:(GLKVector2)swipeDirection{}
- (void)enterFromState:(GameState *)last{}
- (void)exitToState:(GameState *)next{}

+ (void)switchToState:(GameState *)next
{
    if(GAMESTATE_ACTIVE){
        [GAMESTATE_ACTIVE exitToState:next];
    }
    
    GameState* last = GAMESTATE_ACTIVE;
    [next enterFromState:last];
    GAMESTATE_ACTIVE = next;
}

+ (void)sendTouches:(NSSet *)touches
{
    [GAMESTATE_ACTIVE receiveTouches:touches];
}

+ (void)sendTouchesEnded:(NSSet*)touches
{
    [GAMESTATE_ACTIVE receiveTouchesEnded:touches];
}

+ (void)sendGesture:(UIGestureRecognizer *)gesture
{
    [GAMESTATE_ACTIVE receiveGesture:gesture];
}

+ (void)sendCustomSwipe:(GLKVector2)swipeDirection
{
    [GAMESTATE_ACTIVE receiveCustomSwipe:swipeDirection];
}

static CFAbsoluteTime GAMESTATE_LAST_TIME;
+ (double)updateActive
{
    if(!GAMESTATE_LAST_TIME){
        GAMESTATE_LAST_TIME = CFAbsoluteTimeGetCurrent();
    }
    
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime dt = now - GAMESTATE_LAST_TIME;
    
    if(GAMESTATE_ACTIVE){
        if(dt < 0.25){
            [GAMESTATE_ACTIVE updateWithTimeElapsed:dt];
        }
    }
    
    GAMESTATE_LAST_TIME = now;
    
    return dt;
}

+ (GameState*)getActive
{
    return GAMESTATE_ACTIVE;
}

@end
