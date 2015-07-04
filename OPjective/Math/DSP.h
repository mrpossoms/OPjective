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

static inline float DSP_half(float t)
{
    return fabsf(cosf(t));
}

static inline float DSP_mod(float t, float fc, float fr, float fd, float fm, float fmr)
{
    return DSP_half(2 * M_PI * fc * t * fr + (fd/fm) * DSP_half(2 * M_PI * fm * t) * fmr);
}

static inline double DSP_mix(int num, ...)
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
