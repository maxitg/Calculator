//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Maxim Piskunov on 29.06.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

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

- (void)updateProgramDisplayWithEquals:(BOOL)equals
{
    self.programDisplay.text = [[self.brain class] descriptionOfProgram:self.brain.program];
    if (equals) self.programDisplay.text = [self.programDisplay.text stringByAppendingString:@" ="];
}

- (void)updateDisplay
{
    self.display.text = [NSString stringWithFormat:@"%g", [[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
}

- (void)updateVariableDisplay
{
    NSSet *variables = [[self.brain class] variablesUsedInProgram:self.brain.program];
    NSMutableArray *displayComponents = [[NSMutableArray alloc] init];
    for (NSString *variableName in variables) {
        [displayComponents addObject:[NSString stringWithFormat:@"%@ = %g", variableName, [[self.testVariableValues objectForKey:variableName] doubleValue]]];
    }
    self.variableDisplay.text = [displayComponents componentsJoinedByString:@" "];
}

- (void)update
{
    [self updateDisplay];
    [self updateProgramDisplayWithEquals:YES];
    [self updateVariableDisplay];
}

- (IBAction)digitPressed:(UIButton *)sender
{
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        if (![digit isEqualToString:@"0"]) self.userIsInTheMiddleOfEnteringANumber = YES;
        [self updateProgramDisplayWithEquals:NO];
    }
}

- (IBAction)enterPressed
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self updateProgramDisplayWithEquals:YES];
}

- (IBAction)variableTest0Pressed {
    self.testVariableValues = nil;
    [self updateVariableDisplay];
    self.display.text = [NSString stringWithFormat:@"%g", [[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
}

- (IBAction)variableTest1Pressed {
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithDouble:3.2], @"x",
                               [NSNumber numberWithDouble:100.6], @"y",
                               [NSNumber numberWithDouble:-4.2], @"z",
                               [NSNumber numberWithDouble:0.], @"t",
                               nil];
    [self updateVariableDisplay];
    self.display.text = [NSString stringWithFormat:@"%g", [[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
}

- (IBAction)variableTest2Pressed {
    self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithDouble:3.2E23], @"x",
                               [NSNumber numberWithDouble:2.1E-23], @"y",
                               [NSNumber numberWithDouble:-1.2E12], @"z",
                               [NSNumber numberWithDouble:0.], @"t",
                               nil];
    [self updateVariableDisplay];
    self.display.text = [NSString stringWithFormat:@"%g", [[self.brain class] runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
}

- (IBAction)variablePressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *variableName = sender.currentTitle;
    self.display.text = variableName;
    [self.brain pushVariable:variableName];
    [self updateProgramDisplayWithEquals:NO];
    [self updateVariableDisplay];
}

- (IBAction)operationPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation = sender.currentTitle;
    [self.brain pushOperation:operation];
    [self updateDisplay];
    [self updateProgramDisplayWithEquals:YES];
    if ([self.display.text isEqualToString:@"-0"]) self.display.text = @"0"; 
}

- (IBAction)plusMinusPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [NSString stringWithFormat:@"%g", -self.display.text.doubleValue];
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

- (IBAction)CPressed {
    [self.brain clear];
    self.display.text = @"0";
    self.programDisplay.text = @"";
    self.variableDisplay.text = @"";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.testVariableValues = nil;
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

- (void)viewDidUnload {
    [self setDisplay:nil];
    [self setProgramDisplay:nil];
    [self setVariableDisplay:nil];
    [super viewDidUnload];
}
@end
