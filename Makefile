export TARGET=iphone:5.0:4.0
export ARCHS = armv6

include theos/makefiles/common.mk

TWEAK_NAME = RemoveBadges
RemoveBadges_FILES = Tweak.xm
RemoveBadges_FRAMEWORKS = Foundation UIKit
RemoveBadges_LDFLAGS = -lactivator -Llib/

TARGET_IPHONEOS_DEPLOYMENT_VERSION = 4.0

include $(FW_MAKEDIR)/tweak.mk
