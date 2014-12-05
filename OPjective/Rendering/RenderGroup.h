//
//  RenderGroup.h
//  OPjective
//
//  Created by Kirk Roerig on 12/4/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols/Drawable.h"
#import "Protocols/Ranked.h"

@interface RenderGroup : NSObject<Ranked, Drawable>

@property (nonatomic, readonly) NSMutableArray* drawableObjects;

- (void)addObject:(id<Ranked, Drawable>)object;
- (void)removeObject:(id)object;

@end
