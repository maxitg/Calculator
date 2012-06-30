//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Maxim Piskunov on 29.06.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain ()

@property (nonatomic, strong) NSMutableArray *operandStack;

@end

@implementation CalculatorBrain

@synthesize operandStack = _operandStack;

- (NSMutableArray *)operandStack
{
    if (!_operandStack) {
        _operandStack = [[NSMutableArray alloc] init];
    }
    return _operandStack;
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.operandStack addObject:operandObject];
}

- (double)popOperand
{
    NSNumber *operandObject = [self.operandStack lastObject];
    if (operandObject) [self.operandStack removeLastObject];
    return [operandObject doubleValue];
}

- (double)performOperation:(NSString *)operation
{
    double result = 0;
    
    if ([operation isEqualToString:@"+"]) {
        result = [self popOperand] + [self popOperand];
    } else if ([@"*" isEqualToString:operation]) {
        result = [self popOperand] * [self popOperand];
    } else if ([operation isEqualToString:@"-"]) {
        double subtrahend = [self popOperand];
        result = [self popOperand] - subtrahend;
    } else if ([operation isEqualToString:@"/"]) {
        double divisor = [self popOperand];
        double dividend = [self popOperand];
        if (divisor) result = dividend / divisor;
    } else if ([operation isEqualToString:@"sin"]) {
        result = sin([self popOperand]);
    } else if ([operation isEqualToString:@"cos"]) {
        result = cos([self popOperand]);
    } else if ([operation isEqualToString:@"sqrt"]) {
        double operand = [self popOperand];
        if (operand >= 0) result = sqrt(operand);
    } else if ([operation isEqualToString:@"π"]) {
        result = M_PI;
    } else if ([operation isEqualToString:@"+ / -"]) {
        result = -[self popOperand];
    }
    
    [self pushOperand:result];
    
    return result;
}

- (void)clear
{
    [self.operandStack removeAllObjects];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"stack = %@", self.operandStack];
}

@end
