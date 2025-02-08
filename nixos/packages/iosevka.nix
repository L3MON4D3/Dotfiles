{
  lib,
  iosevka,
  fetchFromGithub,
  buildNpmPackage,
  writeTextFile
}:

iosevka.override (let
  # rename to avoid recursion.
  superBuildNpmPackage = buildNpmPackage;
in {
  privateBuildPlan = ''
    [buildPlans.Iosevka-l3mon]
    family = "iosevka"
    spacing = "term"
    serifs = "sans"
    noCvSs = true

    [buildPlans.Iosevka-l3mon.variants.design]
    asterisk = "hex-low"
    dollar = "open"
    cent = "open"
    percent = "rings-continuous-slash"
    number-sign = "slanted"
  '';
  set = "-l3mon";
})
