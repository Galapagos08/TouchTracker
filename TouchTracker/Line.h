//
//  Line.h
//  TouchTracker
//
//  Created by Dan Esrey on 2016/16/09.
//  Copyright © 2016 Dan Esrey. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Line : NSObject

@property (nonatomic) CGPoint begin;
@property (nonatomic) CGPoint end;

-(instancetype)initWithBegin:(CGPoint)begin end:(CGPoint)end;

@end
