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

    //  Operations helping methods

+ (BOOL)isOperation:(id) anObject
{
    NSSet *operations = [NSSet setWithObjects:@"+", @"*", @"-", @"/", @"sin", @"cos", @"sqrt", @"π", @"+ / -", nil];
    if ([operations containsObject:anObject]) return YES;
    else return NO;
}

+ (BOOL)isVariable:(id)anObject
{
    if ([anObject isKindOfClass:[NSString class]] && ![self isOperation:anObject]) return YES;
    else return NO;
}

+ (int)numberOfObjectOperands:(id) anObject
{
    NSSet *operationsWith2Operands = [NSSet setWithObjects:@"+", @"*", @"-", @"/", nil];
    NSSet *operationsWith1Operand = [NSSet setWithObjects:@"sin", @"cos", @"sqrt", @"+ / -", nil];
    
    if ([operationsWith2Operands containsObject:anObject]) return 2;
    else if ([operationsWith1Operand containsObject:anObject]) return 1;
    else return 0;
}

+ (int)objectPrecedence:(id) anObject
{
    NSSet *operationsWithPrecedence2 = [NSSet setWithObjects:@"+", @"-", @"+ / -", nil];
    NSSet *operationsWithPrecedence1 = [NSSet setWithObjects:@"*", @"/", nil];
    
    if ([operationsWithPrecedence2 containsObject:anObject]) return 2;
    else if ([operationsWithPrecedence1 containsObject:anObject]) return 1;
    else if ([anObject isKindOfClass:[NSNumber class]]) return [anObject doubleValue] >= 0 ? 0 : 2;
    else return 0;
}

+ (int)operationIsCommutative:(NSString *) anOperation
{
    NSSet *commutativeOperations = [NSSet setWithObjects:@"+", @"*", nil];
    return [commutativeOperations containsObject:anOperation];
}

    //  Program description methods

    //  Yes, it is longer that it should be, but brackets counting is quite complicated thing

+ (NSString*)descriptionOfTopOfStack:(NSMutableArray*) stack
{
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]] || [self isOperation:topOfStack] || [self isVariable:topOfStack])   //  object is valid
    {
        if ([self numberOfObjectOperands:topOfStack] == 0) {
            return [topOfStack isKindOfClass:[NSNumber class]] ? [NSString stringWithFormat:@"%g", [topOfStack doubleValue]] : topOfStack;
            
        } else if ([topOfStack isEqualToString:@"+ / -"]) {
            int operandPrecedence = [self objectPrecedence:[stack lastObject]];
            NSString *operand = [self descriptionOfTopOfStack:stack];
            return operandPrecedence >= 1 ? [NSString stringWithFormat:@"-(%@)", operand] : [NSString stringWithFormat:@"-%@", operand];
        
        } else if ([self numberOfObjectOperands:topOfStack] == 1) {
            return [NSString stringWithFormat:@"%@(%@)", topOfStack, [self descriptionOfTopOfStack:stack]];
        
        } else if ([self numberOfObjectOperands:topOfStack] == 2) {
            int secondOperandPrecedence = [self objectPrecedence:[stack lastObject]];
            int numberOfSecondObjectOperands = [self numberOfObjectOperands:[stack lastObject]];
            NSString *secondOperand = [self descriptionOfTopOfStack:stack];
            
            int firstOperandPrecedence = [self objectPrecedence:[stack lastObject]];
            NSString *firstOperand = [self descriptionOfTopOfStack:stack];
            
            if (firstOperandPrecedence > [self objectPrecedence:topOfStack]) {  //  example: (2 + 3) * 4
                firstOperand = [NSString stringWithFormat:@"(%@)", firstOperand];
            }
            
            if (secondOperandPrecedence == 2 && numberOfSecondObjectOperands < 2) {   //  "-obj" case
                secondOperand = [NSString stringWithFormat:@"(%@)", secondOperand];
            } else if ([self operationIsCommutative:topOfStack]) {
                if (secondOperandPrecedence > [self objectPrecedence:topOfStack]) {  //  example: 4 * (2 + 3) [but not 4 * 2 * 4]
                    secondOperand = [NSString stringWithFormat:@"(%@)", secondOperand];
                }
            } else {
                if (secondOperandPrecedence >= [self objectPrecedence:topOfStack]) { //  example: 4 / (2 * 3) [4 / 2 * 3 is incorrect]
                    secondOperand = [NSString stringWithFormat:@"(%@)", secondOperand];
                }
            }
            
            return [NSString stringWithFormat:@"%@ %@ %@", firstOperand, topOfStack, secondOperand];
        }
    }
    
    return @"0";
}

    //  There is a contradicion in the assignments:
    //  1. It is required to put '=' on the end of the label [Assignment 1 page 6]
    //  2. It is required to put newer programStack components to the left [Assignment 2 page 3]
    //  So,
    //  1. programDisplay can't be truncated from the left because of (2)
    //  2. programDisplay can't be truncated from the right because of (1)
    //  So, components of description are returned in opposite direction.

+ (NSString*)descriptionOfProgram:(id)program
{    
    NSMutableArray* stack;
    if ([program isKindOfClass:[NSArray class]]) stack = [program mutableCopy];
    
    NSMutableArray *descriptionComponents = [[NSMutableArray alloc] init];
    while ([stack count] != 0) {
        [descriptionComponents insertObject:[self descriptionOfTopOfStack:stack] atIndex:0];
    }
    
    if ([descriptionComponents count]) return [descriptionComponents componentsJoinedByString:@", "];
    else return nil;
}

    //  Program evaluation

+ (double)popOperandOffProgramStack:(NSMutableArray *) stack
{
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        return [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        
        if ([topOfStack isEqualToString:@"+"]) {
            return [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
            
        } else if ([topOfStack isEqualToString:@"*"]) {
            return [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
            
        } else if ([topOfStack isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            return [self popOperandOffProgramStack:stack] - subtrahend;
            
        } else if ([topOfStack isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            double dividend = [self popOperandOffProgramStack:stack];
            if (divisor) return dividend / divisor;
            
        } else if ([topOfStack isEqualToString:@"sin"]) {
            return sin([self popOperandOffProgramStack:stack]);
            
        } else if ([topOfStack isEqualToString:@"cos"]) {
            return cos([self popOperandOffProgramStack:stack]);
            
        } else if ([topOfStack isEqualToString:@"sqrt"]) {
            double operand = [self popOperandOffProgramStack:stack];
            if (operand >= 0) return sqrt(operand);
            
        } else if ([topOfStack isEqualToString:@"π"]) {
            return M_PI;
            
        } else if ([topOfStack isEqualToString:@"+ / -"]) {
            return -[self popOperandOffProgramStack:stack];
        }
    }
    
    return 0;
}

    //  Variable evaluation methods

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{    
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        for (int i = 0; i < [stack count]; i++) if ([self isVariable:[stack objectAtIndex:i]]) {
            [stack replaceObjectAtIndex:i withObject:[variableValues objectForKey:[stack objectAtIndex:i]] ?: [[NSNull alloc] init]];
        }
    }
    return [self popOperandOffProgramStack:stack];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableSet* result = [[NSMutableSet alloc] init];
    if ([program isKindOfClass:[NSArray class]]) {
        for (int i = 0; i < [program count]; i++) if ([self isVariable:[program objectAtIndex:i]]) {
            [result addObject:[program objectAtIndex:i]];
        }
    }
    return [result copy];
}

    //  Instance methods

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

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushVariable:(NSString *)variable
{
    if ([[self class] isVariable:variable]) [self.programStack addObject:variable];
}

- (void)pushOperation:(NSString *)operation
{
    if ([[self class] isOperation:operation]) [self.programStack addObject:operation];
}

- (void)clear
{
    [self.programStack removeAllObjects];
}

- (void)undo
{
    if ([self.programStack count]) [self.programStack removeLastObject];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"stack = %@", self.programStack];
}

@end
