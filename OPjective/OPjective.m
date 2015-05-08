//
//  OPbjective.m
//  OPbjective
//
//  Created by Kirk Roerig on 8/20/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import "OPjective.h"
#include <sys/sysctl.h>
#include <mach/machine.h>

@implementation OPjective

+ (float)aspectRatio
{
    CGSize dims = [UIScreen mainScreen].bounds.size;
    
    if(dims.height > dims.width){
        return dims.height / dims.width;
    }
    
    return dims.width / dims.height;
}

+ (GLKVector2)cannonicalFromTouch:(UITouch*)touch
{
    float aspect = [self aspectRatio];
    CGPoint loc = [touch locationInView:touch.view];
    
    float x,y;
    
    if(touch.window.frame.size.height > touch.window.frame.size.width){
        x = (loc.x * 2.0 / touch.window.frame.size.height) - 1.0f;
        y = ((loc.y * -2.0 / touch.window.frame.size.width) + 1.0f) * aspect;
    }
    else{
        x = (loc.x * 2.0 / touch.window.frame.size.width) - 1.0f;
        y = ((loc.y * -2.0 / touch.window.frame.size.height) + 1.0f) * aspect;
    }
    
    return GLKVector2Make(x, y);
}

+ (NSString *)platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}


+ (enum MachineSpec)machinePerformance
{
    NSString *platform = [OPjective platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return LOW_SPEC;
    if ([platform isEqualToString:@"iPhone1,2"])    return LOW_SPEC;
    if ([platform isEqualToString:@"iPhone2,1"])    return LOW_SPEC;
    if ([platform isEqualToString:@"iPhone3,1"])    return LOW_SPEC;
    if ([platform isEqualToString:@"iPhone3,2"])    return LOW_SPEC;
    if ([platform isEqualToString:@"iPhone3,3"])    return LOW_SPEC;
    if ([platform isEqualToString:@"iPod1,1"])      return LOW_SPEC;
    if ([platform isEqualToString:@"iPod2,1"])      return LOW_SPEC;
    if ([platform isEqualToString:@"iPod3,1"])      return LOW_SPEC;
    if ([platform isEqualToString:@"iPod4,1"])      return LOW_SPEC;
    if ([platform isEqualToString:@"iPad1,1"])      return LOW_SPEC;
    if ([platform isEqualToString:@"iPad1,2"])      return LOW_SPEC;
    if ([platform isEqualToString:@"iPad3,1"])      return LOW_SPEC;
    if ([platform isEqualToString:@"iPad3,2"])      return LOW_SPEC;
    if ([platform isEqualToString:@"iPad3,3"])      return LOW_SPEC;
    
    if ([platform isEqualToString:@"iPhone4,1"])    return MED_SPEC;
    if ([platform isEqualToString:@"iPhone5,1"])    return MED_SPEC;
    if ([platform isEqualToString:@"iPhone5,2"])    return MED_SPEC;
    if ([platform isEqualToString:@"iPod5,1"])      return MED_SPEC;
    if ([platform isEqualToString:@"iPad2,1"])      return MED_SPEC;
    if ([platform isEqualToString:@"iPad2,2"])      return MED_SPEC;
    if ([platform isEqualToString:@"iPad2,3"])      return MED_SPEC;
    if ([platform isEqualToString:@"iPad2,4"])      return MED_SPEC;
    if ([platform isEqualToString:@"iPad2,5"])      return MED_SPEC;
    if ([platform isEqualToString:@"iPad2,6"])      return MED_SPEC;
    if ([platform isEqualToString:@"iPad2,7"])      return MED_SPEC;

    if ([platform isEqualToString:@"iPad3,4"])      return HIGH_SPEC;
    if ([platform isEqualToString:@"iPad3,5"])      return HIGH_SPEC;
    if ([platform isEqualToString:@"iPad3,6"])      return HIGH_SPEC;
    if ([platform isEqualToString:@"iPad4,4"])      return HIGH_SPEC;

    return UNKNOWN_SPEC;
}

@end
