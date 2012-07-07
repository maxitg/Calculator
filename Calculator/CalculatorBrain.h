//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Maxim Piskunov on 29.06.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)pushVariable:(NSString *)variable;
- (void)pushOperation:(NSString *)operation;
- (void)undo;
- (void)clear;

@property (nonatomic, readonly) id program;

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSString*)descriptionOfProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end
