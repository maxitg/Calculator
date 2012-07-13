//
//  GraphView.h
//  Calculator
//
//  Created by Maxim Piskunov on 13.07.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIkit.h>

@protocol GraphViewDataSource
- (float)functionValueForX:(float)x;
@end

@interface GraphView : UIView

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;
@property (nonatomic) CGFloat scale;    //  1.0 means show plot from -1 to 1
@property (nonatomic) CGPoint origin;

@end
