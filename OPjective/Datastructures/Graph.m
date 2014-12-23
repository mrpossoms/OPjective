//
//  Graph.m
//  OPjective
//
//  Created by Kirk Roerig on 12/12/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "Graph.h"

@implementation GraphNode

- (instancetype)initWithKey:(id)key andValue:(id)value
{
    self = [super init];
    
    if(self){
        _key = key;
        _value = value;
        _edges = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)connectTo:(GraphNode *)node
{
    // create a unidirectional path
    [self.edges addObject:node];
}

- (void)connectToBoth:(GraphNode*)node
{
    // create a bidirectional path
    [self.edges addObject:node];
    [node.edges addObject:self];
}

@end

@implementation Graph

- (instancetype)init
{
    self = [super init];
    
    _atlas = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (GraphNode*)objectForKeyedSubscript:(id <NSCopying>)key
{
   return (GraphNode*)_atlas[key];
}

- (GraphNode*)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    GraphNode* newNode = _atlas[key];
    
    if(!newNode){
        newNode = [[GraphNode alloc] initWithKey:key andValue:obj];
        _atlas[key] = newNode;
    }
    
    return newNode;
}

@end
