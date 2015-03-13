//
//  OPbjective.m
//  OPbjective
//
//  Created by Kirk Roerig on 8/20/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "OPjective.h"

@implementation OPjective

+ (GLKVector2)cannonicalFromTouch:(UITouch*)touch
{
    CGSize dims = [UIScreen mainScreen].bounds.size;
    float aspect = dims.height / dims.width;
    CGPoint loc = [touch locationInView:touch.view];

    return GLKVector2Make(
          (loc.x * 2.0 / touch.window.frame.size.width) - 1.0f,
          ((loc.y * -2.0 / touch.window.frame.size.height) + 1.0f) * aspect
    );
}

@end
