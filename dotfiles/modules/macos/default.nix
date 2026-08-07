{
  config,
  lib,
  ...
}:
let
  cfg = config.local.macos;
  inherit (lib) mkIf mkEnableOption;

  # Moom persists every custom control as a complete record, so the shared
  # scaffolding lives here and only the differing parts are passed in.
  moomControlDefaults = {
    "Apply to Overlapping Windows" = false;
    "Auto-Trigger" = false;
    "Auto-Trigger Display Count" = 1;
    "Center Mode" = 0;
    "Confine to Display" = false;
    Generic = false;
    "Loop Through Displays" = false;
    "Move Delta" = 50;
    "Move Delta Unit" = 0;
    "Move Direction" = 5;
    "Move to Edge/Corner Direction" = 5;
    "Resize Anchor" = 10;
    "Resize Height Unit" = 0;
    "Resize Proportionally" = false;
    "Resize Size" = "{800, 600}";
    "Resize Width Unit" = 0;
  };

  # A resize control (Action 19) bound to cmd + a number key. The identifier is
  # reused as the hot key identifier, which is how Moom itself stores them.
  mkMoomGridControl =
    {
      identifier,
      keyCode,
      label,
      frame,
    }:
    moomControlDefaults
    // {
      Action = 19;
      Collapsed = false;
      Identifier = identifier;
      "Hot Key" = {
        Identifier = identifier;
        "Key Code" = keyCode;
        "Modifier Flags" = 256; # Carbon cmdKey
        "Visual Representation" = label;
      };
      "Relative Frame" = frame;
    };
in
{
  options.local.macos.enable = mkEnableOption "macOS user defaults";

  config = mkIf cfg.enable {
    # Written with `defaults import`, which merges per top-level key: keys not
    # named here are left alone, but a key that is named is replaced outright.
    targets.darwin.defaults = {
      NSGlobalDomain = {
        # Appearance
        AppleInterfaceStyle = "Dark";
        AppleIconAppearanceTheme = "RegularDark";
        AppleAquaColorVariant = 1;
        AppleAntiAliasingThreshold = 4;
        NSGlassDiffusionSetting = false;

        # Keyboard repeat, well below what System Settings exposes
        InitialKeyRepeat = 15;
        KeyRepeat = 2;

        # Windows
        AppleMiniaturizeOnDoubleClick = false;

        # Language, region and formats
        AppleLanguages = [
          "en-US"
          "mk-MK"
        ];
        AppleLocale = "en_US@rg=mkzzzz";
        AppleICUDateFormatStrings = {
          "1" = "y-MM-dd";
        };
        AppleICUNumberSymbols = {
          "0" = ".";
          "1" = ",";
          "10" = ".";
          "17" = ",";
        };

        # Text input and spelling
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = true;
        NSAutomaticSpellingCorrectionEnabled = false;
        WebAutomaticSpellingCorrectionEnabled = false;
        NSSpellCheckerAutomaticallyIdentifiesLanguages = false;
        NSPreferredSpellServerLanguage = "en_US";
        NSPreferredSpellServerVendors = {
          en_US = "Open";
        };
        KB_SpellingLanguage = {
          KB_SpellingLanguage = [
            "en_US"
            "Open"
          ];
          KB_SpellingLanguageIsAutomatic = false;
        };

        # Smart quotes
        KB_DoubleQuoteOption = "“abc”";
        KB_SingleQuoteOption = "‘abc’";
        NSUserQuotesArray = [
          "“"
          "”"
          "‘"
          "’"
        ];

        # Text replacements
        NSUserDictionaryReplacementItems = [
          {
            on = 1;
            replace = "mfg";
            "with" ="Mit freundlichen Grüßen";
          }
          {
            on = 1;
            replace = "omw";
            "with" ="On my way!";
          }
          {
            on = 1;
            replace = "loremipsum";
            "with" ="Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
          }
          {
            on = 1;
            replace = "и'";
            "with" ="ѝ";
          }
          {
            on = 1;
            replace = "е'";
            "with" ="ѐ";
          }
        ];

        # Misc
        shouldShowRSVPDataDetectors = false;
        NSPreferredWebServices = {
          NSWebServicesProviderWebSearch = {
            NSDefaultDisplayName = "Google";
            NSProviderIdentifier = "com.google.www";
          };
        };
        "com.apple.sound.beep.flash" = 0;
        "com.apple.springing.enabled" = true;
        "com.apple.springing.delay" = 0.5;
        "com.apple.trackpad.forceClick" = true;

        # Deliberately not managed here, because macOS owns them and rewrites
        # them at runtime: ACDMonthlyAnalyticsLastPosted, AKLastIDMSEnvironment,
        # AKLastLocale, _AKBAACertMarkerKey, AppleLanguagesSchemaVersion,
        # NSLinguisticDataAssets*, NSNavPanel*/NavPanel* open-panel state,
        # NSSpellChecker*ContainerTransitionComplete,
        # PKFPANInitialEligibilityCheckPerformedKey and
        # com.apple.finder.SyncExtensions.
      };

      # Only the position: the Dock's app list is left to the Dock.
      "com.apple.dock".orientation = "right";

      "com.manytricks.Moom" = {
        "Application Mode" = 1;
        "Dismiss After Filling" = true;
        "Hide Keyboard Controls Logo" = true;
        "Keyboard Controls Grid" = false;
        "Mouse Controls Trigger: Apple: Primary" = true;
        "Show Cheat Sheet" = true;

        # Keyboard control trigger and its arrow-key bindings
        "Key Control: Arrow" = 12;
        "Key Control: Arrow: Command" = 41;
        "Keyboard Controls" = {
          Identifier = "Keyboard Controls";
          "Key Code" = 13;
          "Modifier Flags" = 393475;
          "Visual Representation" = "⌃⇧W";
        };

        # This array is authoritative: controls added through Moom's UI are
        # dropped on the next activation, so add them here instead. The saved
        # snapshot control is intentionally absent, as its payload is display
        # geometry plus window titles from whatever was open at capture time.
        "Custom Controls" = [
          (moomControlDefaults
            // {
              Action = -101;
              Collapsed = true;
              Identifier = "959F15C0-E090-482B-85DB-58EEDEBDE7DC";
              "Relative Frame" = "{{0.16666666666666666, 0.25}, {0.66666666666666663, 0.5}}";
              Title = "SAMPLE CUSTOM CONTROLS";
            }
          )
          (mkMoomGridControl {
            identifier = "7787568D-F88B-4BB3-BC37-1E304F03EF80";
            keyCode = 18;
            label = "1";
            frame = "{{0, 0}, {0.33333333333333331, 1}}"; # left third
          })
          (mkMoomGridControl {
            identifier = "9688F05D-AE4E-42C5-96A6-530659D6AFF9";
            keyCode = 19;
            label = "2";
            frame = "{{0.33333333333333331, 0}, {0.66666666666666674, 1}}"; # right two thirds
          })
          (mkMoomGridControl {
            identifier = "FF70AA5A-BF2C-4FB1-8104-77E3C54AC59D";
            keyCode = 20;
            label = "3";
            frame = "{{0, 0}, {0.66666666666666663, 1}}"; # left two thirds
          })
          (mkMoomGridControl {
            identifier = "616DCDEF-4A0E-4BF4-A420-44C79A7AD18F";
            keyCode = 21;
            label = "4";
            frame = "{{0.66666666666666663, 0}, {0.33333333333333337, 1}}"; # right third
          })
        ];
      };

      # Ghostty's Sparkle updater. Everything else lives in the ghostty module.
      "com.mitchellh.ghostty" = {
        SUEnableAutomaticChecks = true;
        SUAutomaticallyUpdate = true;
        SUSendProfileInfo = false;
      };
    };
  };
}
