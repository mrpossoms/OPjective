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
- (void)drawWithViewProjection:(GLKMatrix4 *)viewProjection{}
- (void)receiveTouches:(NSSet*)touches{}

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

static CFAbsoluteTime GAMESTATE_LAST_TIME;
+ (void)updateActive
{
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime dt = now - GAMESTATE_LAST_TIME;
    
    if(GAMESTATE_ACTIVE){
        [GAMESTATE_ACTIVE updateWithTimeElapsed:dt];
    }
    
    GAMESTATE_LAST_TIME = now;
}

@end
