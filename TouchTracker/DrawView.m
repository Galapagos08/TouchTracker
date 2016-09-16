//
//  DrawView.m
//  TouchTracker
//
//  Created by Dan Esrey on 2016/16/09.
//  Copyright © 2016 Dan Esrey. All rights reserved.
//

#import "DrawView.h"

@implementation DrawView

- (void)strokeLine:(Line *)line {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = 10;
    path.lineCapStyle = kCGLineCapRound;
    [path moveToPoint:line.begin];
    [path addLineToPoint:line.end];
    [path stroke];
}

- (void)drawRect:(CGRect)rect {
    // Draw finished lines in black
    [[UIColor blackColor] setStroke];
   
    for (Line *line in self.finishedLines) {
        [self strokeLine:line];
    }
    [[UIColor redColor] setStroke];
    for (Line *line in self.currentLines.allValues) {
        [self strokeLine:line];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Let's put in a log statement to see the order of events
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self];
        Line *newLine = [[Line alloc] initWithBegin:location end:location];
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        self.currentLines[key] = newLine;
    }
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // Let's put in a print statement to see the order of events
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self];
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        Line *line = self.currentLines[key];
        line.end = location;
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Let's put in a print statement to see the order of events
    NSLog(@"%s", __PRETTY_FUNCTION__);
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self];
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        Line *line = self.currentLines[key];
        line.end = location;
        [self.finishedLines addObject:line];
        [self.currentLines removeObjectForKey:key];
    }
    [self setNeedsDisplay];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _finishedLines = [[NSMutableArray alloc] init];
        _currentLines = [[NSMutableDictionary alloc] init];

    }
    return self;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Let's put in a print statement to see the order of events
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self.currentLines removeAllObjects];
  
    [self setNeedsDisplay];
}

@end
