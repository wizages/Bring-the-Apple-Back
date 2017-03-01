SDKVERSION = 9.3
SYSROOT = $(THEOS)/sdks/iPhoneOS9.3.sdk
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MakeRespringsGreatAgain
MakeRespringsGreatAgain_FILES = Tweak.xm
MakeRespringsGreatAgain_PRIVATE_FRAMEWORKS = ProgressUI BackBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
