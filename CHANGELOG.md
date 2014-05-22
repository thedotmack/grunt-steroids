#0.2.2 (2014-05-22)

Support for *.android.scss and *.android.sass. Thanks to @couhajjou for the pull request!

#0.2.1 (2014-04-28)

SCSS files prefixed with `_` won't be compiled and thus can be used with `@import`, minor error logging fixes, updated dependencies.

Features:
- SCSS files prefixed with `_` (e.g. `_importThis.scss`) won't be compiled and thus can be used with `@import`.

Changes:
- Grunt npm dependencies updated to latest versions.

Bugfixes:
- `steroids-configure` task now gives a proper error message if `www/config.xml` is missing.

#0.2.0 (2014-02-17)

Added `steroids-configure` Grunt task to `steroids-make` defaults, used to parse [Steroids Addons](http://www.appgyver.com/steroids/addons) feature configurations from `www/config.xml`.

#0.1.2 (2013-12-19)

Updated absolute version numbers for dependencies to latest.

#0.1.1 (2013-12-13)

Fixed `steroids-concat-models` task using `dist/models/` as source instead of `app/models/`. This fixes concatenation of `.coffee` model files into `models.js`.

#0.1.0 (2013-12-12)

Initial release. Defines the default Steroids make task `steroids-make` and the SASS compile task `steroids-compile-sass`.
