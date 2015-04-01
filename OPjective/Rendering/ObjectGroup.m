//
//  RenderGroup.m
//  OPjective
//
//  Created by Kirk Roerig on 12/4/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "ObjectGroup.h"

@interface ObjectGroup()

@end

@implementation ObjectGroup

- (instancetype)init
{
    self = [super init];
    
    if(self){
        _drawableObjects = [NSMutableArray array];
        _updateableObjects = [NSMutableArray array];
    }
    
    return self;
}

- (void)addObject:(id<Ranked>)obj
{
    if([obj conformsToProtocol:@protocol(Drawable)]){
        [_drawableObjects addObject:obj];
        [_drawableObjects sortUsingComparator:^NSComparisonResult(id <Ranked> a, id <Ranked> b) {
            if([a drawRank] < [b drawRank]){
                return NSOrderedAscending;
            }
            else if([a drawRank] > [b drawRank]){
                return NSOrderedDescending;
            }
            
            return NSOrderedSame;
        }];
    }

    if([obj conformsToProtocol:@protocol(Updateable)]){
        [_updateableObjects addObject:obj];
        [_updateableObjects sortUsingComparator:^NSComparisonResult(id <Ranked> a, id <Ranked> b) {
            if([a updateRank] < [b updateRank]){
                return NSOrderedAscending;
            }
            else if([a updateRank] > [b updateRank]){
                return NSOrderedDescending;
            }
            
            return NSOrderedSame;
        }];
    }
}

- (void)removeObjects:(NSArray *)objects
{
    [_drawableObjects removeObjectsInArray:objects];
    [_updateableObjects removeObjectsInArray:objects];
}

- (void)removeObject:(id)obj
{
    [_drawableObjects removeObject:obj];
    [_updateableObjects removeObject:obj];
}

- (void)updateWithTimeElapsed:(double)dt
{
    for(int i = 0; i < _updateableObjects.count; ++i){
        id<Updateable> updateable = _updateableObjects[i];
        [updateable updateWithTimeElapsed:dt];
    }
}

- (void)drawWithViewProjection:(const GLKMatrix4 *)viewProjection
{
    for(int i = 0; i < _drawableObjects.count; ++i){
        id<Drawable> drawable = _drawableObjects[i];
        [drawable drawWithViewProjection:viewProjection];
    }
}

- (int)updateRank
{
    return 0;
}

- (int)drawRank
{
    return 0;
}

@end
