# Zone 2.0.0 — multilingual community translation

**Original author:** iosdumpzzz (iosdump).

**Translation and runtime localization:** RAtnik00. This is an unofficial text translation only. It does not claim authorship of Zone. The original `ZonePrefs` and `Zone` executable binaries are unchanged. Upstream package repository: [iosdumpzzz/iosdump.repo](https://github.com/iosdumpzzz/iosdump.repo).

English, Russian, and Ukrainian tables cover all 127 UTF-16 string constants extracted from the supplied `ZonePrefs` binary. A runtime hook translates hard-coded labels, explanatory text, menus, alerts, editing actions, and formatted count/name strings according to the device language. Static Settings labels use `Root.strings`; runtime hook source and build files are in `runtime/`.

Installable packages are provided for `iphoneos-arm`, `iphoneos-arm64`, and `iphoneos-arm64e`. Some text supplied directly by iOS may continue to follow the system language. The updated package compiled successfully and its contents were checked, but it has not yet been tested on a physical device.
