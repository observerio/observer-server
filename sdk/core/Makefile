build.android:
	ANDROID_HOME=~/Library/Android/sdk/ gomobile bind --target=android .
.PHONY: build.android

build.ios:
	gomobile bind --target=android
.PHONY: build.ios

build: build.android
