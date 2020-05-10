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
