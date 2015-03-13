//
//  Touchable.h
//  OPjective
//
//  Created by Kirk Roerig on 12/27/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Touchable <NSObject>

- (BOOL)isTouchedBy:(UITouch*)touch;

@end
