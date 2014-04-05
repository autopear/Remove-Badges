#import <UIKit/UIKit.h>
#import "libactivator.h"

@interface SBIconModel
+ (id)sharedInstance; //iOS 4&5
- (id)applicationIconForDisplayIdentifier:(id)displayIdentifier; //iOS 4&5&6
- (id)visibleIconIdentifiers; //iOS 4&5&6
@end

@interface SBIconViewMap
+ (id)homescreenMap; //iOS 5&6
- (id)iconModel; //iOS 6
@end

@interface SBIcon
- (void)setBadge:(id)badge; //iOS 5&6
- (id)badgeNumberOrString; //iOS 5&6
- (int)badgeValue; //iOS 5&6
- (id)displayName; //iOS 5&6
@end

@interface RemoveBadgesListener : NSObject <LAListener>
@end

@interface RemoveBadgesInclusiveListener : NSObject <LAListener>
@end

@interface RemoveBadgesExclusiveListener : NSObject <LAListener>
@end

#define PreferencesChangedNotification "com.autopear.removebadges/prefs"
#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.autopear.removebadges.plist"]

static NSDictionary *preferences = nil;

static NSString *listenerTitle = nil;
static NSString *listenerDescription = nil;
static NSString *listenerTitleInclusive = nil;
static NSString *listenerDescriptionInclusive = nil;
static NSString *listenerTitleExclusive = nil;
static NSString *listenerDescriptionExclusive = nil;
static UIImage *listenerIcon = nil;

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if (preferences)
        [preferences release];
	preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
}

@implementation RemoveBadgesListener

- (id)init {
	if ((self = [super init])) {
	}
	return self;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	if ([%c(SBIconModel) respondsToSelector:@selector(sharedInstance)]) {
		//iOS 4 & 5
		SBIconModel *iconModel = (SBIconModel*)[%c(SBIconModel) sharedInstance];
		for (NSString *identifier in [iconModel visibleIconIdentifiers]) {
			SBIcon *icon = (SBIcon *)[iconModel applicationIconForDisplayIdentifier:identifier];
			if (icon && [icon badgeNumberOrString]) {
				[icon setBadge:nil];
				NSLog(@"Badge removed: %@ (%@)", [icon displayName], identifier);
			}
		}
	} else if ([%c(SBIconViewMap) respondsToSelector:@selector(homescreenMap)]) {
		//iOS 6
		for (NSString *identifier in [[[%c(SBIconViewMap) homescreenMap] iconModel] visibleIconIdentifiers]) {
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

- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    return listenerIcon;
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    return listenerIcon;
}

@end

@implementation RemoveBadgesInclusiveListener

- (id)init {
	if ((self = [super init])) {
        if (!preferences)
            preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
	return self;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	if ([%c(SBIconModel) respondsToSelector:@selector(sharedInstance)]) {
		//iOS 4 & 5
		SBIconModel *iconModel = (SBIconModel*)[%c(SBIconModel) sharedInstance];
		for (NSString *identifier in [iconModel visibleIconIdentifiers]) {
			if ([[preferences objectForKey:[@"RemoveBadge-" stringByAppendingString:identifier]] boolValue]) {
                SBIcon *icon = (SBIcon *)[iconModel applicationIconForDisplayIdentifier:identifier];
                if (icon && [icon badgeNumberOrString]) {
                    [icon setBadge:nil];
                    NSLog(@"Badge removed: %@ (%@)", [icon displayName], identifier);
                }
            }
		}
	} else if ([%c(SBIconViewMap) respondsToSelector:@selector(homescreenMap)]) {
		//iOS 6
		for (NSString *identifier in [[[%c(SBIconViewMap) homescreenMap] iconModel] visibleIconIdentifiers]) {
			if ([[preferences objectForKey:[@"RemoveBadge-" stringByAppendingString:identifier]] boolValue]) {
                SBIcon *icon = (SBIcon *)[[[%c(SBIconViewMap) homescreenMap] iconModel] applicationIconForDisplayIdentifier:identifier];
                if (icon && [icon badgeNumberOrString]) {
                    [icon setBadge:nil];
                    NSLog(@"Badge removed: %@ (%@)", [icon displayName], identifier);
                }
            }
		}
	} else {
		//Not implemented
	}
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return listenerTitleInclusive;
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return listenerDescriptionInclusive;
}

- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    return listenerIcon;
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    return listenerIcon;
}

@end

@implementation RemoveBadgesExclusiveListener

- (id)init {
	if ((self = [super init])) {
        if (!preferences)
            preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
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
		//iOS 6
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
	return listenerTitleExclusive;
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return listenerDescriptionExclusive;
}

- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    return listenerIcon;
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    return listenerIcon;
}

@end

__attribute__((constructor)) static void BAL_Main() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSBundle *bundle = nil;
	bundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceLoader/Preferences/RemoveBadges/"];

	listenerTitle = [NSLocalizedStringFromTableInBundle(@"Remove Badges", @"RemoveBadges", bundle, @"Remove Badges") retain];
	listenerDescription = [NSLocalizedStringFromTableInBundle(@"Remove all app badges at once", @"RemoveBadges", bundle, @"Remove all app badges at once") retain];

	listenerTitleInclusive = [NSLocalizedStringFromTableInBundle(@"Remove Badges (Inclusive)", @"RemoveBadges", bundle, @"Remove Badges (Inclusive)") retain];
	listenerDescriptionInclusive = [NSLocalizedStringFromTableInBundle(@"Remove all app badges included in the list at once", @"RemoveBadges", bundle, @"Remove all app badges included in the list at once") retain];

	listenerTitleExclusive = [NSLocalizedStringFromTableInBundle(@"Remove Badges (Exclusive)", @"RemoveBadges", bundle, @"Remove Badges (Exclusive)") retain];
	listenerDescriptionExclusive = [NSLocalizedStringFromTableInBundle(@"Remove all app badges excluded in the list at once", @"RemoveBadges", bundle, @"Remove all app badges excluded in the list at once") retain];

    [bundle release];

    if ([UIScreen mainScreen].scale == 2.0f)
        listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon@2x.png"];
    else
        listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon.png"];
    
	RemoveBadgesListener *listener = [[RemoveBadgesListener alloc] init];
	[[LAActivator sharedInstance] registerListener:listener forName:@"com.autopear.removebadges"];

	RemoveBadgesInclusiveListener *listenerInclusive = [[RemoveBadgesInclusiveListener alloc] init];
	[[LAActivator sharedInstance] registerListener:listenerInclusive forName:@"com.autopear.removebadges.inclusive"];

	RemoveBadgesExclusiveListener *listenerExclusive = [[RemoveBadgesExclusiveListener alloc] init];
	[[LAActivator sharedInstance] registerListener:listenerExclusive forName:@"com.autopear.removebadges.exclusive"];

	[pool release];
}