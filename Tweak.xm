#import "important.h"
#import <spawn.h>

@interface _UIStatusBarStringView : UIView
@property (copy) NSString *text;
@property NSInteger numberOfLines;
@property (copy) UIFont *font;
@property NSInteger textAlignment;
+ (id)sharedInstance;
@end


@interface PCSimpleTimer : NSObject
@property BOOL disableSystemWaking;
- (BOOL)disableSystemWaking;
- (id)initWithFireDate:(id)arg1 serviceIdentifier:(id)arg2 target:(id)arg3 selector:(SEL)arg4 userInfo:(id)arg5;
- (id)initWithTimeInterval:(double)arg1 serviceIdentifier:(id)arg2 target:(id)arg3 selector:(SEL)arg4 userInfo:(id)arg5;
- (void)invalidate;
- (BOOL)isValid;
- (void)scheduleInRunLoop:(id)arg1;
- (void)setDisableSystemWaking:(BOOL)arg1;
- (id)userInfo;
@end

@interface _UIStatusBarBackgroundActivityView : UIView
@property (copy) CALayer *pulseLayer;
@end

#define udtTimerPlist @"/private/var/mobile/Library/Preferences/com.mpg13.udtTimer.plist"
static PCSimpleTimer *udtTimer = nil;

static void udtTimerLoad();





int sizeOfFont = GetPrefInt(@"sizeOfFont");

NSString *lineTwo = GetPrefString(@"lineTwo");
NSString *lineOne = GetPrefString(@"lineOne");
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];



@interface _UIStatusBarTimeItem
@property (copy) _UIStatusBarStringView *shortTimeView;
@property (copy) _UIStatusBarStringView *pillTimeView;
@end


%group SPRINGBOARD
%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application
{
	%orig;

	NSLog(@"[udtTimer] SpringBoard applicationDidFinishLaunching");
	udtTimerLoad();
}
%end

%hook _UIStatusBarStringView

- (void)udtTimerFired:(NSString *)text {
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
%end
%group STATUSTIME

/*
%hook _UIStatusBarTimeItem
- (void)udtTimerFired{
	if (udtTimer) {
		
		NSLog(@"[udtTimer] udtTimerFired");
		
		self.shortTimeView.text = @":";
		self.pillTimeView.text = @":";
		[self.shortTimeView setFont: [self.shortTimeView.font fontWithSize:sizeOfFont]];
		[self.pillTimeView setFont: [self.pillTimeView.font fontWithSize:sizeOfFont]];

		[udtTimer invalidate];
		udtTimer = nil;
}}
%end


%hook _UIStatusBarTimeItem
%property (nonatomic, retain) NSTimer *nz9_seconds_timer;

- (instancetype)init {
	%orig;
	self.shortTimeView.text = @":";
	self.pillTimeView.text = @":";
	self.shortTimeView.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightBold];
	self.pillTimeView.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightBold];
	return self;
}

- (id)applyUpdate:(id)arg1 toDisplayItem:(id)arg2 {
	id returnThis = %orig;
	self.shortTimeView.text = @":";
	self.pillTimeView.text = @":";
	self.shortTimeView.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightBold];
	self.pillTimeView.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightBold];
	return returnThis;
}

%end*/


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
%end

static void udtTimerLoad(){
	NSDictionary *userInfoDictionary = nil;
	userInfoDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:udtTimerPlist];
	
	if (!userInfoDictionary) {
		return;
	}
	
	NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
	
	udtTimer = [[%c(PCSimpleTimer) alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:1] serviceIdentifier:@"com.mpg13.UnderTime" target:[%c(_UIStatusBarStringView) sharedInstance] selector:@selector(udtTimerFired) userInfo:data];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
	[formatter setTimeZone:[NSTimeZone defaultTimeZone]];
	
	if ([NSThread isMainThread]) {
		[udtTimer scheduleInRunLoop:[NSRunLoop mainRunLoop]];
	} else {
		dispatch_async(dispatch_get_main_queue(), ^ {
			[udtTimer scheduleInRunLoop:[NSRunLoop mainRunLoop]];
		});
	}

}
	
	




/*
%ctor {
	dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterNoStyle;
	dateFormatter.timeStyle = NSDateFormatterMediumStyle;
	dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	%init;
}*/

%ctor{
	@autoreleasepool {
		if (%c(SpringBoard)) {
			%init(SPRINGBOARD);
		} else {
			%init(STATUSTIME);
		}
	}
}