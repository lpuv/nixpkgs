args @ { fetchurl, ... }:
rec {
  baseName = ''cl-l10n-cldr'';
  version = ''20120909-darcs'';

  description = ''The necessary CLDR files for cl-l10n packaged in a QuickLisp friendly way.'';

  deps = [ ];

  src = fetchurl {
    url = ''http://beta.quicklisp.org/archive/cl-l10n-cldr/2012-09-09/cl-l10n-cldr-20120909-darcs.tgz'';
    sha256 = ''03l81bx8izvzwzw0qah34l4k47l4gmhr917phhhl81qp55x7zbiv'';
  };

  overrides = x: {
    postInstall = ''
        echo "$CL_SOURCE_REGISTRY"
        NIX_LISP_PRELAUNCH_HOOK='nix_lisp_run_single_form "(asdf:load-system :cl-l10n-cldr)"' "$out/bin/cl-l10n-cldr-lisp-launcher.sh" ""
    '';
  };
}
