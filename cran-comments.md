## R CMD check results

❯ checking for future file timestamps ... NOTE
  unable to verify current time

❯ checking sizes of PDF files under 'inst/doc' ... NOTE
  Unable to find GhostScript executable to run checks on size reduction

0 errors ✔ | 0 warnings ✔ | 2 notes ✖

* This is a new release.

I observed 2 notes. Given the simplicity of the package, I do not believe they hint at deeper issues.

* Timestamp note appears inconsequential. As I work at a hospital, I suspect this is central IT blocking NTP.

* This is a company computer on which I cannot install ghostscript.

No additional errors, warnings or notes were returned by devtools::check_win_devel().

## revdepcheck results

Could not install revdepcheck: "package ‘revdepcheck’ is not available for this version of R"



