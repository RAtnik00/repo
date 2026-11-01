TARGET := iphone:clang:16.5:14.0
ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless
INSTALL_TARGET_PROCESSES = Preferences
include $(THEOS)/makefiles/common.mk
TWEAK_NAME = ZoneLocalization
ZoneLocalization_FILES = Tweak.xm
ZoneLocalization_CFLAGS = -fobjc-arc -fmodules-cache-path=$(THEOS_PROJECT_DIR)/.module-cache
ZoneLocalization_FRAMEWORKS = UIKit
include $(THEOS_MAKE_PATH)/tweak.mk
