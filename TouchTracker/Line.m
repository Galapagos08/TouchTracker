//
//  Line.m
//  TouchTracker
//
//  Created by Dan Esrey on 2016/16/09.
//  Copyright © 2016 Dan Esrey. All rights reserved.
//

#import "Line.h"

@implementation Line

- (instancetype)initWithBegin:(CGPoint)begin end:(CGPoint)end {
    self = [super init];
    if (self) {
        _begin = begin;
        _end = end;
    }
    return self;
}

@end
