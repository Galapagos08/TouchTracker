//
//  DrawView.h
//  TouchTracker
//
//  Created by Dan Esrey on 2016/16/09.
//  Copyright © 2016 Dan Esrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Line.h"

@interface DrawView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic) NSMutableDictionary *currentLines;
@property (nonatomic) NSMutableArray *finishedLines;
@property (nonatomic, weak) Line *selectedLine;
@property (nonatomic) UIPanGestureRecognizer *moveRecognizer;

@end
