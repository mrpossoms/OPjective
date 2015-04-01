//
//  Drawable.h
//  BlastAR!
//
//  Created by Kirk Roerig on 8/23/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@protocol Drawable <NSObject>

- (void) drawWithViewProjection:(const GLKMatrix4*)viewProjection;

@end
