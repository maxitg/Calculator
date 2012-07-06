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

+ (BOOL)isOperation:(NSString *) aString
{
    if ([[self arrayOfOperations] containsObject:aString]) return YES;
    else return NO;
}

+ (NSArray *)arrayOfOperations
{
    return [NSArray arrayWithObjects:@"+", @"*", @"-", @"/", @"sin", @"cos", @"sqrt", @"π", @"+ / -", nil];
}

+ (int)numberOfOperationOperands:(NSString *) anOperation
{
    if (![self isOperation:anOperation]) return 0;
    NSArray* operations = [self arrayOfOperations];
    NSArray* numbersOfOperands = [NSArray arrayWithObjects:
                                  [NSNumber numberWithInt:2],   //  +
                                  [NSNumber numberWithInt:2],   //  *
                                  [NSNumber numberWithInt:2],   //  -
                                  [NSNumber numberWithInt:2],   //  /
                                  [NSNumber numberWithInt:1],   //  sin
                                  [NSNumber numberWithInt:1],   //  cos
                                  [NSNumber numberWithInt:1],   //  sqrt
                                  [NSNumber numberWithInt:0],   //  π
                                  [NSNumber numberWithInt:1],   //  + / -
                                  nil];
    return [[[NSDictionary dictionaryWithObjects:numbersOfOperands forKeys:operations] valueForKey:anOperation] intValue];
}

    //  Lower precedence means this operation should be evaluated first

+ (int)objectPrecedence:(NSString *) anOperation
{
    if ([anOperation isKindOfClass:[NSNumber class]]) {
        if ([anOperation doubleValue] < 0) return 3;
        else return 0;
    } else if ([self isOperation:anOperation]) {
        NSArray* operations = [self arrayOfOperations];
        NSArray* precedences = [NSArray arrayWithObjects:
                                [NSNumber numberWithInt:2], //  +
                                [NSNumber numberWithInt:1], //  *
                                [NSNumber numberWithInt:2], //  -
                                [NSNumber numberWithInt:1], //  /
                                [NSNumber numberWithInt:0], //  sin
                                [NSNumber numberWithInt:0], //  cos
                                [NSNumber numberWithInt:0], //  sqrt
                                [NSNumber numberWithInt:0], //  π
                                [NSNumber numberWithInt:3]  //  + / -
                                , nil];
        return [[[NSDictionary dictionaryWithObjects:precedences forKeys:operations] valueForKey:anOperation] intValue];
    } else {
        return 0;
    }
}

+ (int)operationIsCommutative:(NSString *) anOperation
{
    NSSet* commutativeOperations = [NSSet setWithObjects:@"+", @"*", nil];
    return [commutativeOperations containsObject:anOperation];
}

+ (NSString*)descriptionOfTopOfStack:(NSMutableArray*) stack
{
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%g", [topOfStack doubleValue]];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        
        if ([topOfStack isEqualToString:@"+ / -"]) {    //  it is a spectial case
            int operandPrecedence = [self objectPrecedence:[stack lastObject]];
            NSString* operand = [self descriptionOfTopOfStack:stack];
            if (operandPrecedence > 0) {
                operand = [NSString stringWithFormat:@"(%@)", operand];
            }
            
            return [NSString stringWithFormat:@"-%@", operand];
        }
        
        else if ([self numberOfOperationOperands:topOfStack] == 0) {
            return topOfStack;
            
        } else if ([self numberOfOperationOperands:topOfStack] == 1) {
            return [NSString stringWithFormat:@"%@(%@)", topOfStack, [self descriptionOfTopOfStack:stack]];

        } else if ([self numberOfOperationOperands:topOfStack] == 2) {
            int secondOperandPrecedence = [self objectPrecedence:[stack lastObject]];
            NSString* secondOperand = [self descriptionOfTopOfStack:stack];
            int firstOperandPrecedence = [self objectPrecedence:[stack lastObject]];
            
            BOOL firstOperandIsMinusSomething = NO;
            if ([self objectPrecedence:[stack lastObject]] == 3) firstOperandIsMinusSomething = YES;
            
            NSString* firstOperand = [self descriptionOfTopOfStack:stack];
            
            if (!(firstOperandIsMinusSomething && ([self objectPrecedence:topOfStack] == 2)) &&  //  filterning out + / - case
                (firstOperandPrecedence > [self objectPrecedence:topOfStack])) {   //  example: (2 + 3) * 4
                firstOperand = [NSString stringWithFormat:@"(%@)", firstOperand];
            }
            
            if ([self operationIsCommutative:topOfStack]) {
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

+ (NSString*)descriptionOfProgram:(id)program
{
    if ([program count] == 0) return nil;
    NSMutableArray* stack;
    if ([program isKindOfClass:[NSArray class]]) stack = [program mutableCopy];
    
    NSString *description = [self descriptionOfTopOfStack:stack];
    while ([stack count] != 0) {
        description = [[self descriptionOfTopOfStack:stack] stringByAppendingFormat:@", %@", description];  //  the elements appear in the description in the other order, then in the assignemnt. This is by design. This order is much more user friendly.
    }
    
    return description;
}

- (NSString*)currentProgramDescription
{
    return [[self class] descriptionOfProgram:self.program];
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
    NSLog(@"%@", [[self class] descriptionOfProgram:self.program]);
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    NSLog(@"%@", [[self class] descriptionOfProgram:self.program]);
    return [[self class] runProgram:self.program];
}

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
    NSSet* result = [NSSet setWithArray:[program objectsAtIndexes:[self variableIndexesInProgram:program]]];
    if ([result count] > 0) return result;
    else return nil;
}

- (void)clear
{
    [self.programStack removeAllObjects];
    NSLog(@"%@", [[self class] descriptionOfProgram:[self program]]);
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"stack = %@", self.programStack];
}

@end
