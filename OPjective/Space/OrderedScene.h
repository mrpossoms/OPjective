//
//  OrderedScene.h
//  OPjective
//
//  Created by Kirk Roerig on 8/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rendering/ObjectGroup.h"
#import "Protocols/Drawable.h"
#import "Protocols/Updateable.h"
#import "Protocols/Ranked.h"
#import "Protocols/Perishable.h"

@interface OrderedScene : NSObject <Updateable, Drawable>

@property NSMutableArray* updatableObjects;
@property NSMutableArray* drawableObjects;

- (id)init;
- (void)addRenderGroup:(ObjectGroup*)group withName:(NSString*)name;
- (void)addObject:(id <Ranked>)obj;
- (void)addObject:(id <Ranked>)obj toGroup:(NSString*)groupName;
- (NSMutableArray*)objectsFromGroup:(NSString*)groupName;
- (void)addObjects:(NSArray*)objs;
- (void)addObjects:(NSArray*)objs toGroup:(NSString*)groupName;
- (void)removeObject:(id)obj;
- (void)removeObjects:(NSMutableArray*)objs;

@end
