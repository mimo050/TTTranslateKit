ARCHS = arm64
TARGET = iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = TikTok

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TTTranslateKit

TTTranslateKit_FILES = \
    src-objc/TTTranslate.m \
    src-objc/TTOverlayView.m \
    TTTweak.xm

TTTranslateKit_FRAMEWORKS = UIKit Foundation
TTTranslateKit_FRAMEWORKS += CFNetwork
TTTranslateKit_CFLAGS += -fobjc-arc
TTTranslateKit_LDFLAGS += -ObjC

include $(THEOS_MAKE_PATH)/tweak.mk
