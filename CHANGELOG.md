# Changelog
## v1.1.9
* Fixed an issue where Material You theme selection would be incorrectly overriden on some platforms.

## v1.1.8
* Bug fixes.
  * Reworked browser warning to compile on all platforms.
  * Web manifest pointed to wrong image assets.

## v1.1.7
* Made the icon better.

## v1.1.6
* Added warning for browsers that do not support wakelock.
  * Safari requires 16.4 or greater.
  * Firefox is straight-up unsupported.
  * Chrome and derivatives are fully supported.

## v1.1.5
* Added an icon, likely temporary.

## v1.1.4
* Default color scheme is now Material You if available.
* All schemes follow Material3 saturation guidelines.
* More theming in general.
* Small Settings UI changes.

## v1.1.3
* Integrated Material You.

## v1.1.2
* Needles and decider glow match accent color selection.

## v1.1.1
* Allowed right-click to open counter menu.
* Use a neat Material3 button for player count.

## v1.1.0
* Added accent color customization.
* Added the ability to pin counters to the main screen.
* Made the needle spinning logic slightly more efficient.
* Updated runner files for Windows.

## v1.0.4
* Added a link in Settings to request features or report bugs.
* Updated static web files to latest provided by Flutter.
* Added some license information.

## v1.0.3
* Fixed state-related bug when clearing counters (issue #1).
* Fixed inverted taps on inverted players (issue #3).

## v1.0.2
* Fixed some web-related bugs.
  * Wakelock library needs time to initialize.
  * Odd bug with `shared_preferences` and nullable primitives caused Settings to crash.

## v1.0.1
* Small changes related to async presentation.

## v1.0.0
* Initial release!
