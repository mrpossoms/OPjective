//
//  RenderGroup.m
//  OPjective
//
//  Created by Kirk Roerig on 12/4/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "RenderGroup.h"

@interface RenderGroup()

@property (nonatomic, readwrite) NSMutableArray* drawableObjects;

@end

@implementation RenderGroup

- (instancetype)init
{
    self = [super init];
    
    if(self){
        _drawableObjects = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addObject:(id<Ranked,Drawable>)obj
{
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

- (void)removeObject:(id)obj
{
    if([obj conformsToProtocol:@protocol(Drawable)]){
        [_drawableObjects removeObject:obj];
    }
}

- (void)drawWithViewProjection:(GLKMatrix4 *)viewProjection
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
