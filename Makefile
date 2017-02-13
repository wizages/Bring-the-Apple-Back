SDKVERSION = 10.1
SYSROOT = $(THEOS)/sdks/iPhoneOS10.1.sdk
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BringTheAppleBack
BringTheAppleBack_FILES = Tweak.xm
BringTheAppleBack_PRIVATE_FRAMEWORKS = ProgressUI

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
