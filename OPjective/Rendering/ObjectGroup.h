//
//  RenderGroup.h
//  OPjective
//
//  Created by Kirk Roerig on 12/4/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols/Drawable.h"
#import "Protocols/Updateable.h"
#import "Protocols/Ranked.h"

@interface ObjectGroup : NSObject<Ranked, Drawable, Updateable>

@property (nonatomic) NSMutableArray* drawableObjects;
@property (nonatomic) NSMutableArray* updateableObjects;

- (void)addObject:(id<Ranked>)object;
- (void)removeObjects:(NSArray*)objects;
- (void)removeObject:(id)object;

@end
