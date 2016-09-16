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
        
        UILongPressGestureRecognizer *longPressGestureRecognizer
        = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                        action:@selector(longPress:)];
        
        [self addGestureRecognizer:longPressGestureRecognizer];
        
        _moveRecognizer
        = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(moveLine:)];
        
        _moveRecognizer.delegate = self;
        _moveRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:_moveRecognizer];

    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGR {
    if (gestureRecognizer == self.moveRecognizer) {
        return YES; }
    return NO; }


- (void)longPress:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:self];
        self.selectedLine = [self lineAtPoint:point];
        if (self.selectedLine) {
            [self.currentLines removeAllObjects];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.selectedLine = nil;
    }
    [self setNeedsDisplay];
}

- (void)moveLine:(UIPanGestureRecognizer *)gestureRecognizer {
    // If we have a selected line ...
    Line *line = self.selectedLine;
    if (line) {
        // When the pan recognizer changes its position...
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            // How far has the pan moved?
            CGPoint translation = [gestureRecognizer translationInView:self];
           
            // Add the translation to the current beginning and end points of the line
            // Make sure there are no copy and paste typos!
            CGPoint begin = line.begin;
            begin.x += translation.x;
            begin.y += translation.y;
            line.begin = begin;
            
            CGPoint end = line.end;
            end.x += translation.x;
            end.y += translation.y;
            line.end = end;
            
            [gestureRecognizer setTranslation:CGPointZero inView:self];
            
            // Redraw the screen
            [self setNeedsDisplay];
        }
    } else {
        // If we have not selected a line, we do not do anything here
        return; }
}

- (void)tap:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"Recognized a tap");
   
    CGPoint point = [gestureRecognizer locationInView:self];
    self.selectedLine = [self lineAtPoint:point];
   
    // Grab the menu controller
    UIMenuController *menu = [UIMenuController sharedMenuController];

    if (self.selectedLine) {
        // Make ourselves the target of menu item action messages
        [self becomeFirstResponder];
    
        // Create a new "Delete" UIMenuItem
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete"
                                                            action:@selector(deleteLine:)];
        menu.menuItems = @[deleteItem];
        
        // Tell the menu where it should come from and show it
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menu setMenuVisible:YES animated:YES];
    } else {
        // Hide the menu if no line is selected
        [menu setMenuVisible:NO animated:YES];
    }
    [self setNeedsDisplay];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)deleteLine:(id)sender {
    // Remove the selected line from the list of finishedLines
    if (self.selectedLine) {
        [self.finishedLines removeObject:self.selectedLine];
        [self setNeedsDisplay];
    }
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
