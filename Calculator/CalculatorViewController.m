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

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize history = _history;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender
{
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        if (![digit isEqualToString:@"0"]) self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (void)addEqualsToHistory
{
    self.history.text = [self.history.text stringByAppendingString:@" ="];
}

- (void)removeEqualsFromHistory
{
    if ([self.history.text characterAtIndex:(self.history.text.length-1)] == '=') self.history.text = [self.history.text substringToIndex:(self.history.text.length-2)];
}

- (void)addHistoryItem:(NSString *)anItem
{
    if ([self.history.text isEqualToString:@""]) {
        self.history.text = anItem;
    } else {
        [self removeEqualsFromHistory];
        self.history.text = [self.history.text stringByAppendingFormat:@" %@", anItem];
    }
}

- (IBAction)enterPressed
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    [self addHistoryItem:self.display.text];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation = sender.currentTitle;
    double result = [self.brain performOperation:operation];
    [self addHistoryItem:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    if ([self.display.text isEqualToString:@"-0"]) self.display.text = @"0"; 
    [self addEqualsToHistory];
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
    }
}

- (IBAction)CPressed {
    [self.brain clear];
    self.display.text = @"0";
    self.history.text = @"";
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)backspacePressed {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text substringToIndex:(self.display.text.length-1)];
        if ([self.display.text isEqualToString:@""] || [self.display.text isEqualToString:@"-"]) {
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    } else {
        self.display.text = @"0";
        [self removeEqualsFromHistory];
    }
}

@end
