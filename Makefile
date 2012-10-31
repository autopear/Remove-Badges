include theos/makefiles/common.mk

TWEAK_NAME = RemoveBadges
RemoveBadges_FILES = Tweak.xm
RemoveBadges_FRAMEWORKS = Foundation UIKit
RemoveBadges_LDFLAGS = -lactivator -Llib/

include $(FW_MAKEDIR)/tweak.mk
