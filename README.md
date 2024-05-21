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

    21may2024 (v 1.2.0)
    - placeholders for system colors are now included in the index of named colors
      so that there will be less queries to the file system
    - in Stata 17 or lower, additional Stata 18 system colors are now provided
      internally as named colors (not through the library file)
    - abbreviations, e.g. in S.colors() or S.palettes(), could result in unstable
      matches if there were elements with the same name apart from capitalization;
      this is fixed (lowercase is now prioritized)
    - finding named colors and palettes is now more efficient (by avoiding repeated
      sorting)

    20may2024 (v 1.1.9)
    - S.colors() now allows ".." and "..." only as last element
    - S.colors() now disallows "=" as first element
    - S.colors() now substitutes "=" by the last color

    20may2024 (v 1.1.8)
    - the behavior of argument -noexpand- in S.palette() slightly changed; if the
      number of requested colors is smaller then the minimum number of colors
      defined in a palette, noexpand!=0 now always causes the first few colors to
      be selected; the old behavior was to apply such selection only in case
      of qualitative palettes
    - S.select() and S.order() sometimes failed if S contained only a single
      color; this is fixed

    19may2024 (v 1.1.7)
    - palette -st- added (15 colors as in Stata 18's stcolor scheme); -st- (rather
      than -s2-) is now the default palette in Stata 18
    - clones of Stata 18 colors stc1-stc15 added to named colors (so that they are
      available in Stata 17 or below); these colors are not documented and not
      listed by S.namedcolors()
    - colors read from color-<name>.style are now added to the index of named
      colors (so that they only need to be read once per Stata session)
    - modifying colors using S.<fcn>_added() did not work as intended: for
      opacity and intensity it affected all colors instead of just the colors
      added last, for the other functions it behaved like S.add_<fcn>_added();
      this is fixed
    - new function S.Intensify() (with capital I) to apply the stored intensity
      multipliers to the colors (and clear the multipliers)
    - S.colors() now supports special keywords as input that are allowed in
      colorstyle specifications (e.g. "fg", "bg", "=", "." etc.); RGB code (0,0,0)
      is used internally, but S.colors() will return the keywords as long as the
      colors are not modified (undocumented)
    - S.colors() now supports opacity and intensity operators without color; RGB
      code (0,0,0) is used internally, but S.colors() will return the operators
      without color as long as colors are not modified (undocumented)
    - palette source is now added to "ColrSpace_paletteindex" if a palette is read
      form disk (i.e. each palette will be read at most once per Stata session)

    12may2023 (v 1.1.6)
    - the index of named colors and the index of palettes are now stored as
      external objects "ColrSpace_paletteindex" and "ColrSpace_namedcolorindex" so
      that they only need to be constructed once in a Stata session; this increases
      speed and reduces memory footprint if working with multiple ColrSpace objects

    30may2022 (v 1.1.5)
    - the qualitative carto palettes were not sensitive to the number of
      requested colors; this is fixed
    - the -pals- collection no longer has the -pals- prefix (e.g. -pals alphabet- is
      now provided as -alphabet-)
    - sb6 is now a simple alias for sb deep6, not a palette with an own name

    18apr2022 (v 1.1.4)
    - palette HTML contained duplicates; this is fixed

    17apr2022
    - colrspace_library_rgbmaps: palette -matplotlib turbo- had a wrong name
      (just -turbo- instead of -matplotlib turbo-); this is fixed

    02apr2022 (v 1.1.3)
    - S.shift() in (-1,1) now applies a proportional shift

    01apr2022 (v 1.1.2)
    - S.pexists() now has a second argument to return the library name
    - library_rbgmaps was incomplete; this is fixed
    - sb6 is now a palette with an own name, not a pure alias

    01apr2022 (v 1.1.1)
    - circular interpolation was not implemented correctly; this is fixed;
      S.ipolate() now always determines the interpolation method based on the
      values of S.pclass()

    01apr2022 (v 1.1.0)
    - ColrSpace now features many additional palettes and colormaps (e.g. 
      Wes Anderson palettes, palettes and colormaps from seaborn.pydata.org,
      Tableau 10 palettes, newer palettes Paul Tol, palettes from Carto, colormaps
      by Peter Kovesi, colormaps by Fabio Crameri); ColrSpace now provides some 500
      predefined palettes and colormaps
    - support for cyclic palettes has been added (and the twilight colormap
      is now correctly classified as "cyclic")
    - new S.shift() function (shift positions of colors, wrapping around at end;
      particularly useful for cyclic paletts)
    - new S.drop() function (drop individual colors; more convenient than S.select()
      in some situations)
    - S.delta() now additionally supports color difference definitions "E94"
      (1994 CIELAB Delta E definition) and "E2000" (2000 CIELAB Delta E definition)
    - the system of palette library files has been revised; new library files
      library_lsmaps and library_rgbmaps are now used in place of library_matplotlib

    06jun2020 (v 1.0.9)
    - support for "_personal" library files added
    
    28may2020
    - internal functions replacedata() and appenddata() did not clear the
      temporary copy of the data container upon completion; this is fixed
    
    27may2020
    - palette definitions, names colors, matplotlib colormap definitions, and color
      generator parameters are now kept in external source files that are read on
      the fly; system for handling palettes completely rewritten
    - expanded set of names colors by various W3.CSS colors; the colors are also available
      as palettes
    - functions S.generate*() and S.matplotlib() no longer exist; their functionality
      is now integrated in S.palette()
    - S.matplotlib_ip() has been renamed to S.lsmap()
    - S.palettes() now returns a list of the names of all available palettes
    - S.namedcolors() now returns a list of all available named colors (apart from
      Stata's system colors) including their hex code
    - S.clear() clears all all colors
    - S.clearsettings() resets color space settings to default
    - S.clearindex() clears the internal indices of palettes names and of named colors
    - reorganized help file
    
    19may2020
    - using new design for the add/added functions that no longer requires making a 
      copy of S
    - all functions setting or modifying colors now leave S unchanged if they fail
    - S._[add_]colors() and S._[add_]Colors() added
    - S.cvalid() is now returns the color name (or RGB code) instead of returning 
      a 0/1 flag
    - S.describe() and S.settings() added
    - S.alpha() now documented
    - S.colors() now gives colors defined in stylefiles - be they official Stata's
      colors or user-added style files - precedence over webcolors as long as the
      specified name is not an exact webcolor match (including case); in earlier
      versions, only official Stata's colors took precedence over webcolors
    - S.colors() only read a stylefile if the color name complied to Statas 
      conventions for names; this was overly restrictive and has now been changed
    - S.pexists() now returns (expanded) name of palette if palette is found and empty 
      string else (instead of returning 0/1); S.pname() is no longer set
    - "_added" functions did not work if no "add_" function has been applied yet; 
      this is fixed (i.e., the original colors are treated as the first "added" 
      colors, if "add_" has not been applied yet)
    - add_colors_added() and add_Colors_added() were defined even though they
      had no use; these definitions have been removed
    - palettes now clickable in helpfile
    
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
