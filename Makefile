SDKVERSION = 10.1
SYSROOT = $(THEOS)/sdks/iPhoneOS10.1.sdk
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MakeRespringsGreatAgain
MakeRespringsGreatAgain_FILES = Tweak.xm
MakeRespringsGreatAgain_PRIVATE_FRAMEWORKS = ProgressUI

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
