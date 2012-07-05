//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Maxim Piskunov on 29.06.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain ()

@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (id)program
{
    return [self.programStack copy];
}

+ (NSString*)descriptionOfProgram:(id)program
{
    return @"Not yet implemented.";
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}
 
+ (double)popOperandOffProgramStack:(NSMutableArray*) stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        
        if ([topOfStack isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
            
        } else if ([topOfStack isEqualToString:@"*"]) {
            result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
            
        } else if ([topOfStack isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
            
        } else if ([topOfStack isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            double dividend = [self popOperandOffProgramStack:stack];
            if (divisor) result = dividend / divisor;
            
        } else if ([topOfStack isEqualToString:@"sin"]) {
            result = sin([self popOperandOffProgramStack:stack]);
            
        } else if ([topOfStack isEqualToString:@"cos"]) {
            result = cos([self popOperandOffProgramStack:stack]);
            
        } else if ([topOfStack isEqualToString:@"sqrt"]) {
            double operand = [self popOperandOffProgramStack:stack];
            if (operand >= 0) result = sqrt(operand);
            
        } else if ([topOfStack isEqualToString:@"π"]) {
            result = M_PI;
            
        } else if ([topOfStack isEqualToString:@"+ / -"]) {
            result = -[self popOperandOffProgramStack:stack];
        }
    }
    
    return result;
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack];
}

- (void)clear
{
    [self.programStack removeAllObjects];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"stack = %@", self.programStack];
}

@end
