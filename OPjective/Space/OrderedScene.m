//
//  OrderedScene.m
//  OPjective
//
//  Created by Kirk Roerig on 8/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "RenderGroup.h"
#import "OrderedScene.h"
#import <GLKit/GLKit.h>

@interface OrderedScene()

@property (nonatomic) NSMutableDictionary* renderGroups;

@end

@implementation OrderedScene

- (id) init
{
    self = [super init];
    
    _updatableObjects = [[NSMutableArray alloc] init];
    _drawableObjects  = [[NSMutableArray alloc] init];
    _renderGroups     = [[NSMutableDictionary alloc] init];
    
    // create the default render group that non-specific objects
    // will be added to and rendered from
    _renderGroups[@"default"] = [[RenderGroup alloc] init];
    [_drawableObjects addObject:_renderGroups[@"default"]];
    
    return self;
}

- (void)addRenderGroup:(RenderGroup *)group withName:(NSString *)name
{
    self.renderGroups[name] = group;
    [self addObject:group];
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
        RenderGroup* rg = self.renderGroups[@"default"];
        [rg addObject:obj];
    }
}

- (void) addObject:(id)obj toGroup:(NSString*)groupName
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
        if(!self.renderGroups[groupName]){
            NSLog(@"Could not add %@ to renderGroup '%@' it was not found!", obj, groupName);
            return;
        }
        
        // add the object to the updatable collection
        RenderGroup* rg = self.renderGroups[groupName];
        [rg addObject:obj];
    }
}



- (void) removeObject:(id)obj
{
    if([obj conformsToProtocol:@protocol(Updateable)]){
        [_updatableObjects removeObject:obj];
    }
    
    // remove the object from all the render groups
    if([obj conformsToProtocol:@protocol(Drawable)]){
        for(RenderGroup* rg in self.renderGroups){
            [rg removeObject:obj];
        }
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
        if([object conformsToProtocol:@protocol(Perishable)]){
            if([(id <Perishable>)object perished]){
                [self removeObject:object];
            }
        }
    }
}

- (void) drawWithViewProjection:(GLKMatrix4 *)viewProjection
{
    for (id object in _drawableObjects) {
        [(id <Drawable>)object drawWithViewProjection:viewProjection];
    }
}

@end
