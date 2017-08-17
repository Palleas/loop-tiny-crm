CARTHAGE=carthage
BREW=brew
SWIFTGEN=swiftgen
SOURCERY=sourcery

dependencies:
	$(BREW) update
	$(BREW) install swiftgen || $(BREW) upgrade swiftgen || true
	$(BREW) install sourcery || $(BREW) upgrade sourcery || true

generate:
	$(SWIFTGEN) xcassets -t swift3 -o Loop/Generated/Assets.swift Loop/Assets.xcassets
	$(SWIFTGEN) colors -t swift3 -o Loop/Generated/Colors.swift Design/LoopStyleguide.clr
	$(SWIFTGEN) storyboards -t swift3 -o Loop/Generated/Storyboards.swift Loop/Base.lproj/Main.storyboard
	$(SWIFTGEN) strings -t structured-swift3 Loop/Assets/Localizable.strings > Loop/Generated/I10N.swift
	$(SWIFTGEN) fonts -o Loop/Generated/Fonts.swift -t swift3 Loop/Assets/Fonts
	$(SOURCERY)
