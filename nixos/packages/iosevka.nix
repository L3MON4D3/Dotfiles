{
  lib,
  iosevka,
  fetchFromGithub,
  buildNpmPackage,
  writeTextFile
}:

iosevka.override {
  privateBuildPlan = ''
    [buildPlans.Iosevka-l3mon]
    family = "iosevka"
    spacing = "term"
    serifs = "sans"
    noCvSs = true

    [buildPlans.Iosevka-l3mon.weights.Regular]
    shape = 400
    menu  = 400
    css   = 400

    [buildPlans.Iosevka-l3mon.variants.design]
    asterisk = "hex-low"
    dollar = "open"
    cent = "open"
    percent = "rings-continuous-slash"
    number-sign = "slanted"
  '';
  set = "-l3mon";
}
