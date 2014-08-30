//
//  OrderedScene.h
//  OPjective
//
//  Created by Kirk Roerig on 8/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols/Drawable.h"
#import "Protocols/Updateable.h"
#import "Ranked.h"

@interface OrderedScene : NSObject <Updateable, Drawable>

@property NSMutableArray* updatableObjects;
@property NSMutableArray* drawableObjects;

- (id) init;
- (void) addObject:(id <Ranked>) obj;
- (void) removeObject:(id)obj;
- (void) removeObjects:(NSMutableArray*)objs;

@end
