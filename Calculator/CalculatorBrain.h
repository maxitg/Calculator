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
- (double)performOperation:(NSString *)operation;
- (void)clear;

@property (nonatomic, readonly) id program;

+ (NSString*)descriptionOfProgram:(id)program;

+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;

@end
