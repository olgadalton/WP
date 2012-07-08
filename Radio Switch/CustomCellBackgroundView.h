//
//  CSCustomCellBackgroundView.h
//

#import <UIKit/UIKit.h>

typedef enum  
{
    CustomCellBackgroundViewPositionTop, 
    CustomCellBackgroundViewPositionMiddle, 
    CustomCellBackgroundViewPositionBottom,
    CustomCellBackgroundViewPositionSingle
} CustomCellBackgroundViewPosition;

@interface CustomCellBackgroundView : UIView 
{
    CustomCellBackgroundViewPosition position;
	CGGradientRef gradient;
	UIColor * borderColor;
}

- (id)initWithFrame:(CGRect)frame gradientTop:(UIColor *)gradientTop andBottomColor:(UIColor *)gradientBottom andBorderColor:(UIColor*)borderCol;

@property(nonatomic) CustomCellBackgroundViewPosition position;


@end