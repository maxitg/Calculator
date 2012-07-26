//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Maxim Piskunov on 29.06.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize programDisplay = _history;
@synthesize variableDisplay = _variableDisplay;

@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (void)updateDisplay
{
    id programResult = [[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    if ([programResult isKindOfClass:[NSNumber class]]) self.display.text = [NSString stringWithFormat:@"%g", [programResult doubleValue]];
    else if ([programResult isKindOfClass:[NSString class]]) self.display.text = programResult;
    else self.display.text = @"0";  //  it is a case of empty program
    if ([self.display.text isEqualToString:@"-0"]) self.display.text = @"0";
}

- (void)updateProgramDisplayWithEquals:(BOOL)equals
{
    self.programDisplay.text = [[self.brain class] descriptionOfProgram:self.brain.program];
    if (equals) self.programDisplay.text = [self.programDisplay.text stringByAppendingString:@" ="];
}

- (void)updateVariableDisplay
{
    NSSet *variables = [[self.brain class] variablesUsedInProgram:self.brain.program];
    NSMutableArray *displayComponents = [[NSMutableArray alloc] init];
    for (NSString *variableName in variables) {
        [displayComponents addObject:[NSString stringWithFormat:@"%@ = %g", variableName, [[self.testVariableValues objectForKey:variableName] doubleValue]]];
    }
    self.variableDisplay.text = [displayComponents componentsJoinedByString:@"  "];
}

- (void)update
{
    [self updateDisplay];
    [self updateProgramDisplayWithEquals:YES];
    [self updateVariableDisplay];
}

- (void)updateVariables
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self updateVariableDisplay];
    } else {
        [self updateDisplay];
        [self updateVariableDisplay];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraph"]) {
        [segue.destinationViewController setProgram:self.brain.program];
    }
}

- (IBAction)variableTest0Pressed
{
    self.testVariableValues = nil;
    [self updateVariables];
}

- (IBAction)variableTest1Pressed
{
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithDouble:3.2], @"x",
                               [NSNumber numberWithDouble:100.6], @"y",
                               [NSNumber numberWithDouble:-4.2], @"z",
                               [NSNumber numberWithDouble:0.], @"t",
                               nil];
    [self updateVariables];
}

- (IBAction)variableTest2Pressed
{
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithDouble:3.2E23], @"x",
                               [NSNumber numberWithDouble:2.1E-23], @"y",
                               [NSNumber numberWithDouble:-1.2E12], @"z",
                               [NSNumber numberWithDouble:0.], @"t",
                               nil];
    [self updateVariables];
}

- (IBAction)digitPressed:(UIButton *)sender
{
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([self.display.text isEqualToString:@"0"]) self.display.text = digit;
        else if ([self.display.text isEqualToString:@"-0"]) self.display.text = [NSString stringWithFormat:@"-%@", digit];
        else self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        [self updateProgramDisplayWithEquals:NO];
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)graphPressed {
    GraphViewController* graphViewController = [[[self splitViewController] viewControllers] objectAtIndex:1];
    graphViewController.program = self.brain.program;
}

- (IBAction)enterPressed
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self updateProgramDisplayWithEquals:YES];
}

- (IBAction)operationPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    if (![self.brain.program count] && ![sender.currentTitle isEqualToString:@"π"] && ![sender.currentTitle isEqualToString:@"e"]) [self enterPressed];   //  to avoid sqrt(?) at the start
    [self.brain pushOperation:sender.currentTitle];
    [self update];
}

- (IBAction)variablePressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    [self.brain pushVariable:sender.currentTitle];
    [self update];
}

- (IBAction)plusMinusPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([self.display.text isEqualToString:@"0"]) return;
        if ([self.display.text characterAtIndex:0] == '-') self.display.text = [self.display.text substringFromIndex:1];
        else self.display.text = [@"-" stringByAppendingString:self.display.text];
    } else {
        [self operationPressed:sender];
    }
}

- (IBAction)dotPressed
{
        // checking if there are no dots already on display
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([self.display.text rangeOfString:@"."].location == NSNotFound) {
            self.display.text = [self.display.text stringByAppendingString:@"."];
        }
    } else {
        self.display.text = @"0.";
        self.userIsInTheMiddleOfEnteringANumber = YES;
        [self updateProgramDisplayWithEquals:NO];
    }
}

- (IBAction)backspacePressed {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text substringToIndex:([self.display.text length]-1)];
        if ([self.display.text isEqualToString:@""] || [self.display.text isEqualToString:@"-"]) {
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    }
    if (!self.userIsInTheMiddleOfEnteringANumber) {
        [self.brain undo];
        [self update];
    }
}

- (IBAction)CPressed {
    [self.brain clear];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self update];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (self.splitViewController) return YES;
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) return YES;
    else return NO;
}

- (void)viewDidUnload {
    [self setDisplay:nil];
    [self setProgramDisplay:nil];
    [self setVariableDisplay:nil];
    [super viewDidUnload];
}
@end
