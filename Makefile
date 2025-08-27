ARCHS = arm64
TARGET = iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = TikTok
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TTTranslateKit

TTTranslateKit_FILES = \
    src-objc/TTTranslate.m \
    src-objc/TTOverlayView.m \
    TTTweak.xm

TTTranslateKit_FRAMEWORKS = Foundation
TTTranslateKit_FRAMEWORKS += CFNetwork
TTTranslateKit_FRAMEWORKS += UIKit
TTTranslateKit_CFLAGS += -fobjc-arc
TTTranslateKit_LDFLAGS += -ObjC

ifeq ($(DEBUG),1)
  TTTranslateKit_CFLAGS += -DTT_DEBUG=1
endif

include $(THEOS_MAKE_PATH)/tweak.mk
