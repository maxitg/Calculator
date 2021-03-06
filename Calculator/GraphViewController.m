//
//  GraphViewController.m
//  Calculator
//
//  Created by Maxim Piskunov on 13.07.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <GraphViewDataSource, UISplitViewControllerDelegate>

@end

@implementation GraphViewController

@synthesize program = _program;
@synthesize graphDisplay = _graphDisplay;
@synthesize programDisplay = _programDisplay;

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
    
    UITapGestureRecognizer *tripleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:graphDisplay action:@selector(tripleTap:)];
    tripleTapRecognizer.numberOfTapsRequired = 3;
    [graphDisplay addGestureRecognizer:tripleTapRecognizer];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    graphDisplay.scale = [userDefaults floatForKey:@"scale"];
    CGPoint defaultOrigin;
    defaultOrigin.x = [userDefaults floatForKey:@"origin.x"];
    defaultOrigin.y = [userDefaults floatForKey:@"origin.y"];
    graphDisplay.origin = defaultOrigin;
    
    self.graphDisplay.dataSource = self;
}

- (void)setProgram:(id)program
{
    _program = program;
    self.title = [CalculatorBrain descriptionOfProgram:program];
    self.programDisplay.title = [CalculatorBrain descriptionOfProgram:program];
    [self.graphDisplay setNeedsDisplay];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Calculator";
    NSMutableArray* toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems insertObject:barButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray* toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems removeObjectAtIndex:0];
    self.toolbar.items = toolbarItems;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)viewDidUnload {
    [self setGraphDisplay:nil];
    [self setProgramDisplay:nil];
    [super viewDidUnload];
}

@end
