//
//  DSP.h
//  OPjective
//
//  Created by Kirk Roerig on 6/18/15.
//  Copyright (c) 2015 OPifex. All rights reserved.
//

#ifndef OPjective_DSP_h
#define OPjective_DSP_h

#include <stdarg.h>

static double DSP_mix(int num, ...)
{
    double co = 1.0 / (float)num, sum = 0;
    
    va_list args;
    va_start(args, num);
    
    for(;num--;){
        sum += va_arg(args, double);
    }
    
    va_end(args);
    
    return sum * co;
}

#endif
