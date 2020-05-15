# colrspace

Stata module providing a class-based color management system in Mata

`colrspace` supports a wide variety of color spaces and translations
among them, provides color generators and a large collection of named palettes,
and features functionality such as color interpolation, grayscale conversion,
or color vision deficiency simulation.

To install the `colrspace` package from the SSC Archive, type

    . ssc install colrspace, replace

in Stata. Stata version 14.2 or newer is required.

---

Installation from GitHub:

    . net install colrspace, replace from(https://raw.githubusercontent.com/benjann/colrspace/master/)

---

Main changes:

    15may2020
    - the p argument in S.gray() and S.dvd() can now be a vector; colors will be 
      recycled if p has more elements than there are colors (same behavior as in
      S.intensify/luminate/saturate())
      Note: the change does not apply to S.convert(), where the p argument for
      for "gray" and "dvd" still has to be scalar 
    - S.intensify/luminate/saturate() returned error if S contained no colors; this
      is fixed
    - palette info for -lin- was not fully accurate; this is corrected
    
    14may2020
    - S.names() and S.Names() added (color names)
    - S.cvalid() added (check whether a color specification is valid)
    - S.info() and S.Info() no longer have an rgbforce argument
    - CMYK colors are now always exported as RGB by S.colors()
    - system for handling palettes revised and partially rewritten
      o S.pexists() added (check whether a palette exists)
      o S.pinfo() added (palette description)
      o S.psource() added (palette source)
      o S.palette() and S.matplotlib() now assign a palette description and a
        source
      o some palettes now assign color names
      o matplotlib colormaps are now supported by S.palettes() (using a
        redirection to S.matplotlib())
    
    10may2020
    - changed info for some palettes so that it contains valid names that can be
      used by colorpalette when creating globals
    - some fixes to help file
    
    10may2020
    - changed info for some palettes so that it contains valid names that can be
      used by colorpalette when creating globals
    - some fixes to help file
    
    09may2020
    - webcolors added as palette
    - some fixes to help file
    
    17apr2020
    - installation files added to GitHub distribution
    
    03feb2019
    - released on SSC
