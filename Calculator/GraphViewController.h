//
//  GraphViewController.h
//  Calculator
//
//  Created by Maxim Piskunov on 13.07.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

@interface GraphViewController : UIViewController

@property (strong, nonatomic) id program;
@property (weak, nonatomic) IBOutlet GraphView *graphDisplay;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *programDisplay;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end
