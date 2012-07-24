//
//  FixedTextField.m
//  Radio Switch
//
//  Created by Olga Dalton on 24/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import "FixedTextField.h"

@implementation FixedTextField

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds 
{
    return CGRectInset( bounds , 10 , 10 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds 
{
    return CGRectInset( bounds , 10 , 10 );
}

@end
