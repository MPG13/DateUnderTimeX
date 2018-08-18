#import "important.h"
#import <spawn.h>

@interface UIColor (fromHex)
+ (UIColor *)colorwithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
@end

@interface _UIStatusBarStringView : UIView
@property (copy) NSString *text;
@property NSInteger numberOfLines;
@property (copy) UIFont *font;
@property (copy) UIColor *color;
@property NSInteger textAlignment;
@end

@interface _UIStatusBarBackgroundActivityView : UIView
@property (copy) CALayer *pulseLayer;
@end

@interface _UIStatusBarTimeItem : UIView
@property (copy) _UIStatusBarStringView *shortTimeView;
@property (copy) _UIStatusBarStringView *pillTimeView;
@property (nonatomic, retain) NSTimer *nz9_seconds_timer;
@end

@implementation UIColor (fromHex)
 
+ (UIColor *)colorwithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
{
	//-----------------------------------------
	// Convert hex string to an integer
	//-----------------------------------------
	unsigned int hexint = 0;
 
	// Create scanner
	NSScanner *scanner = [NSScanner scannerWithString:hexStr];
 
	// Tell scanner to skip the # character
	[scanner setCharactersToBeSkipped:[NSCharacterSet 
		characterSetWithCharactersInString:@"#"]];
	[scanner scanHexInt:&hexint];
 
	//-----------------------------------------
	// Create color object, specifying alpha
	//-----------------------------------------
	UIColor *color =
		[UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
		green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
		blue:((CGFloat) (hexint & 0xFF))/255
		alpha:alpha];
 
	return color;
}
 
@end

int sizeOfFont = GetPrefInt(@"sizeOfFont");
int fontAlpha = GetPrefInt(@"fontAlpha");
NSString *fontColor = GetPrefString(@"fontHex");
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

%hook _UIStatusBarStringView

- (void)setText:(NSString *)text {
	if(GetPrefBool(@"Enable") && [text containsString:@":"]) {
		NSString *lineOne = GetPrefString(@"lineOne");
		NSString *lineTwo = GetPrefString(@"lineTwo");
		NSString *timeLineOne = lineOne;
		NSString *timeLineTwo = lineTwo;
	
		NSDate *now = [NSDate date];
		if(!GetPrefBool(@"lineTwoStandard")){
			[dateFormatter setDateFormat:lineTwo];
			timeLineTwo = [dateFormatter stringFromDate:now];
			timeLineTwo = [timeLineTwo substringToIndex:[timeLineTwo length]];
		}
		if(!GetPrefBool(@"lineOneStandard")){
			[dateFormatter setDateFormat:lineOne];
			timeLineOne = [dateFormatter stringFromDate:now];
			timeLineOne = [timeLineOne substringToIndex:[timeLineOne length]];
		}
		NSString *newString;
		if(GetPrefBool(@"lineOneEnable")){
			newString = [NSString stringWithFormat:@"%@\n%@", timeLineOne, timeLineTwo];
		}
		else{
			newString = [NSString stringWithFormat:@"%@\n%@", text, timeLineTwo];
		}
		[self setFont: [self.font fontWithSize:sizeOfFont]];
		if((fontColor) && (fontAlpha) && (GetPrefBool(@"customColor"))){
			[self setColor:[UIColor colorwithHexString:fontColor alpha:fontAlpha]];
		}
		if(GetPrefBool(@"replaceTime")){
			%orig(timeLineOne);
		}
		else{
			self.textAlignment = 1;
			self.numberOfLines = 2;
			%orig(newString);
		}
	}
	else {
		%orig(text);
	}
}
%end

%hook _UIStatusBarTimeItem
%property (nonatomic, retain) NSTimer *nz9_seconds_timer;

- (instancetype)init {
	%orig;
		if(GetPrefBool(@"Enable") && GetPrefBool(@"hasSeconds")) {
			self.nz9_seconds_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *timer) {
				self.shortTimeView.text = @":";
				self.pillTimeView.text = @":";
				[self.shortTimeView setFont: [self.shortTimeView.font fontWithSize:sizeOfFont]];
				[self.pillTimeView setFont: [self.pillTimeView.font fontWithSize:sizeOfFont]];
			}];
		}
		return self;
}

- (id)applyUpdate:(id)arg1 toDisplayItem:(id)arg2 {
	id returnThis = %orig;
	[self.shortTimeView setFont: [self.shortTimeView.font fontWithSize:sizeOfFont]];
	[self.pillTimeView setFont: [self.pillTimeView.font fontWithSize:sizeOfFont]];
	return returnThis;

}

%end


%hook _UIStatusBarBackgroundActivityView

- (void)setCenter:(CGPoint)point {
	if(GetPrefBool(@"Enable") && !GetPrefBool(@"replaceTime")){
			point.y = 11;
			self.frame = CGRectMake(0, 0, self.frame.size.width, 31);
			self.pulseLayer.frame = CGRectMake(0, 0, self.frame.size.width, 31);
			%orig(point);
	}

}

%end

%hook _UIStatusBarIndicatorLocationItem

- (id)applyUpdate:(id)arg1 toDisplayItem:(id)arg2 {
	return nil;
}

%end

%ctor {
	dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterNoStyle;
	dateFormatter.timeStyle = NSDateFormatterMediumStyle;
	dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
}