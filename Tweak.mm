#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>

#define PreferencesChangedNotification "com.autopear.removebadges/prefs"
#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.autopear.removebadges.plist"]

@interface SBIconModel : NSObject
+ (id)sharedInstance; //iOS 4-7
- (id)applicationIconForDisplayIdentifier:(id)displayIdentifier; //iOS 4-7
- (id)visibleIconIdentifiers; //iOS 4-7
- (id)applicationIconForBundleIdentifier:(id)bundleIdentifier; //iOS 8
@end

@interface SBIconViewMap : NSObject
+ (id)homescreenMap; //iOS 5-9.2
- (id)iconModel; //iOS 6
@end

@interface SBIcon : NSObject
- (void)setBadge:(id)badge; //iOS 5&6
- (id)badgeNumberOrString; //iOS 5&6
- (int)badgeValue; //iOS 5&6
- (id)displayName; //iOS 5&6
- (id)displayNameForLocation:(int)location; //iOS 8.4
@end

@interface SBIconController : UIViewController
+(id)sharedInstance;
-(SBIconViewMap *)homescreenIconViewMap; //New in 9.3
@end

@interface RemoveBadgesListener : NSObject <LAListener>
@end

@interface RemoveBadgesInclusiveListener : NSObject <LAListener>
@end

@interface RemoveBadgesExclusiveListener : NSObject <LAListener>
@end

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
        //iOS 6+
        SBIconModel *iconModel = (SBIconModel *)[[%c(SBIconViewMap) homescreenMap] iconModel];
        for (NSString *identifier in [iconModel visibleIconIdentifiers]) {
            SBIcon *icon = nil;
            if ([iconModel respondsToSelector:@selector(applicationIconForDisplayIdentifier:)])
                icon = (SBIcon *)[iconModel applicationIconForDisplayIdentifier:identifier];
            else if ([iconModel respondsToSelector:@selector(applicationIconForBundleIdentifier:)])
                icon = (SBIcon *)[iconModel applicationIconForBundleIdentifier:identifier];
            else
                return;
            if (icon && [icon badgeNumberOrString]) {
                [icon setBadge:nil];
                if ([icon respondsToSelector:@selector(displayName)])
                    NSLog(@"Badge removed: %@ (%@)", [icon displayName], identifier);
                else
                    NSLog(@"Badge removed: %@ (%@)", [icon displayNameForLocation:0], identifier);
            }
        }
    } else {
        SBIconController *iconCtrl = [%c(SBIconController) sharedInstance];
        if ([iconCtrl respondsToSelector:@selector(homescreenIconViewMap)]) {
            //iOS 9.3
            SBIconModel *iconModel = (SBIconModel *)[[iconCtrl homescreenIconViewMap] iconModel];
            for (NSString *identifier in [iconModel visibleIconIdentifiers]) {
                SBIcon *icon = (SBIcon *)[iconModel applicationIconForBundleIdentifier:identifier];
                if (icon && [icon badgeNumberOrString]) {
                    [icon setBadge:nil];
                    NSLog(@"Badge removed: %@ (%@)", [icon displayNameForLocation:0], identifier);
                }
            }
        }
    }
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return listenerTitle;
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return listenerDescription;
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return listenerTitle;
}

- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    if (!listenerIcon) {
        if (scale == 2.0f)
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon@2x.png"];
        else if (scale == 3.0f)
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon@3x.png"];
        else
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon.png"];
    }

    return listenerIcon;
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    if (!listenerIcon) {
        if (scale == 2.0f)
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon@2x.png"];
        else if (scale == 3.0f)
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon@3x.png"];
        else
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon.png"];
    }
    return listenerIcon;
}

@end

@implementation RemoveBadgesInclusiveListener

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
            if ([[preferences objectForKey:[@"RemoveBadge-" stringByAppendingString:identifier]] boolValue]) {
                SBIcon *icon = (SBIcon *)[iconModel applicationIconForDisplayIdentifier:identifier];
                if (icon && [icon badgeNumberOrString]) {
                    [icon setBadge:nil];
                    NSLog(@"Badge removed: %@ (%@)", [icon displayName], identifier);
                }
            }
        }
    } else if ([%c(SBIconViewMap) respondsToSelector:@selector(homescreenMap)]) {
        //iOS 6+
        SBIconModel *iconModel = (SBIconModel *)[[%c(SBIconViewMap) homescreenMap] iconModel];
        for (NSString *identifier in [iconModel visibleIconIdentifiers]) {
            if ([[preferences objectForKey:[@"RemoveBadge-" stringByAppendingString:identifier]] boolValue]) {
                SBIcon *icon = nil;
                if ([iconModel respondsToSelector:@selector(applicationIconForDisplayIdentifier:)])
                    icon = (SBIcon *)[iconModel applicationIconForDisplayIdentifier:identifier];
                else if ([iconModel respondsToSelector:@selector(applicationIconForBundleIdentifier:)])
                    icon = (SBIcon *)[iconModel applicationIconForBundleIdentifier:identifier];
                else
                    return;
                if (icon && [icon badgeNumberOrString]) {
                    [icon setBadge:nil];
                    if ([icon respondsToSelector:@selector(displayName)])
                        NSLog(@"Badge removed: %@ (%@)", [icon displayName], identifier);
                    else
                        NSLog(@"Badge removed: %@ (%@)", [icon displayNameForLocation:0], identifier);
                }
            }
        }
    } else {
        SBIconController *iconCtrl = [%c(SBIconController) sharedInstance];
        if ([iconCtrl respondsToSelector:@selector(homescreenIconViewMap)]) {
            //iOS 9.3
            SBIconModel *iconModel = (SBIconModel *)[[iconCtrl homescreenIconViewMap] iconModel];
            for (NSString *identifier in [iconModel visibleIconIdentifiers]) {
                if ([[preferences objectForKey:[@"RemoveBadge-" stringByAppendingString:identifier]] boolValue]) {
                    SBIcon *icon = (SBIcon *)[iconModel applicationIconForBundleIdentifier:identifier];
                    if (icon && [icon badgeNumberOrString]) {
                        [icon setBadge:nil];
                        NSLog(@"Badge removed: %@ (%@)", [icon displayNameForLocation:0], identifier);
                    }
                }
            }
        }
    }
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return listenerTitleInclusive;
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return listenerDescriptionInclusive;
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return listenerTitle;
}

- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    if (!listenerIcon) {
        if (scale == 2.0f)
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon@2x.png"];
        else if (scale == 3.0f)
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon@3x.png"];
        else
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon.png"];
    }
    return listenerIcon;
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    if (!listenerIcon) {
        if (scale == 2.0f)
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon@2x.png"];
        else if (scale == 3.0f)
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon@3x.png"];
        else
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon.png"];
    }
    return listenerIcon;
}

@end

@implementation RemoveBadgesExclusiveListener

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
            if ([[preferences objectForKey:[@"KeepBadge-" stringByAppendingString:identifier]] boolValue])
                continue;

            SBIcon *icon = (SBIcon *)[iconModel applicationIconForDisplayIdentifier:identifier];
            if (icon && [icon badgeNumberOrString]) {
                [icon setBadge:nil];
                NSLog(@"Badge removed: %@ (%@)", [icon displayName], identifier);
            }
        }
    } else if ([%c(SBIconViewMap) respondsToSelector:@selector(homescreenMap)]) {
        //iOS 6+
        SBIconModel *iconModel = (SBIconModel *)[[%c(SBIconViewMap) homescreenMap] iconModel];
        for (NSString *identifier in [iconModel visibleIconIdentifiers]) {
            if ([[preferences objectForKey:[@"KeepBadge-" stringByAppendingString:identifier]] boolValue])
                continue;

            SBIcon *icon = nil;
            if ([iconModel respondsToSelector:@selector(applicationIconForDisplayIdentifier:)])
                icon = (SBIcon *)[iconModel applicationIconForDisplayIdentifier:identifier];
            else if ([iconModel respondsToSelector:@selector(applicationIconForBundleIdentifier:)])
                icon = (SBIcon *)[iconModel applicationIconForBundleIdentifier:identifier];
            else
                return;

            if (icon && [icon badgeNumberOrString]) {
                [icon setBadge:nil];
                if ([icon respondsToSelector:@selector(displayName)])
                    NSLog(@"Badge removed: %@ (%@)", [icon displayName], identifier);
                else
                    NSLog(@"Badge removed: %@ (%@)", [icon displayNameForLocation:0], identifier);
            }
        }
    } else {
        SBIconController *iconCtrl = [%c(SBIconController) sharedInstance];
        if ([iconCtrl respondsToSelector:@selector(homescreenIconViewMap)]) {
            //iOS 9.3
            SBIconModel *iconModel = (SBIconModel *)[[iconCtrl homescreenIconViewMap] iconModel];
            for (NSString *identifier in [iconModel visibleIconIdentifiers]) {
                if ([[preferences objectForKey:[@"KeepBadge-" stringByAppendingString:identifier]] boolValue])
                    continue;

                SBIcon *icon = (SBIcon *)[iconModel applicationIconForBundleIdentifier:identifier];
                if (icon && [icon badgeNumberOrString]) {
                    [icon setBadge:nil];
                    NSLog(@"Badge removed: %@ (%@)", [icon displayNameForLocation:0], identifier);
                }
            }
        }
    }
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return listenerTitleExclusive;
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return listenerDescriptionExclusive;
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return listenerTitle;
}

- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    if (!listenerIcon) {
        if (scale == 2.0f)
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon@2x.png"];
        else if (scale == 3.0f)
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon@3x.png"];
        else
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon.png"];
    }
    return listenerIcon;
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    if (!listenerIcon) {
        if (scale == 2.0f)
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon@2x.png"];
        else if (scale == 3.0f)
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon@3x.png"];
        else
            listenerIcon = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceLoader/Preferences/RemoveBadges/icon.png"];
    }
    return listenerIcon;
}

@end

__attribute__((constructor)) static void BAL_Main() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSBundle *bundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceLoader/Preferences/RemoveBadges"];

    listenerTitle = [NSLocalizedStringFromTableInBundle(@"Remove Badges", @"RemoveBadges", bundle, @"Remove Badges") retain];
    listenerDescription = [NSLocalizedStringFromTableInBundle(@"Remove all app badges at once", @"RemoveBadges", bundle, @"Remove all app badges at once") retain];

    listenerTitleInclusive = [NSLocalizedStringFromTableInBundle(@"Remove Badges (Inclusive)", @"RemoveBadges", bundle, @"Remove Badges (Inclusive)") retain];
    listenerDescriptionInclusive = [NSLocalizedStringFromTableInBundle(@"Remove all app badges included in the list at once", @"RemoveBadges", bundle, @"Remove all app badges included in the list at once") retain];

    listenerTitleExclusive = [NSLocalizedStringFromTableInBundle(@"Remove Badges (Exclusive)", @"RemoveBadges", bundle, @"Remove Badges (Exclusive)") retain];
    listenerDescriptionExclusive = [NSLocalizedStringFromTableInBundle(@"Remove all app badges excluded in the list at once", @"RemoveBadges", bundle, @"Remove all app badges excluded in the list at once") retain];

    [bundle release];

    preferences = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);

    RemoveBadgesListener *listener = [[RemoveBadgesListener alloc] init];
    [[LAActivator sharedInstance] registerListener:listener forName:@"com.autopear.removebadges"];

    RemoveBadgesInclusiveListener *listenerInclusive = [[RemoveBadgesInclusiveListener alloc] init];
    [[LAActivator sharedInstance] registerListener:listenerInclusive forName:@"com.autopear.removebadges.inclusive"];

    RemoveBadgesExclusiveListener *listenerExclusive = [[RemoveBadgesExclusiveListener alloc] init];
    [[LAActivator sharedInstance] registerListener:listenerExclusive forName:@"com.autopear.removebadges.exclusive"];

    [pool release];
}