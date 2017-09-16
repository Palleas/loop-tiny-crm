CARTHAGE=carthage
SWIFTLINT=swiftlint
BREW=brew
SWIFTGEN=swiftgen
SOURCERY=sourcery

dependencies:
	@$(BREW) update > /dev/null
	@$(BREW) install swiftgen || $(BREW) upgrade swiftgen || true
	@$(BREW) install sourcery || $(BREW) upgrade sourcery || true

generate:
	@echo "Generate assets..."
	@$(SWIFTGEN) xcassets -t swift3 -o Loop/Generated/Assets.swift Loop/Assets.xcassets
	@echo "Generate colors..."
	@$(SWIFTGEN) colors -t swift3 -o Loop/Generated/Colors.swift Design/LoopStyleguide.clr
	@echo "Generate storyboards..."
	@$(SWIFTGEN) storyboards -t swift3 -o Loop/Generated/Storyboards.swift Loop/Base.lproj/Main.storyboard
	@echo "Generate strings..."
	@$(SWIFTGEN) strings -t structured-swift3 Loop/Assets/Localizable.strings > Loop/Generated/I10N.swift
	@echo "Generate fonts..."
	@$(SWIFTGEN) fonts -o Loop/Generated/Fonts.swift -t swift3 Loop/Assets/Fonts
	@echo "Generate sourcery..."
	@$(SOURCERY) --sources BirdNest/Sources --templates Templates --output BirdNest/Generated

lint:
	$(SWIFTLINT)

