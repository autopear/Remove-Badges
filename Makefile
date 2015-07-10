export ARCHS = armv7 armv7s arm64
export TARGET=iphone:8.4:4.0

include theos/makefiles/common.mk

TWEAK_NAME = RemoveBadges
RemoveBadges_FILES = Tweak.xm
RemoveBadges_FRAMEWORKS = Foundation UIKit
RemoveBadges_LDFLAGS = -lactivator

include $(FW_MAKEDIR)/tweak.mk

before-package::
	find _ -name "*.plist" -exec plutil -convert binary1 {} \;
	find _ -name "*.strings" -exec chmod 0644 {} \;
	find _ -name "*.png" -exec chmod 0644 {} \;
	find _ -name "*.plist" -exec chmod 0644 {} \;
	find _ -exec touch -r _/Library/MobileSubstrate/DynamicLibraries/RemoveBadges.dylib {} \;

after-package::
	rm -fr .theos/packages/*
