#import "important.h"
#import <spawn.h>
#import <PersistentConnection/PCSimpleTimer.h>

@interface _UIStatusBarStringView : UIView
@property (copy) NSString *text;
@property NSInteger numberOfLines;
@property (copy) UIFont *font;
@property NSInteger textAlignment;
@end

int sizeOfFont = GetPrefInt(@"sizeOfFont");

NSString *lineTwo = GetPrefString(@"lineTwo");
NSString *lineOne = GetPrefString(@"lineOne");
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

%hook _UIStatusBarStringView

- (void)setText:(NSString *)text {
	if(GetPrefBool(@"Enable") && ![text containsString:@"%"] && ![text containsString:@"1x"] && ![text containsString:@"LTE"] && ![text containsString:@"4G"] && ![text containsString:@"3G"] && ![text containsString:@"2G"] && ![text containsString:@"EDGE"]) {

		NSString *timeLineTwo = lineTwo;
		NSString *timeLineOne = lineOne;
		
		
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

@interface _UIStatusBarTimeItem : UIView
@property (copy) _UIStatusBarStringView *shortTimeView;
@property (copy) _UIStatusBarStringView *pillTimeView;
@property (nonatomic) PCSimpleTimer *nz9_seconds_timer;
@end
	
%hook _UIStatusBarTimeItem
%property (nonatomic, retain) PCSimpleTimer *nz9_seconds_timer;

- (instancetype)init {
	%orig;
	if(GetPrefBool(@"Enable") && ((!GetPrefBool(@"lineTwoStandard") && [lineTwo containsString:@"s"]) || (!GetPrefBool(@"lineOneStandard") && [lineOne containsString:@"s"]))) {
		self.nz9_seconds_timer = [PCSimpleTimer initWithTimerInterval:1.0 block:^(PCSimpleTimer *timer) {
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


@interface _UIStatusBarBackgroundActivityView : UIView
@property (copy) CALayer *pulseLayer;
@end

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
	%init;
}
