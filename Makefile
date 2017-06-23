CARTHAGE=carthage
BREW=brew
SWIFTGEN=swiftgen

dependencies:
	$(BREW) update
	$(BREW) install swiftgen 

generate:
	$(SWIFTGEN) images -t dot-syntax-swift3 -o Loop/Generated/Assets.swift Loop/Assets.xcassets
	$(SWIFTGEN) storyboards -t swift3 -o Loop/Generated/Storyboards.swift Loop/Base.lproj/Main.storyboard
	$(SWIFTGEN) strings -t dot-syntax-swift3 Loop/Assets/Localizable.strings > Loop/Generated/I10N.swift
