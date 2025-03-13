## R CMD check results

❯ checking for future file timestamps ... NOTE
  unable to verify current time

❯ checking R code for possible problems ... NOTE
  kitesquare: no visible binding for global variable 'count'
  kitesquare: no visible binding for global variable 'xmarg'
  kitesquare: no visible binding for global variable 'ymarg'
  kitesquare: no visible binding for global variable 'xprop'
  kitesquare: no visible binding for global variable 'yprop'
  kitesquare: no visible binding for global variable 'xykite'
  kitesquare: no visible binding for global variable 'xmin'
  kitesquare: no visible binding for global variable 'xmax'
  kitesquare: no visible binding for global variable 'ymin'
  kitesquare: no visible binding for global variable 'ymax'
  kitesquare: no visible binding for global variable 'ykitersect'
  kitesquare: no visible binding for global variable 'xkitersect'
  kitesquare: no visible binding for global variable 'prop'
  Undefined global functions or variables:
    count prop xkitersect xmarg xmax xmin xprop xykite ykitersect ymarg
    ymax ymin yprop

❯ checking sizes of PDF files under 'inst/doc' ... NOTE
  Unable to find GhostScript executable to run checks on size reduction

0 errors ✔ | 0 warnings ✔ | 3 notes ✖

* This is a new release.

I observed 3 notes. Given the simplicity of the package, I do not believe they hint at deeper issues.

* Timestamp note appears inconsequential. As I work at a hospital, I suspect this is central IT blocking NTP.

* Variables without binding are all column names in a tibble, the note is thus a false positive due to NSE.

* This is a company computer on which I cannot install ghostscript.

No additional errors, warnings or notes were returned by devtools::check_win_devel().

## revdepcheck results

Could not install revdepcheck: "package ‘revdepcheck’ is not available for this version of R"



