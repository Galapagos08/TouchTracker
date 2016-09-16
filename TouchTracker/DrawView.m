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
    if (self.selectedLine) {
        [[UIColor greenColor] setStroke];
        [self strokeLine:self.selectedLine];
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

- (void)doubleTap:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"Recognized a double tap");
    [self.currentLines removeAllObjects];
    [self.finishedLines removeAllObjects];
    [self setNeedsDisplay];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _finishedLines = [[NSMutableArray alloc] init];
        _currentLines = [[NSMutableDictionary alloc] init];
        
        UITapGestureRecognizer *doubleTapRecognizer
        = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(doubleTap:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:doubleTapRecognizer];
        UITapGestureRecognizer *tapRecognizer
        = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(tap:)];
        tapRecognizer.delaysTouchesBegan = YES;
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)tap:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"Recognized a tap");
    
    CGPoint point = [gestureRecognizer locationInView:self];
    self.selectedLine = [self lineAtPoint:point];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Let's put in a print statement to see the order of events
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self.currentLines removeAllObjects];
  
    
    [self setNeedsDisplay];
}

- (Line *)lineAtPoint:(CGPoint)point {
    // Find a line close to point
    for (Line *line in self.finishedLines) {
        CGPoint begin = line.begin;
        CGPoint end = line.end;
        // Check a few points on the line
        for (CGFloat t = 0; t < 1.0; t += 0.05) {
            CGFloat x = begin.x + ((end.x - begin.x) * t);
            CGFloat y = begin.y + ((end.y - begin.y) * t);
            // If the tapped point is within 20 points, let's return this line
            if (hypot(x - point.x, y - point.y) < 20.0) {
                return line;
            }
        } }
    // If nothing is close enough to the tapped point, then we did not select a line
    return nil; }


@end
