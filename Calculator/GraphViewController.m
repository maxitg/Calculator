//
//  GraphViewController.m
//  Calculator
//
//  Created by Maxim Piskunov on 13.07.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <GraphViewDataSource>

@end

@implementation GraphViewController

@synthesize program = _program;
@synthesize graphDisplay = _graphDisplay;

- (float)functionValueForX:(float)x
{
    NSDictionary* variableValues = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:x] forKey:@"x"];
    id result = [CalculatorBrain runProgram:self.program usingVariableValues:variableValues];
    return [result isKindOfClass:[NSNumber class]] ? [result doubleValue] : NAN;
}

- (void)setGraphDisplay:(GraphView *)graphDisplay
{
    _graphDisplay = graphDisplay;
    
    [graphDisplay addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:graphDisplay action:@selector(pinch:)]];
    
    [graphDisplay addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:graphDisplay action:@selector(pan:)]];
    
    UITapGestureRecognizer *tripleTapRecognizer= [[UITapGestureRecognizer alloc] initWithTarget:graphDisplay action:@selector(tripleTap:)];
    tripleTapRecognizer.numberOfTapsRequired = 3;
    [graphDisplay addGestureRecognizer:tripleTapRecognizer];
    
    self.graphDisplay.dataSource = self;
}

- (void)setProgram:(id)program
{
    _program = program;
    self.title = [CalculatorBrain descriptionOfProgram:program];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)viewDidUnload {
    [self setGraphDisplay:nil];
    [super viewDidUnload];
}

@end
