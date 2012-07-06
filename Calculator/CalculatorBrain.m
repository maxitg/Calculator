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
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

+ (BOOL)isOperation:(NSString *) aString
{
    NSSet* operations = [NSSet setWithObjects:@"+", @"*", @"-", @"/", @"sin", @"cos", @"sqrt", @"π", @"+ / -", nil];
    if ([operations containsObject:aString]) return YES;
    else return NO;
}

+ (double)popOperandOffProgramStack:(NSMutableArray *) stack
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
    return [self runProgram:program usingVariableValues:nil];
}

+ (NSIndexSet *)variableIndexesInProgram:(id)program
{
    BOOL (^isVariable)(id obj, NSUInteger idx, BOOL *stop);
    
    isVariable = ^ (id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]] && ![self isOperation:obj]) return YES;
        else return NO;
    };
    
    return [program indexesOfObjectsPassingTest:isVariable];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        
        //  Replacing variable names with its values
        
        void (^replaceVariable)(NSUInteger idx, BOOL *stop);
        
        replaceVariable = ^ (NSUInteger idx, BOOL *stop) {
            id variableValue = [variableValues objectForKey:[program objectAtIndex:idx]];
            if ([variableValue isKindOfClass:[NSNumber class]]) {   //  Maybe variableValue is NSString and isOperation
                [stack replaceObjectAtIndex:idx withObject:[variableValues objectForKey:[program objectAtIndex:idx]]];
            }
        };
        
        [[self variableIndexesInProgram:program] enumerateIndexesUsingBlock:replaceVariable];
    }
    return [self popOperandOffProgramStack:stack];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    return [NSSet setWithArray:[program objectsAtIndexes:[self variableIndexesInProgram:program]]];
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
