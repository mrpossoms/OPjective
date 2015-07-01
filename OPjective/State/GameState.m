//
//  GameState.m
//  OPjective
//
//  Created by Kirk Roerig on 12/18/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "GameState.h"

static GameState* GAMESTATE_ACTIVE;

#define EACH_SUB_STATE for(GameState* state in _subStates)

@implementation GameState

- (instancetype)init
{
    self = [super init];
    if(!self) return nil;
    
    _subStates = [NSMutableArray array];
    
    return self;
}

- (void)updateWithTimeElapsed:(double)dt
{
    EACH_SUB_STATE{
        [state updateWithTimeElapsed:dt];
    }
}

- (void)drawWithViewProjection:(const GLKMatrix4 *)viewProjection
{
    EACH_SUB_STATE{
        [state drawWithViewProjection:viewProjection];
    }
}

- (void)batchDrawStartWithViewProjection:(const GLKMatrix4 *)vp
{
    EACH_SUB_STATE{
        [state batchDrawStartWithViewProjection:vp];
    }
}

- (void)batchDraw
{
    EACH_SUB_STATE{
        [state batchDraw];
    }
}

- (void)receiveTouches:(NSSet*)touches
{
    EACH_SUB_STATE{
        [state receiveTouches:touches];
    }
}

- (void)receiveTouchesMoved:(NSSet *)touches
{
    EACH_SUB_STATE{
        [state receiveTouchesMoved:touches];
    }
}

- (void)receiveTouchesEnded:(NSSet *)touches
{
    EACH_SUB_STATE{
        [state receiveTouchesEnded:touches];
    }
}

- (void)receiveGesture:(UIGestureRecognizer *)gesture
{
    EACH_SUB_STATE{
        [state receiveGesture:gesture];
    }
}

- (void)receiveCustomSwipe:(GLKVector2)swipeDirection
{
    EACH_SUB_STATE{
        [state receiveCustomSwipe:swipeDirection];
    }
}

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

+ (void)sendTouchesMoved:(NSSet *)touches
{
    [GAMESTATE_ACTIVE receiveTouchesMoved:touches];
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
