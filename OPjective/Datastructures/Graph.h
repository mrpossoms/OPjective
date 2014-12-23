//
//  Graph.h
//  OPjective
//
//  Created by Kirk Roerig on 12/12/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphNode : NSObject

@property NSMutableArray* edges;

@property id tag;
@property id value;
@property id key;

- (void)connectTo:(GraphNode*)node;
- (void)connectToBoth:(GraphNode*)node;

@end

@interface Graph : NSDictionary

@property NSMutableDictionary* atlas;

- (GraphNode*)objectForKeyedSubscript:(id <NSCopying>)key;
- (GraphNode*)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end
