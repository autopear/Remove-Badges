#import <UIKit/UIKit.h>
#import "libactivator.h"

@interface SBIconModel
+ (id)sharedInstance; //iOS 4&5
- (id)applicationIconForDisplayIdentifier:(id)displayIdentifier; //iOS 4&5&6&7
- (id)visibleIconIdentifiers; //iOS 4&5&6&7
@end

@interface SBIconViewMap
+ (id)homescreenMap; //iOS 5&6&7
- (id)iconModel; //iOS 6&7
@end

@interface SBIcon
- (void)setBadge:(id)badge; //iOS 5&6&7
- (id)badgeNumberOrString; //iOS 5&6&7
- (int)badgeValue; //iOS 5&6&7
- (id)displayName; //iOS 5&6&7
@end

@interface RemoveBadgesListener : NSObject <LAListener>
@end

#define PreferencesChangedNotification "com.autopear.removebadges/prefs"
#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.autopear.removebadges.plist"]

static NSDictionary *preferences = nil;

static NSString *listenerTitle, *listenerDescription;

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[preferences release];
	preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
}

@implementation RemoveBadgesListener

- (id)init {
	if ((self = [super init])) {
		preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];

		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);

		NSBundle *bundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceLoader/Preferences/RemoveBadges/"];

		listenerTitle =  [NSLocalizedStringFromTableInBundle(@"Remove Badges", @"RemoveBadges", bundle, @"Remove Badges") retain];
		listenerDescription =  [NSLocalizedStringFromTableInBundle(@"Remove all app badges at once", @"RemoveBadges", bundle, @"Remove all app badges at once") retain];

		[bundle release];
	}
	
	return self;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	if ([%c(SBIconModel) respondsToSelector:@selector(sharedInstance)]) {
		//iOS 4 & 5
		SBIconModel *iconModel = (SBIconModel*)[%c(SBIconModel) sharedInstance];
		for (NSString *identifier in [iconModel visibleIconIdentifiers]) {
			if ([[preferences objectForKey:[@"KeepBadge-" stringByAppendingString:identifier]] boolValue])
				continue;

			SBIcon *icon = (SBIcon *)[iconModel applicationIconForDisplayIdentifier:identifier];
			if (icon && [icon badgeNumberOrString]) {
				[icon setBadge:nil];
				NSLog(@"Badge removed: %@ (%@)", [icon displayName], identifier);
			}
		}
	} else if ([%c(SBIconViewMap) respondsToSelector:@selector(homescreenMap)]) {
		//iOS 6 & 7
		for (NSString *identifier in [[[%c(SBIconViewMap) homescreenMap] iconModel] visibleIconIdentifiers]) {
			if ([[preferences objectForKey:[@"KeepBadge-" stringByAppendingString:identifier]] boolValue])
				continue;

			SBIcon *icon = (SBIcon *)[[[%c(SBIconViewMap) homescreenMap] iconModel] applicationIconForDisplayIdentifier:identifier];
			if (icon && [icon badgeNumberOrString]) {
				[icon setBadge:nil];
				NSLog(@"Badge removed: %@ (%@)", [icon displayName], identifier);
			}
		}
	} else {
		//Not implemented
	}
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return listenerTitle;
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return listenerDescription;
}

@end

__attribute__((constructor)) static void BAL_Main() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	RemoveBadgesListener *listener = [[RemoveBadgesListener alloc] init];
	[[LAActivator sharedInstance] registerListener:listener forName:@"com.autopear.removebadges"];
	
	[pool release];
}
