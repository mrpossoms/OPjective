//
//  OrderedScene.m
//  OPjective
//
//  Created by Kirk Roerig on 8/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "OrderedScene.h"
#import <GLKit/GLKit.h>

@interface OrderedScene()

@end

@implementation OrderedScene

- (id) init
{
    self = [super init];
    
    self.updatableObjects = [[NSMutableArray alloc] init];
    self.drawableObjects  = [[NSMutableArray alloc] init];

    return self;
}


- (void) addObject:(id)obj
{
    if([obj conformsToProtocol:@protocol(Updateable)]){
        // add the object to the updatable collection
        [_updatableObjects addObject:obj];
        
        [_updatableObjects sortUsingComparator:^NSComparisonResult(id <Ranked> a, id <Ranked> b) {
            if([a updateRank] < [b updateRank]){
                return NSOrderedAscending;
            }
            else if([a updateRank] > [b updateRank]){
                return NSOrderedDescending;
            }
            
            return NSOrderedSame;
        }];
    }
    
    if([obj conformsToProtocol:@protocol(Drawable)]){
        // add the object to the updatable collection
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
}

- (void) removeObject:(id)obj
{
    if([obj conformsToProtocol:@protocol(Updateable)]){
        [_updatableObjects removeObject:obj];
    }
    
    if([obj conformsToProtocol:@protocol(Drawable)]){
        [_drawableObjects removeObject:obj];
    }
}

- (void) removeObjects:(NSMutableArray*)objs
{
    [_updatableObjects removeObjectsInArray:objs];
    [_drawableObjects  removeObjectsInArray:objs];
}

- (void) updateWithTimeElapsed:(double)dt
{
    for (id object in _updatableObjects) {
        [(id <Updateable>)object updateWithTimeElapsed:dt];
    }
}

- (void) drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    for (id object in _drawableObjects) {
        [(id <Drawable>)object drawWithViewProjection:viewProjection];
    }
}

@end
