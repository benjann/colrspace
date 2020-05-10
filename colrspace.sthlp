{smcl}
{* 10may2020}{...}
{cmd:help colrspace}
{hline}

{title:Title}

{pstd}
    {bf:ColrSpace -- Mata class for color management}


{title:Description}

{pstd}
    {cmd:ColrSpace} is a class-based color management system implemented in
    Mata. It supports a wide variety of color spaces and translations among
    them, provides color generators and a large collection of named palettes,
    and features functionality such as color interpolation, grayscale conversion,
    or color vision deficiency simulation.

{pstd}
    {cmd:ColrSpace} requires Stata 14.2 or newer.

{pstd}
    The examples below make use of the {helpb colorpalette} command, which is
    provided as part of the {cmd:palettes} package. Type

        {com}. ssc install palettes, replace{txt}

{pstd}
    to install the package.


{title:Contents}

    {help colrspace##cspace:Color spaces}
    {help colrspace##index:Alphabetical index of functions}
    {help colrspace##init:Initialize a ColrSpace object}
    Settings:
        {help colrspace##rgbspace:RGB working space}
        {help colrspace##xyzwhite:XYZ reference white}
        {help colrspace##viewcond:CIECAM02 viewing conditions}
        {help colrspace##ucscoefs:Default coefficients for J'M'h and J'a'b'}
        {help colrspace##chadapt:Chromatic adaption method}
    Define and transform colors:
        {help colrspace##string:String input/output (Stata interface)}
        {help colrspace##io:Import/export colors in various spaces}
        {help colrspace##opint:Set/retrieve opacity and intensity}
        {help colrspace##ipolate:Interpolate, mix, recycle, select, order}
        {help colrspace##intensify:Intensify, saturate, luminate}
        {help colrspace##gray:Grayscale conversion}
        {help colrspace##cvd:Color vision deficiency simulation}
        {help colrspace##palettes:Color palettes}
        {help colrspace##cgen:Color generators}
        {help colrspace##delta:Color differences and contrast ratios}
        {help colrspace##util:Some utilities}
    {help colrspace##source:Source code and certification script}
    {help colrspace##ref:References}
    {help colrspace##author:Author}
    {help colrspace##alsosee:Also see}


{marker cspace}{...}
{title:Color spaces}

{pstd}
    The following diagram shows an overview of the different color spaces
    and coding schemes supported by {cmd:ColrSpace}:

                  {help colrspace##HEX:HEX}   {c TLC}{c -} {help colrspace##HSV:HSV}
                   |    {c |}
         ({help colrspace##RGBA:RGBA}) {c -} {help colrspace##RGB:RGB}   {c LT}{c -} {help colrspace##HSL:HSL}                  {help colrspace##xyY1:xyY1}
                   |    {c |}                        |
        ({help colrspace##RGBA1:RGBA1}) {c -} {helpb colrspace##RGB1:RGB1} {c -}{c BT}{c -} {help colrspace##CMYK1:CMYK1} {hline 1} {help colrspace##CMYK:CMYK}         {help colrspace##xyY:xyY}
                   |                             |
                  {help colrspace##lRGB:lRGB} {c -} ({help colrspace##chadapt:chromatic adaption}) {c -} {help colrspace##XYZ:XYZ} {c -} {help colrspace##XYZ1:XYZ1}
                                                 |
                        {c TLC}{hline 7}{c TT}{hline 7}{c TT}{hline 8}{c BRC}
                       {help colrspace##Lab:Lab}     {help colrspace##Luv:Luv}    {help colrspace##CAM02:CAM02 [{it:mask}]}
                        |       |       |
                       {help colrspace##LCh:LCh}     {help colrspace##HCL:HCL}     {help colrspace##JMh:JMh [{it:coefs}]}
                                        |
                                       {help colrspace##Jab:Jab [{it:coefs}]}

{pstd}
    The shown acronyms are the names by which the color spaces are referred to
    in {cmd:ColrSpace}. Internally, {cmd:ColrSpace} stores colors using
    their RGB1 values and additionally maintains an opacity value
    (alpha) in [0,1] and an intensity adjustment multiplier in [0,255] for each
    color.

{marker HEX}{...}
{phang}
    HEX is a hex RGB value (hex triplet; see
    {browse "http://en.wikipedia.org/wiki/Web_colors":Wikipedia 2019c}). Examples
    are {cmd:"#ffffff"} for white or {cmd:"#1a476f"} for Stata's navy. {cmd:ColrSpace} will
    always return HEX colors using their lowercase 6-digit codes. As input, however, uppercase spelling
    and 3-digit abbreviations are allowed. For example, white can be specified as
    are {cmd:"#ffffff"}, {cmd:"#FFFFFF"}, {cmd:"#fff"}, or {cmd:"#FFF"}.

{marker RGB}{...}
{phang}
    RGB is an RGB triplet (red, green, blue) in 0-255 scaling
    (see {browse "http://en.wikipedia.org/wiki/RGB_color_model":Wikipedia 2018f}). When
    returning RGB values, {cmd:ColrSpace} will round the values to integers and clip
    them at 0 and 255.

{marker RGB1}{...}
{phang}
    RGB1 is an RGB triplet in 0-1 scaling. {cmd:ColrSpace} does not clip or
    round the values and may thus return values larger than 1 or smaller than
    0. Using unclipped values ensures consistency of translations among
    different color spaces. To retrieve a matrix of clipped values, you can type
    {it:C} = {it:S}{cmd:.clip(}{it:S}{cmd:.get("RGB1"), 0, 1)}.

{pmore}
    RGB1 is the format in which {cmd:ColrSpace} stores colors internally. By
    default, {cmd:ColrSpace} assumes that the colors are in the standard RGB
    working space ({cmd:"sRGB"}), but this can be changed; see
    {help colrspace##rgbspace:Setting the RGB working space}. Note
    that changing the RGB working space after colors have been added to a
    {cmd:ColrSpace} object will not change the stored values. To transform
    colors from one RGB working space to another RGB working space, you could
    export the colors to XYZ typing {it:XYZ} = {it:S}{cmd:.get("XYZ")}, change
    the RGB working space using function {it:S}{cmd:.rgbspace()}, and
    then reimport the colors typing {it:S}{cmd:.set(}{it:XYZ}{cmd:, "XYZ")}.

{marker lRGB}{...}
{phang}
    lRGB stands for linear RGB in 0-1 scaling, that is, {help colrspace##RGB1:RGB1}
    from which {help colrspace##gamma:gamma correction} has been removed.

{marker HSV}{...}
{phang}
    HSV is a color triplet in the HSV (hue, saturation, value) color space. Hue is
    in degrees of the color wheel (0-360), saturation and value are numbers
    in [0,1]. {cmd:ColrSpace} uses the procedure described in
    {browse "http://en.wikipedia.org/wiki/HSL_and_HSV":Wikipedia (2018d)}
    to translate between HSV and RGB.

{marker HSL}{...}
{phang}
    HSL is a color triplet in the HSL (hue, saturation, lightness) color space. Hue is
    in degrees of the color wheel (0-360), saturation and lightness are numbers
    in [0,1]. {cmd:ColrSpace} uses the procedure described in
    {browse "http://en.wikipedia.org/wiki/HSL_and_HSV":Wikipedia (2018d)}
    to translate between HSL and RGB.

{marker CMYK}{...}
{phang}
    CMYK is a CMYK quadruplet (cyan, magenta, yellow, black) in 0-255 scaling. When returning
    CMYK values, {cmd:ColrSpace} will round the values to integers and clip
    them at 0 and 255. There is no unique standard method to translate between
    CMYK and RGB, as translation is device-specific. {cmd:ColrSpace} uses the
    same translation as is implemented in official Stata (for
    CMYK to RGB see program {cmd:setcmyk} in file
    {stata viewsource color.class:color.class}; for RGB to CMYK see
    program {cmd:rgb2cmyk} in file
    {stata viewsource palette.ado:palette.ado}).

{marker CMYK1}{...}
{phang}
    CMYK1 is a CMYK quadruplet (cyan, magenta, yellow, black) in 0-1 scaling. {cmd:ColrSpace} does
    not clip or round the values and may thus return values larger than 1 or smaller than 0. To
    retrieve a matrix of clipped values, you can type
    {it:C} = {it:S}{cmd:.clip(}{it:S}{cmd:.get("CMYK1"), 0, 1)}. See
    {help colrspace##CMYK:CMYK} for additional explanations.

{marker XYZ}{...}
{phang}
    XYZ is a CIE 1931 XYZ tristimulus value in Y_white = 100 scaling. See
    {browse "http://en.wikipedia.org/wiki/CIE_1931_color_space":Wikipedia (2018a)} for
    background information. XYZ values are defined with respect to a reference
    white; see {help colrspace##xyzwhite:Setting the XYZ reference white}. The
    default illuminant used by {cmd:ColrSpace} to define the reference white is {cmd:"D65"} (noon
    daylight for a CIE 1931 2° standard observer). To transform
    RGB to CIE XYZ, {cmd:ColrSpace} first removes
    {help colrspace##gamma:gamma correction} to obtain
    linear RGB (lRGB) and then transforms lRGB to XYZ using an appropriate
    transformation matrix (see, e.g.,
    {browse "http://www.babelcolor.com/index_htm_files/A%20review%20of%20RGB%20color%20spaces.pdf":Pascale 2003} for
    detailed explanations of both steps),
    possibly applying {help colrspace##chadapt:chromatic adaption} to take account
    of a change in the reference white between the RGB working space and the
    XYZ color space.

{marker XYZ1}{...}
{phang}
    XYZ1 is a CIE XYZ tristimulus value in Y_white = 1 scaling. See
    {help colrspace##XYZ:XYZ} for additional explanations.

{marker xyY}{...}
{phang}
    xyY is a CIE xyY triplet, where x (cyan to red for y around .2) and y (magenta to
    green for x around .2) are the chromaticity coordinates in [0,1], with x + y <= 1, and Y is
    the luminance in Y_white = 100 scaling (Y in CIE xyY is the same as Y in
    CIE XYZ). {cmd:ColrSpace} uses the procedure described in
    {browse "http://en.wikipedia.org/wiki/CIE_1931_color_space":Wikipedia (2018a)}
    to translate between XYZ and xyY.

{marker xyY1}{...}
{phang}
    xyY1 is a CIE xyY triplet, with Y in Y_white = 1 scaling. See
    {help colrspace##xyY:xyY} for additional explanations.

{marker Lab}{...}
{phang}
    Lab is a color triplet in the CIE L*a*b* color space. L* in [0,100] is the
    lightness of the color, a* is the green (-) to red (+) component, b* is the
    blue (-) to yellow (+) component. The range of a* and b* is somewhere
    around +/- 100 for typical colors. {cmd:ColrSpace} uses the procedure described in
    {browse "http://en.wikipedia.org/wiki/CIELAB_color_space":Wikipedia (2018b)}
    to translate between XYZ and CIE L*a*b*.

{marker LCh}{...}
{phang}
    LCh is a color triplet in the CIE LCh color space
    (cylindrical representation of CIE L*a*b*). L (lightness) in [0,100] is the same as L* in
    CIE L*a*b*, C (chroma) is the relative colorfulness (with typical values in a range
    of 0-100, although higher values are possible), h (hue) is the angle on the color wheel
    in degrees (0-360). See
    {browse "http://en.wikipedia.org/wiki/CIELAB_color_space":Wikipedia (2018b)}.

{marker Luv}{...}
{phang}
    Luv is a color triplet in the CIE L*u*v* color space. L* in [0,100] is the
    lightness of the color, u* is the green (-) to red (+) component, v* is the
    blue (-) to yellow (+) component. The range of u* and v* is somewhere
    around +/- 100 for typical colors. {cmd:ColrSpace} uses the procedure described in
    {browse "http://en.wikipedia.org/wiki/CIELUV":Wikipedia (2018c)}
    to translate between XYZ and CIE L*u*v*. L* in CIE L*u*v* is the same
    as L* in CIE L*a*b*.

{marker HCL}{...}
{phang}
    HCL is a color triplet in the HCL color space (cylindrical
    representation of CIE L*u*v*). H (hue) is the angle on the color wheel
    in degrees (0-360), C (chroma) is the relative colorfulness (with
    typical values in a range of 0-100, although higher values are possible),
    L (lightness) in [0,100] is the same as L* in CIE L*u*v*. See
    {browse "http://en.wikipedia.org/wiki/CIELUV":Wikipedia (2018c)}.

{marker CAM02}{...}
{phang}
    CAM02 is a color value in the CIECAM02 color space. See
    {browse "http://doi.org/10.1007/978-1-4419-6190-7_2":Luo and Li (2013)}
    for details. In {cmd:ColrSpace}, CIECAM02 is specified as

            {cmd:"CAM02 }[{it:mask}]{cmd:"}

{pmore}
    where optional {it:mask} selects the CIECAM02 attributes. The supported
    attributes are {cmd:Q} (brightness), {cmd:J} (lightness), {cmd:M} (colourfulness),
    {cmd:C} (chroma), {cmd:s} (saturation), {cmd:h} (hue angle), and {cmd:H}
    (hue composition). For example, you could type

            C = {it:S}{cmd:.get("CAM02 QJMCshH")}

{pmore}
    to obtain a {it:n} x 7 matrix containing all available attributes for each
    color. When importing colors, e.g. using {it:S}{cmd:.colors()} or
    {it:S}{cmd:.set()}, {it:mask} must contain at least one of {cmd:Q} and
    {cmd:J}, at least one of {cmd:M}, {cmd:C}, and {cmd:s}, and at least one of
    {cmd:h} and {cmd:H}. If {it:mask} is omitted, {cmd:ColrSpace} assumes
    {cmd:"CAM02 JCh"}.

{marker JMh}{...}
{phang}
    JMh is a color triplet in the CIECAM02-based perceptually uniform
    J'M'h color space. See
    {browse "http://doi.org/10.1007/978-1-4419-6190-7_2":Luo and Li (2013, chapter 2.6.1)}
    and {browse "http://doi.org/10.1002/col.20227":Luo et al. (2006)}
    for details. In {cmd:ColrSpace}, J'M'h is specified as

            {cmd:"JMh }[{it:coefs}]{cmd:"}

{pmore}
    where optional {it:coefs} selects the transformation coefficients. {it:coefs} can be

                {cmd:UCS}
            or  {cmd:LCD}
            or  {cmd:SCD}
            or  {it:K_L} {it:c_1} {it:c_2}

{pmore}
    (lowercase spelling and abbreviations allowed). {bind:{cmd:"JMh UCS"}} is equivalent
    to {bind:{cmd:"JMh 1 .007 .0228"}}, {bind:{cmd:"JMh LCD"}} is equivalent to
    {bind:{cmd:"JMh .77 .007 .0053"}}, {bind:{cmd:"JMh SCD"}}
    is equivalent to {bind:{cmd:"JMh 1.24 .007 .0363"}}. If {it:coefs} is omitted,
    the default coefficients as set by {help colrspace##ucscoefs:{it:S}{bf:.ucscoefs()}}
    will be used.

{marker Jab}{...}
{phang}
    Jab is a color triplet in the CIECAM02-based perceptually uniform
    J'a'b' color space. See
    {browse "http://doi.org/10.1007/978-1-4419-6190-7_2":Luo and Li (2013, chapter 2.6.1)}
    and {browse "http://doi.org/10.1002/col.20227":Luo et al. (2006)}
    for details. In {cmd:ColrSpace}, J'a'b' is specified as

            {cmd:"Jab }[{it:coefs}]{cmd:"}

{pmore}
    where optional {it:coefs} is as described in {help colrspace##JMh:JMh}.

{marker RGBA}{...}
{phang}
    RGBA is an opacity-extended RGB value (red, green, blue, alpha), where
    red, green, and blue are in 0-255 scaling and alpha is a number in [0,1] (0 =
    fully transparent, 1 = fully opaque). RGBA is not directly supported by
    {it:S}{cmd:.convert()}, but is allowed as input or output
    format in functions such as {it:S}{cmd:.colors()}, {it:S}{cmd:.set()}, or
    {it:S}{cmd:.get()}. Alternatively, in {it:S}{cmd:.colors()}, you can use
    non-extended RGB and specify opacity using Stata's {it:{help colorstyle}}
    syntax; for example {cmd:"RGBA 26 71 111 0.7"} is equivalent to
    {cmd:"RGB 26 71 111%70"} or {cmd:"26 71 111%70"} (see the section on
    {help colrspace##string:String input/output} below). A further alternative
    is to manage opacity using {it:S}{cmd:.opacify()} or {it:S}{cmd:.alpha()} (see
    {help colrspace##opint:Set/retrieve opacity and intensity}).

{marker RGBA1}{...}
{phang}
    RGBA1 is an opacity-extended RGB value (red, green, blue, alpha), where
    red, green, and blue are in 0-1 scaling and alpha is a number in [0,1] (0 =
    fully transparent, 1 = fully opaque). See {help colrspace##RGBA:RGBA} for
    additional explanations.


{marker index}{...}
{title:Alphabetical index of functions}

{p2colset 5 25 27 2}{...}
{p2col:{helpb colrspace##init:ColrSpace()}}initialize a {cmd:ColrSpace} object{p_end}
{p2col:{helpb colrspace##io:{it:S}.add()}}add colors in particular space{p_end}
{p2col:{helpb colrspace##opint:{it:S}.alpha()}}set/retrieve opacity{p_end}
{p2col:{helpb colrspace##chadapt:{it:S}.chadapt()}}set chromatic adaption method{p_end}
{p2col:{helpb colrspace##clip:{it:S}.clip()}}helper function for clipping{p_end}
{p2col:{helpb colrspace##contrast:{it:S}.contrast()}}compute contrast ratios{p_end}
{p2col:{helpb colrspace##delta:{it:S}.delta()}}compute color differences{p_end}
{p2col:{helpb colrspace##ipolate:{it:S}.colipolate()}}helper function for interpolating{p_end}
{p2col:{helpb colrspace##string:{it:S}.colors()}}string input/output (scalar){p_end}
{p2col:{helpb colrspace##string:{it:S}.Colors()}}string input/output (vector){p_end}
{p2col:{helpb colrspace##recycle:{it:S}.colrecycle()}}helper function for recycling{p_end}
{p2col:{helpb colrspace##convert:{it:S}.convert()}}convert colors between spaces{p_end}
{p2col:{helpb colrspace##cvd:{it:S}.cvd()}}color vision deficiency simulation{p_end}
{p2col:{helpb colrspace##cvd:{it:S}.cvd_M()}}helper function to retrieve CVD matrix{p_end}
{p2col:{helpb colrspace##cgen:{it:S}.generate()}}color generators{p_end}
{p2col:{helpb colrspace##get:{it:S}.get()}}retrieve colors in particular space{p_end}
{p2col:{helpb colrspace##gray:{it:S}.gray()}}gray scale conversion{p_end}
{p2col:{helpb colrspace##info:{it:S}.info()}}color description input/output (scalar){p_end}
{p2col:{helpb colrspace##info:{it:S}.Info()}}color description input/output (vector){p_end}
{p2col:{helpb colrspace##intensify:{it:S}.intensify()}}adjust color intensity{p_end}
{p2col:{helpb colrspace##intensity:{it:S}.intensity()}}set/retrieve intensity adjustment{p_end}
{p2col:{helpb colrspace##ipolate:{it:S}.ipolate()}}interpolate colors{p_end}
{p2col:{helpb colrspace##isipolate:{it:S}.isipolate()}}whether interpolation has been applied{p_end}
{p2col:{helpb colrspace##luminate:{it:S}.luminate()}}adjust luminance of colors{p_end}
{p2col:{helpb colrspace##matplotlib:{it:S}.matplotlib()}}retrieve {browse "http://matplotlib.org":matplotlib} colormap{p_end}
{p2col:{helpb colrspace##matplotlib:{it:S}.matplotlib_ip()}}helper function to create colormaps{p_end}
{p2col:{helpb colrspace##mix:{it:S}.mix()}}mix colors{p_end}
{p2col:{helpb colrspace##util:{it:S}.N()}}retrieve number of colors{p_end}
{p2col:{helpb colrspace##opint:{it:S}.opacity()}}set/retrieve opacity{p_end}
{p2col:{helpb colrspace##select:{it:S}.order()}}order colors{p_end}
{p2col:{helpb colrspace##palettes:{it:S}.palette()}}retrieve colors from named palette{p_end}
{p2col:{helpb colrspace##pclass:{it:S}.pclass()}}set/retrieve palette class{p_end}
{p2col:{helpb colrspace##pname:{it:S}.pname()}}set/retrieve palette name{p_end}
{p2col:{helpb colrspace##recycle:{it:S}.recycle()}}recycle colors{p_end}
{p2col:{helpb colrspace##io:{it:S}.reset()}}reset colors in particular space{p_end}
{p2col:{helpb colrspace##select:{it:S}.reverse()}}reverse order of colors{p_end}
{p2col:{helpb colrspace##rgbspace:{it:S}.rgbspace()}}set RGB working space{p_end}
{p2col:{helpb colrspace##rgbspace:{it:S}.rgb_gamma()}}set/retrieve gamma correction{p_end}
{p2col:{helpb colrspace##rgbspace:{it:S}.rgb_invM()}}set/retrieve XYZ-to-lRGB matrix{p_end}
{p2col:{helpb colrspace##rgbspace:{it:S}.rgb_M()}}set/retrieve lRGB-to-XYZ matrix{p_end}
{p2col:{helpb colrspace##rgbspace:{it:S}.rgb_white()}}set/retrieve RGB reference white{p_end}
{p2col:{helpb colrspace##rgbspace:{it:S}.rgb_xy()}}set/retrieve RGB primaries{p_end}
{p2col:{helpb colrspace##saturate:{it:S}.saturate()}}adjust saturation (chroma) of colors{p_end}
{p2col:{helpb colrspace##select:{it:S}.select()}}select colors{p_end}
{p2col:{helpb colrspace##io:{it:S}.set()}}set colors in particular space{p_end}
{p2col:{helpb colrspace##chadapt:{it:S}.tmatrix()}}retrieve transformation matrices{p_end}
{p2col:{helpb colrspace##ucscoefs:{it:S}.ucscoefs()}}set default J'M'h/J'a'b' coefficients{p_end}
{p2col:{helpb colrspace##viewcond:{it:S}.viewcond()}}set/retrieve CIECAM02 viewing conditions{p_end}
{p2col:{helpb colrspace##xyzwhite:{it:S}.xyzwhite()}}set/retrieve XYZ reference white{p_end}
{p2col:{helpb colrspace##chadapt:{it:S}.XYZ_to_XYZ()}}apply chromatic adaption{p_end}

{pstd}
    Several of the above functions also come in variants such as {it:S}{cmd:.add_}{it:name}{cmd:()},
    {it:S}{cmd:.}{it:name}{cmd:_added()}, or {it:S}{cmd:.add_}{it:name}{cmd:_added()},
    where {it:name} is the function name.


{marker init}{...}
{title:Initialize a ColrSpace object}

{pstd}
    To initialize a new {cmd:ColrSpace} object, type

        {cmd:class ColrSpace scalar} {it:S}

{pstd}
    or

        {it:S} = {cmd:ColrSpace()}

{pstd}
    where {it:S} is the name of the object. After initialization, the object
    will be empty, that is, contain no colors. However, the object will be
    initialized with the following default settings:

        {it:S}{cmd:.rgbspace("sRGB")}
        {it:S}{cmd:.xyzwhite("D65")}
        {it:S}{cmd:.viewcond(20, 64/(5*pi()), "average")}
        {it:S}{cmd:.ucscoefs("UCS")}
        {it:S}{cmd:.chadapt("Bfd")}


{marker rgbspace}{...}
{title:Setting the RGB working space}

{pstd}
    To set the RGB working space, type

        {it:S}{cmd:.rgbspace("}{it:name}{cmd:")}

{pstd}
    where {it:name} is one of the following:

{p2colset 9 26 28 2}{...}
{p2col:{cmd:Adobe 1998}}Adobe RGB (1998){p_end}
{p2col:{cmd:Apple}}Apple RGB{p_end}
{p2col:{cmd:Best}}Best RGB{p_end}
{p2col:{cmd:Beta}}Beta RGB{p_end}
{p2col:{cmd:Bruce}}Bruce RGB{p_end}
{p2col:{cmd:CIE}}CIE 1931 RGB{p_end}
{p2col:{cmd:ColorMatch}}ColorMatch RGB{p_end}
{p2col:{cmd:Don 4}}Don RGB 4{p_end}
{p2col:{cmd:ECI v2}}ECI RGB v2{p_end}
{p2col:{cmd:Ekta PS5}}Ekta Space PS5{p_end}
{p2col:{cmd:Generic}}Generic RGB{p_end}
{p2col:{cmd:HDTV}}HDTV (HD-CIF){p_end}
{p2col:{cmd:NTSC}}NTSC RGB (1953){p_end}
{p2col:{cmd:PAL/SECAM}}PAL/SECAM RGB{p_end}
{p2col:{cmd:ProPhoto}}ProPhoto RGB{p_end}
{p2col:{cmd:SGI}}SGI RGB{p_end}
{p2col:{cmd:SMPTE-240M}}SMPTE-240M RGB{p_end}
{p2col:{cmd:SMPTE-C}}SMPTE-C RGB{p_end}
{p2col:{cmd:sRGB}}Standard RGB using primaries from {browse "http://www.brucelindbloom.com/WorkingSpaceInfo.html":Lindbloom (2017b)}{p_end}
{p2col:{cmd:sRGB2}}Standard RGB using equation F.8 (XYZ to RGB matrix) from {browse "http://www.sis.se/api/document/preview/562720/":IEC (2003)}{p_end}
{p2col:{cmd:sRGB3}}Standard RGB using equation F.7 (RGB to XYZ matrix) from {browse "http://www.sis.se/api/document/preview/562720/":IEC (2003)}{p_end}
{p2col:{cmd:Wide Gamut}}Adobe Wide Gamut RGB{p_end}
{p2col:{cmd:Wide Gamut BL}}Wide Gamut variant from {browse "http://www.brucelindbloom.com/WorkingSpaceInfo.html":Lindbloom (2017b)}{p_end}

{pstd}
    The names can be abbreviated and typed in lowercase letters. If
    abbreviation is ambiguous, the first matching name in the alphabetically
    ordered list will be used. See the
    {help colrspace_source##rgbspaces:{bf:ColrSpace} source code} for the definitions of the
    spaces. The definitions have been taken from
    {browse "http://www.babelcolor.com/index_htm_files/A%20review%20of%20RGB%20color%20spaces.pdf":Pascale (2003)} and
    {browse "http://www.brucelindbloom.com/WorkingSpaceInfo.html":Lindbloom (2017b)}. Also
    see {browse "http://en.wikipedia.org/wiki/RGB_color_space":Wikipedia (2018g)}. The
    default is {it:S}{cmd:.rgbspace("sRGB")}. This default can also be selected
    by typing {it:S}{cmd:.rgbspace("")}. Other color management systems
    may use slightly different definition of standard RGB. For example, the
    {cmd:colorspacious} Python library by Smith (2018) uses a definition equivalent to
    {cmd:"sRGB2"}. The advantage of {cmd:"sRGB"} is that RGB white (255, 255, 255)
    translates to the reference white in XYZ, which is not exactly true for
    {cmd:"sRGB2"} or {cmd:"sRGB3"}.

{marker gamma}{...}
{pstd}
    An RGB working space consists of three elements: the parameters of the
    gamma compression used to transform lRGB (linear RGB) to RGB, the reference
    white, and the working space primaries used to transform XYZ to lRGB. Instead
    of choosing a named RGB working space, the elements can also be set
    directly. To set the gamma compression parameters, type

        {it:S}{cmd:.rgb_gamma(}{it:args}{cmd:)}

{pstd}
    where {it:args} is

            {it:gamma}
        or  {it:gamma}{cmd:,} {it:offset}{cmd:,} {it:transition}{cmd:,} {it:slope}
        or  {cmd:(}{it:gamma}{cmd:,} {it:offset}{cmd:,} {it:transition}{cmd:,} {it:slope}{cmd:)}
        or  {cmd:"}{it:gamma}{cmd:"}
        or  {cmd:"}{it:gamma} {it:offset} {it:transition} {it:slope}{cmd:"}

{pstd}
    If only {it:gamma} is provided, simple gamma encoding C' = C^(1/{it:gamma})
    is applied. If {it:offset}, {it:transition}, and {it:slope} are also
    provided, the detailed gamma encoding C' = (1 + {it:offset}) *
    C^(1/{it:gamma}) - {it:offset} if C > {it:transition} and else C' = C *
    {it:slope} is used. A typical value for {it:gamma} is 2.2; see
    {browse "http://blog.johnnovak.net/2016/09/21/what-every-coder-should-know-about-gamma/":Novak (2016)}
    for an excellent explanation of gamma compression. Likewise,
    the reference white can be set by

        {it:S}{cmd:.rgb_white(}{it:args}{cmd:)}

{pstd}
    where {it:args} is as described in
    {help colrspace##xyzwhite:Setting the XYZ reference white}. If the
    reference white of the RGB working space differs from the XYZ reference
    white, {cmd:ColrSpace} applies {help colrspace##chadapt:chromatic adaption} when translating
    between XYZ and lRGB. Furthermore, to set the working space primaries. type

        {it:S}{cmd:.rgb_xy(}{it:xy}{cmd:)}

{pstd}
    where {it:xy} is a 3 x 2 matrix containing the red, green, and blue xy
    primaries. {cmd:ColrSpace} uses the method described in
    {browse "http://www.brucelindbloom.com/Eqn_RGB_XYZ_Matrix.html":Lindbloom (2017c)} to
    compute the lRGB-to-XYZ transformation matrix from the white point and the
    primaries, and sets the XYZ-to-lRGB matrix to the inverse of the lRGB-to-XYZ
    matrix. Alternatively, you can type

        {it:S}{cmd:.rgb_M(}{it:M}{cmd:)}

{pstd}
    where {it:M} is a 3 x 3 matrix, to directly set the lRGB-to-XYZ matrix to {it:M} and
    the XYZ-to-lRGB matrix to {help mf_luinv:{bf:luinv(}{it:M}{bf:)}}, or

        {it:S}{cmd:.rgb_invM(}{it:invM}{cmd:)}

{pstd}
    to set the XYZ-to-lRGB matrix to {it:invM} and the lRGB-to-XYZ matrix to
    {help mf_luinv:{bf:luinv(}{it:invM}{bf:)}}. To retrieve the current settings, you can type

        {it:gamma} = {it:S}{cmd:.rgb_gamma()}
        {it:white} = {it:S}{cmd:.rgb_white()}
           {it:xy} = {it:S}{cmd:.rgb_xy()}
            {it:M} = {it:S}{cmd:.rgb_M()}
         {it:invM} = {it:S}{cmd:.rgb_invM()}


{marker xyzwhite}{...}
{title:Setting the XYZ reference white}

{pstd}
    To set the reference white for the CIE XYZ color space, type

        {it:S}{cmd:.xyzwhite(}{it:args}{cmd:)}

{pstd}
    where {it:args} is

            {it:X}{cmd:,} {it:Y}{cmd:,} {it:Z}
        or  {cmd:(}{it:X}{cmd:,} {it:Y}{cmd:,} {it:Z}{cmd:)}
        or  {cmd:"}{it:X} {it:Y} {it:Z}{cmd:"}
        or  {it:x}, {it:y}
        or  {cmd:(}{it:x}, {it:y}{cmd:)}
        or  {cmd:"}{it:x} {it:y}{cmd:"}
        or  {cmd:"}{it:name}{cmd:"}

{pstd}
    where {it:X}, {it:Y}, and {it:Z} are the XYZ coordinates of the
    white point (with {it:Y} = 100), {it:x} and {it:y} are the xyY coordinates of
    the white point (assuming {it:Y} = 100), and {it:name}
    is one of the following:

{p2colset 9 38 40 2}{...}
{p2col:CIE 1931 2°{space 2}CIE 1964 10°}Description{p_end}
{p2col:observer{space 5}observer}{p_end}
{p2col:{cmd:A}{space 12}{cmd:A 10 degree}}Incandescent/Tungsten 2856K{p_end}
{p2col:{cmd:B}{space 12}{cmd:B 10 degree}}Direct sunlight at noon 4874K (obsolete){p_end}
{p2col:{cmd:B BL}}B 2 degree variant from {browse "http://www.brucelindbloom.com/Eqn_ChromAdapt.html":Lindbloom (2017a)}{p_end}
{p2col:{cmd:C}{space 12}{cmd:C 10 degree}}North sky daylight 6774K (obsolete){p_end}
{p2col:{cmd:D50}{space 10}{cmd:D50 10 degree}}Horizon light 5003K (used for color rendering){p_end}
{p2col:{cmd:D55}{space 10}{cmd:D55 10 degree}}Mid-morning/mid-afternoon daylight 5503K (used for photography){p_end}
{p2col:{cmd:D65}{space 10}{cmd:D65 10 degree}}Noon daylight 6504K (new version of north sky daylight){p_end}
{p2col:{cmd:D75}{space 10}{cmd:D75 10 degree}}North sky daylight 7504K{p_end}
{p2col:{cmd:9300K}}High eff. blue phosphor monitors 9300K{p_end}
{p2col:{cmd:E}}Uniform energy illuminant 5454K{p_end}
{p2col:{cmd:F1}{space 11}{cmd:F1 10 degree}}Daylight fluorescent 6430K{p_end}
{p2col:{cmd:F2}{space 11}{cmd:F2 10 degree}}Cool white fluorescent 4200K{p_end}
{p2col:{cmd:F3}{space 11}{cmd:F3 10 degree}}White fluorescent 3450K{p_end}
{p2col:{cmd:F4}{space 11}{cmd:F4 10 degree}}Warm white fluorescent 2940K{p_end}
{p2col:{cmd:F5}{space 11}{cmd:F5 10 degree}}Daylight fluorescent 6350K{p_end}
{p2col:{cmd:F6}{space 11}{cmd:F6 10 degree}}Lite white fluorescent 4150K {p_end}
{p2col:{cmd:F7}{space 11}{cmd:F7 10 degree}}Broad-band daylight fluorescent, 6500K {p_end}
{p2col:{cmd:F8}{space 11}{cmd:F8 10 degree}}D50 simulator, Sylvania F40 design 50, 5000K{p_end}
{p2col:{cmd:F9}{space 11}{cmd:F9 10 degree}}Cool white deluxe fluorescent 4150K{p_end}
{p2col:{cmd:F10}{space 10}{cmd:F10 10 degree}}Philips TL85, Ultralume 50, 5000K{p_end}
{p2col:{cmd:F11}{space 10}{cmd:F11 10 degree}}Narrow-band white fluorescen, Philips TL84, Ultralume 40, 4000K{p_end}
{p2col:{cmd:F12}{space 10}{cmd:F12 10 degree}}Philips TL83, Ultralume 30, 3000K{p_end}

{pstd}
    The names can be abbreviated and typed in lowercase letters (for example,
    {cmd:"D55 10 degree"} could be typed as {cmd:"d55 10"}). If
    abbreviation is ambiguous, the first matching name in the alphabetically
    ordered list will be used. See the
    {help colrspace_source##illuminants:{bf:ColrSpace} source code} for the definitions of the
    white points. The definitions have been taken from
    {browse "http://www.babelcolor.com/index_htm_files/A%20review%20of%20RGB%20color%20spaces.pdf":Pascale (2003)},
    {browse "http://www.brucelindbloom.com/Eqn_ChromAdapt.html":Lindbloom (2017a)}, and
    {browse "http://en.wikipedia.org/wiki/Standard_illuminant":Wikipedia (2018h)}. The
    default is {it:S}{cmd:.xyzwhite("D65")}. This default can also be selected
    by typing {it:S}{cmd:.xyzwhite(.)} or {it:S}{cmd:.xyzwhite("")}. To retrieve a
    1 x 3 rowvector containing the XYZ coordinates of the current white point, you
    can type

        {it:white} = {it:S}{cmd:.xyzwhite()}


{marker viewcond}{...}
{title:Setting the CIECAM02 viewing conditions}

{pstd}
    To set the CIECAM02 viewing conditions, type

        {it:S}{cmd:.viewcond(}{it:args}{cmd:)}

{pstd}
    where {it:args} is

            {it:Y_b}{cmd:,} {it:L_A}{cmd:,} {it:F}{cmd:,} {it:c}{cmd:,} {it:N_c}
        or  {it:Y_b}{cmd:,} {it:L_A}{cmd:,} {cmd:(}{it:F}{cmd:,} {it:c}{cmd:,} {it:N_c}{cmd:)}
        or  {cmd:(}{it:Y_b}{cmd:,} {it:L_A}{cmd:,} {it:F}{cmd:,} {it:c}{cmd:,} {it:N_c}{cmd:)}
        or  {cmd:"}{it:Y_b} {it:L_A} {it:F} {it:c} {it:N_c}{cmd:"}
        or  {it:Y_b}{cmd:,} {it:L_A}{cmd:,} {cmd:"}{it:surround}{cmd:"}
        or  {cmd:"}{it:Y_b} {it:L_A} {it:surround}{cmd:"}

{pstd}
    with {it:surround} equal to {cmd:average} ({it:F} = 1, {it:c} = .69, {it:N_c} = 1),
    {cmd:dim} ({it:F} = .9, {it:c} = .59, {it:N_c} = .9),
    or {cmd:dark} ({it:F} = .8, {it:c} = .525, {it:N_c} = .8) (abbreviations allowed). The default is
    {it:Y_b} = 20, {it:L_A} = 64/(5*pi()), and average surround. These defaults can also be selected by
    typing {it:S}{cmd:.viewcond(.)} or {it:S}{cmd:.viewcond("")}, or by setting {it:Y_b} to {cmd:.},
    {it:L_A} to {cmd:.}, and {it:surround} to {cmd:.} or empty string. To
    retrieve a 1 x 5 rowvector of the current viewing condition parameters, type

        {it:viewcond} = {it:S}{cmd:.viewcond()}

{pstd}
    See {browse "http://doi.org/10.1007/978-1-4419-6190-7_2":Luo and Li (2013)}
    for details on CIECAM02 viewing conditions.


{marker ucscoefs}{...}
{title:Setting the default coefficients for J'M'h and J'a'b'}

{pstd}
    To set the default uniform color space coefficients for J'M'h and J'a'b', type

        {it:S}{cmd:.ucscoefs(}{it:args}{cmd:)}

{pstd}
    where {it:args} is

            {it:K_L}{cmd:,} {it:c_1}{cmd:,} {it:c_2}
        or  {cmd:(}{it:K_L}{cmd:,} {it:c_1}{cmd:,} {it:c_2}{cmd:)}
        or  {cmd:"}{it:K_L} {it:c_1} {it:c_2}{cmd:"}
        or  {cmd:"}{it:name}{cmd:"}

{pstd}
    with {it:name} equal to {cmd:UCS} ({it:K_L} = 1, {it:c_1} = .007, {it:c_2} = .0228),
    {cmd:LCD} ({it:K_L} = .77, {it:c_1} = .007, {it:c_2} = .0053),
    or {cmd:SCD} ({it:K_L} = 1.24, {it:c_1} = .007, {it:c_2} = .0363)
    (abbreviations and lowercase letters allowed). To to retrieve a 1 x 3 rowvector
    of the current default coefficients, type

        {it:ucscoefs} = {it:S}{cmd:.ucscoefs()}

{pstd}
    See {browse "http://doi.org/10.1007/978-1-4419-6190-7_2":Luo and Li (2013, chapter 2.6.1)}
    and {browse "http://doi.org/10.1002/col.20227":Luo et al. (2006)} for details on these coefficients.


{marker chadapt}{...}
{title:Setting the chromatic adaption method}

{pstd}
    To set the chromatic adaption method type

        {it:S}{cmd:.chadapt(}{it:method}{cmd:)}

{pstd}
    where {it:method} is {cmd:"Bfd"} (Bradford), {cmd:"identity"} (XYZ Scaling),
    {cmd:"vKries"} (Von Kries), or {cmd:"CAT02"} (abbreviations and lowercase
    letters allowed). The default is {it:S}{cmd:.chadapt("Bfd")}, which can also be selected
    by typing {it:S}{cmd:.chadapt("")}. The Bradford, XYZ Scaling, and Von Kries methods use the
    procedure described in
    {browse "http://www.brucelindbloom.com/Eqn_ChromAdapt.html":Lindbloom (2017a)},
    the {cmd:"CAT02"} method uses the procedure described in
    {browse "http://doi.org/10.1007/978-1-4419-6190-7_2":Luo and Li (2013)}
    (page 33). To retrieve a string scalar containing the current method, type

        {it:method} = {it:S}{cmd:.chadapt()}

{pstd}
    {cmd:ColrSpace} uses chromatic adaption internally whenever such a
    translation is necessary. However, you can also apply chromatic adaption
    manually by typing

        {it:XYZnew} = {it:S}{cmd:.XYZ_to_XYZ(}{it:XYZ}{cmd:,} {it:from}{cmd:,} {it:to}{cmd:)}

{pstd}
    where {it:XYZ} is an {it:n} x 3 matrix of XYZ values to be adapted, {it:from} is the
    origin whitepoint, and {it:to} is the destination whitepoint; any single-argument whitepoint
    specification as described in {help colrspace##xyzwhite:Setting the XYZ reference white}
    is allowed. Function {it:S}{cmd:.XYZ_to_XYZ()} does not change or store any colors in {it:S}.

{pstd}
    To retrieve the predefined transformation matrices on which chromatic adaption is based,
    type

        {it:M} = {it:S}{cmd:.tmatrix(}{it:name}{cmd:)}

{pstd}
    where {it:name} is {cmd:"Bfd"}, {cmd:"identity"},
    {cmd:"vKries"}, {cmd:"CAT02"}, or {cmd:"HPE"} (Hunt-Pointer-Estevez)
    (abbreviations and lowercase letters allowed). The default is {it:S}{cmd:.tmatrix("Bfd")},
    which can also be selected by typing {it:S}{cmd:.tmatrix("")}. The
    {cmd:"HPE"} matrix is not used for chromatic adaption but has been included in
    {it:S}{cmd:.tmatrix()} for convenience. It is used when translating colors
    from XYZ to CIECAM02; see {browse "http://doi.org/10.1007/978-1-4419-6190-7_2":Luo and Li (2013)}.


{marker string}{...}
{title:String input/output (Stata interface)}

{dlgtab:Color input}

{pstd}
    To import colors from a string scalar {it:colors} containing a list of color
    specifications, type

        {it:S}{cmd:.}[{cmd:add_}]{cmd:colors(}{it:colors}[{cmd:,} {it:delimiter}]{cmd:)}

{pstd}
    where string scalar {it:delimiter} sets the character(s) delimiting the specifications;
    the default is to assume a space-separated list, i.e. {it:delimiter} = {cmd:" "}. To
    avoid breaking a specification that contains a delimiting character, enclose the
    specification in double quotes. {it:S}{cmd:.colors()} will replace
    preexisting colors in {it:S} by the new colors; alternatively, use
    {it:S}{cmd:.add_colors()} to append the new colors to the existing colors.

{pstd}
    To import colors from a string vector {it:Colors} (each
    element containing a single color specification), type

        {it:S}{cmd:.}[{cmd:add_}]{cmd:Colors(}{it:Colors}{cmd:)}

{pstd}
    The syntax for a single color specification is

        {it:color}[{cmd:%}{it:#}][*{it:#}]

{pstd}
    where {cmd:%}{it:#} sets the opacity (in percent; 0 = fully transparent,
    100 = fully opaque), {cmd:*}{it:#} sets the intensity adjustment multiplier
    (values between 0 and 1 make the color lighter; values larger than one
    make the color darker), and {it:color} is one of the following:

{marker strinput}{...}
{p2colset 9 28 30 2}{...}
{p2col:{help colorstyle##colorstyle:{it:name}}}official Stata color name as listed in {help colorstyle##colorstyle:{it:colorstyle}}{p_end}
{p2col:{help colrspace##webcolors:{it:webname}}}web color name as listed {help colrspace##webcolors:below}{p_end}
{p2col:{cmd:#}{it:rrggbb}}6-digit hex RGB value; white = {cmd:#FFFFFF} or {cmd:#ffffff}, navy = {cmd:#1A476F} or {cmd:#1a476f} {p_end}
{p2col:{cmd:#}{it:rgb}}3-digit abbreviated hex RGB value; white = {cmd:#FFF} or {cmd:#fff}{p_end}
{p2col:{it:# # #}}RGB value in 0-255 scaling; navy = {cmd:"26 71 111"}{p_end}
{p2col:{it:# # # #}}CMYK value in 0-255 or 0-1 scaling; navy = {cmd:"85 40 0 144"} or {cmd:".333 .157 0 .565"}{p_end}
{p2col:{cmd:RGB }{it:# # #}}RGB value in 0-255 scaling; navy = {cmd:"RGB 26 71 111"}{p_end}
{p2col:{cmd:RGB1 }{it:# # #}}RGB value in 0-1 scaling; navy = {cmd:"RGB1 .102 .278 .435"} {p_end}
{p2col:{cmd:lRGB }{it:# # #}}linear RGB value in 0-1 scaling; navy = {cmd:"lRGB .0103 .063 .159"}{p_end}
{p2col:{cmd:CMYK }{it:# # # #}}CMYK value in 0-255 scaling; navy = {cmd:"CMYK 85 40 0 144"}{p_end}
{p2col:{cmd:CMYK1 }{it:# # # #}}CMYK value in 0-1 scaling; navy = {cmd:"CMYK1 .333 .157 0 .565"}{p_end}
{p2col:{cmd:HSV }{it: # # #}}HSV value; navy = {cmd:"HSV 208 .766 .435"}{p_end}
{p2col:{cmd:HSL }{it:# # #}}HSL value; navy = {cmd:"HSL 208 .620 .269"}{p_end}
{p2col:{cmd:XYZ }{it:# # #}}CIE XYZ value in 0-100 scaling; navy = {cmd:"XYZ 5.55 5.87 15.9"}{p_end}
{p2col:{cmd:XYZ1 }{it:# # #}}CIE XYZ value in 0-1 scaling; navy = {cmd:"XYZ1 .0555 .0587 .159"}{p_end}
{p2col:{cmd:xyY }{it:# # #}}CIE xyY value with Y in 0-100 scaling; navy = {cmd:"xyY .203 .215 5.87"}{p_end}
{p2col:{cmd:xyY1 }{it:# # #}}CIE xyY value with Y in 0-1 scaling; navy = {cmd:"xyY1 .203 .215 .0587"}{p_end}
{p2col:{cmd:Lab }{it:# # #}}CIE L*a*b* value; navy = {cmd:"Lab 29 -.4 -27.5"}{p_end}
{p2col:{cmd:LCh }{it:# # #}}LCh value (polar CIE L*a*b*); navy = {cmd:"LCh 29 27.5 269.2"}{p_end}
{p2col:{cmd:Luv }{it:# # #}}CIE L*u*v* value; navy = {cmd:"Luv 29 -15.4 -35.6"}{p_end}
{p2col:{cmd:HCL }{it:# # #}}HCL value (polar CIE L*u*v*); navy = {cmd:"HCL 246.6 38.8 29"}{p_end}
{p2col:{cmd:CAM02 }[{help colrspace##CAM02:{it:mask}}] {it:...}}CIECAM02 value according to {help colrspace##CAM02:{it:mask}}; navy = {cmd:"CAM02 JCh 20.2 37 245"} or {cmd:"CAM02 QsH 55.7 69.5 303.5"}{p_end}
{p2col:{cmd:JMh }[{help colrspace##JMh:{it:coefs}}] {it:# # #}}CIECAM02 J'M'h value; navy = {cmd:"JMh 30.1 21 245"}{p_end}
{p2col:{cmd:Jab }[{help colrspace##JMh:{it:coefs}}] {it:# # #}}CIECAM02 J'a'b' value; navy = {cmd:"Jab 30.1 -8.9 -19"} or {cmd:"Jab LCD 39 -10.6 -23"}{p_end}
{p2col:{cmd:RGBA }{it:# # # #}}RGB 0-255 value where the last number specifies the opacity in [0,1]{p_end}
{p2col:{cmd:RGBA1 }{it:# # # #}}RGB 0-1 value where the last number specifies the opacity in [0,1] {p_end}

{pmore}
    The colorspace labels (but not {it:mask}) can be typed in lowercase
    letters. The provided examples are for standard viewing conditions.

{marker webcolors}{...}
{pstd}
    {it:webname} is one of the following (see {browse "http://www.w3schools.com/colors/colors_names.asp"}):

{pmore}
    {cmd:AliceBlue}, {cmd:AntiqueWhite}, {cmd:Aqua}, {cmd:Aquamarine}, {cmd:Azure},
    {cmd:Beige}, {cmd:Bisque}, {cmd:Black}, {cmd:BlanchedAlmond}, {cmd:Blue},
    {cmd:BlueViolet}, {cmd:Brown}, {cmd:BurlyWood}, {cmd:CadetBlue},
    {cmd:Chartreuse}, {cmd:Chocolate}, {cmd:Coral}, {cmd:CornflowerBlue},
    {cmd:Cornsilk}, {cmd:Crimson}, {cmd:Cyan}, {cmd:DarkBlue}, {cmd:DarkCyan},
    {cmd:DarkGoldenRod}, {cmd:DarkGray}, {cmd:DarkGrey}, {cmd:DarkGreen},
    {cmd:DarkKhaki}, {cmd:DarkMagenta}, {cmd:DarkOliveGreen}, {cmd:DarkOrange},
    {cmd:DarkOrchid}, {cmd:DarkRed}, {cmd:DarkSalmon}, {cmd:DarkSeaGreen},
    {cmd:DarkSlateBlue}, {cmd:DarkSlateGray}, {cmd:DarkSlateGrey},
    {cmd:DarkTurquoise}, {cmd:DarkViolet}, {cmd:DeepPink}, {cmd:DeepSkyBlue},
    {cmd:DimGray}, {cmd:DimGrey}, {cmd:DodgerBlue}, {cmd:FireBrick},
    {cmd:FloralWhite}, {cmd:ForestGreen}, {cmd:Fuchsia}, {cmd:Gainsboro},
    {cmd:GhostWhite}, {cmd:Gold}, {cmd:GoldenRod}, {cmd:Gray}, {cmd:Grey},
    {cmd:Green}, {cmd:GreenYellow}, {cmd:HoneyDew}, {cmd:HotPink}, {cmd:IndianRed},
    {cmd:Indigo}, {cmd:Ivory}, {cmd:Khaki}, {cmd:Lavender}, {cmd:LavenderBlush},
    {cmd:LawnGreen}, {cmd:LemonChiffon}, {cmd:LightBlue}, {cmd:LightCoral},
    {cmd:LightCyan}, {cmd:LightGoldenRodYellow}, {cmd:LightGray}, {cmd:LightGrey},
    {cmd:LightGreen}, {cmd:LightPink}, {cmd:LightSalmon}, {cmd:LightSeaGreen},
    {cmd:LightSkyBlue}, {cmd:LightSlateGray}, {cmd:LightSlateGrey},
    {cmd:LightSteelBlue}, {cmd:LightYellow}, {cmd:Lime}, {cmd:LimeGreen},
    {cmd:Linen}, {cmd:Magenta}, {cmd:Maroon}, {cmd:MediumAquaMarine},
    {cmd:MediumBlue}, {cmd:MediumOrchid}, {cmd:MediumPurple}, {cmd:MediumSeaGreen},
    {cmd:MediumSlateBlue}, {cmd:MediumSpringGreen}, {cmd:MediumTurquoise},
    {cmd:MediumVioletRed}, {cmd:MidnightBlue}, {cmd:MintCream}, {cmd:MistyRose},
    {cmd:Moccasin}, {cmd:NavajoWhite}, {cmd:Navy}, {cmd:OldLace}, {cmd:Olive},
    {cmd:OliveDrab}, {cmd:Orange}, {cmd:OrangeRed}, {cmd:Orchid},
    {cmd:PaleGoldenRod}, {cmd:PaleGreen}, {cmd:PaleTurquoise}, {cmd:PaleVioletRed},
    {cmd:PapayaWhip}, {cmd:PeachPuff}, {cmd:Peru}, {cmd:Pink}, {cmd:Plum},
    {cmd:PowderBlue}, {cmd:Purple}, {cmd:RebeccaPurple}, {cmd:Red},
    {cmd:RosyBrown}, {cmd:RoyalBlue}, {cmd:SaddleBrown}, {cmd:Salmon},
    {cmd:SandyBrown}, {cmd:SeaGreen}, {cmd:SeaShell}, {cmd:Sienna}, {cmd:Silver},
    {cmd:SkyBlue}, {cmd:SlateBlue}, {cmd:SlateGray}, {cmd:SlateGrey}, {cmd:Snow},
    {cmd:SpringGreen}, {cmd:SteelBlue}, {cmd:Tan}, {cmd:Teal}, {cmd:Thistle},
    {cmd:Tomato}, {cmd:Turquoise}, {cmd:Violet}, {cmd:Wheat}, {cmd:White},
    {cmd:WhiteSmoke}, {cmd:Yellow}, {cmd:YellowGreen}

{pmore}
    The names can be abbreviated and typed in lowercase letters. If abbreviation is
    ambiguous, the first matching name in the alphabetically ordered list will be used. In
    case of name conflict, official Stata colors will take precedence over web colors; use
    the uppercase names as shown above to prevent such conflict (for example, {cmd:pink} will refer
    to official Stata pink, {cmd:Pink} will refer to web color pink).

{pstd}
    Example:

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.colors("LightCyan MediumAqua BurlyWood")"'}
        . {stata "colorpalette mata(S)"}
        . {stata `"mata: S.add_colors("SeaShell Crimson")"'}
        . {stata "colorpalette mata(S)"}
        . {stata `"mata: S.colors("#337ab7, lab 50 -23 32, xyz 80 30 40, hcl 200 50 30", ",")"'}
        . {stata "colorpalette mata(S)"}
        . {stata `"mata: S.colors("navy*.5 orange%80 maroon*.7%60")"'}
        . {stata "colorpalette mata(S)"}

{dlgtab:Color output}

{pstd}
    To export colors into a string scalar containing a space-separated list of
    color specifications compatible with Stata graphics, type

        {it:colors} = {it:S}{cmd:.colors}[{cmd:_added}]{cmd:(}[{it:rgbforce}]{cmd:)}

{pstd}
    where {it:rgbforce}!=0 enforces exporting all colors using their in RGB
    values. Colors that have been defined in terms of their Stata color names or
    CMYK values are exported as is by default, because these
    specifications are understood by Stata graphics. Specify {it:rgbforce}!=0
    to export these colors as RGB values. {it:S}{cmd:.colors()} exports all
    colors; use {it:S}{cmd:.colors_added()} to export only the colors that have
    been added last.

{pstd}
    To export colors into a string column vector (each
    row containing a single color specification), type

        {it:Colors} = {it:S}{cmd:.Colors}[{cmd:_added}]{cmd:(}[{it:rgbforce}]{cmd:)}

{pstd}
    Example:

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.colors("navy*.5 orange%80 maroon*.7%60")"'}
        . {stata "mata: S.colors()"}
        . {stata "mata: S.colors(1)"}
        . {stata `"mata: S.add_colors("SeaShell Crimson")"'}
        . {stata "mata: S.colors_added()"}

{marker info}{...}
{dlgtab:Description input}

{pstd}
    To import information from a string scalar {it:info} containing a list of color
    descriptions (e.g. color names or other text describing a color), type

        {it:S}{cmd:.info}[{cmd:_added}]{cmd:(}{it:info}[{cmd:,} {it:delimiter}]{cmd:)}

{pstd}
    where string scalar {it:delimiter} sets the character(s) delimiting the descriptions;
    the default is to assume a space-separated list, i.e. {it:delimiter} = {cmd:" "}. To
    avoid breaking a description that contains a delimiting character, enclose
    the description in double quotes. {it:S}{cmd:.info()} affects all colors
    defined in {it:S}; use {it:S}{cmd:.colors_added()} to affect only the
    colors that have been added last.

{pstd}
    To import descriptions from a string vector {it:Info} (each
    element containing a single color description), type

        {it:S}{cmd:.Info}[{cmd:_added}]{cmd:(}{it:Info}{cmd:)}

{pstd}
    Note that redefining the colors, e.g. by applying {it:S}{cmd:.colors(}{it:colors}{cmd:)}
    or {it:S}{cmd:.set()}, will delete existing color descriptions.

{pstd}
    Example (colors from {browse "http://getbootstrap.com/docs/3.3/"}):

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.colors("#337ab7 #5cb85c #5bc0de #f0ad4e #d9534f")"'}
        . {stata `"mata: S.info("primary success info warning danger")"'}
        . {stata `"mata: S.pname("Bootstrap 3.3 colors")"'}
        . {stata "colorpalette mata(S)"}

{dlgtab:Description output}

{pstd}
    To export color descriptions into a string scalar containing a
    space-separated list of the descriptions, type

        {it:info} = {it:S}{cmd:.info}[{cmd:_added}]{cmd:(}[{it:rgbforce}]{cmd:)}

{pstd}
    where {it:rgbforce}!=0 changes the type of descriptions that are
    exported. By default, {it:S}{cmd:.info()} exports whatever descriptions
    have been defined. That is, empty string will be exported for colors
    that have no description. However, if {it:rgbforce}!=0 is specified,
    descriptions are automatically generated for colors that have no
    description but have been defined in terms of their Stata color names or
    CMYK values. Specifying {it:rgbforce}!=0 primarily makes sense in
    connection with specifying {it:rgbforce}!=0 when calling
    {it:S}{cmd:.colors()}. {it:S}{cmd:.info()} exports descriptions from all
    colors; use {it:S}{cmd:.info_added()} to export descriptions only from the
    colors that have been added last.

{pstd}
    Alternatively, to export the color descriptions into a string column vector (each
    row containing a single description) type

        {it:Info} = {it:S}{cmd:.Info}[{cmd:_added}]{cmd:(}[{it:rgbforce}]{cmd:)}

{pstd}
    Example:

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.colors("navy*.5 orange%80 maroon*.7%60 SeaShell Crimson")"'}
        . {stata "mata: S.colors()"}
        . {stata "mata: S.info()"}
        . {stata "mata: S.colors(1)"}
        . {stata "mata: S.info(1)"}


{marker io}{...}
{title:Import/export colors in various spaces}

{dlgtab:Import colors}

{pstd}
    As an alternative to {it:S}{cmd:.colors()}, colors can be imported into
    {it:S} using the following functions:

        {it:S}{cmd:.set(}{it:C}[{cmd:,} {it:space}]{cmd:)}
        {it:S}{cmd:.add(}{it:C}[{cmd:,} {it:space}]{cmd:)}
        {it:S}{cmd:.reset}[{cmd:_added}]{cmd:(}{it:C}[{cmd:,} {it:space}{cmd:,} {it:p}]{cmd:)}

{pstd}
    {it:S}{cmd:.set()} replaces preexisting colors by the new
    colors; use {it:S}{cmd:.add()} if you want to append the new colors to the
    existing colors. {it:S}{cmd:.reset()} can be used to reset the values of
    colors, without reinitializing opacity and intensity
    adjustment; {it:S}{cmd:.reset_added()} is like {it:S}{cmd:.reset()}
    but only operates on the colors that have been added last. The arguments are as
    follows.

{phang}
    {it:C} provides the color values. In case of {it:space} = {cmd:"HEX"},
    {it:C} is a string vector of length {it:n} containing {it:n} hex RGB
    values; in case of {it:space} = {cmd:"CMYK"}, {cmd:"CMYK1"}, {cmd:"RGBA"}, 
    or {cmd:"RGBA1"}, {it:C} is a {it:n} x 4 real matrix; in case of {it:space} =
    {bind:{cmd:"CAM02} {it:mask}{cmd:"}}, {it:C} is a {it:n} x
    {cmd:strlen(}{it:mask}{cmd:)} real matrix; in all
    other cases, {it:C} is a {it:n} x 3 real matrix of {it:n} color values
    in the respective space. In case of {it:S}{cmd:.reset()} the number of colors in
    {it:C} must match the length of {it:p}.

{phang}
    {it:space} is a string scalar specifying the color space of {it:C}. It can
    be {cmd:"HEX"}, {cmd:"RGB"}, {cmd:"RGB1"}, {cmd:"lRGB"}, {cmd:"HSV"},
    {cmd:"HSL"}, {cmd:"CMYK"}, {cmd:"CMYK1"}, {cmd:"XYZ"}, {cmd:"XYZ1"},
    {cmd:"xyY"}, {cmd:"xyY1"}, {cmd:"Lab"}, {cmd:"LCh"}, {cmd:"Luv",}
    {cmd:"HCL"}, {cmd:"CAM02} [{help colrspace##CAM02:{it:mask}}]{cmd:"},
    {cmd:"JMh} [{it:{help colrspace##JMh:coefs}}]{cmd:"},
    {cmd:"Jab} [{it:{help colrspace##JMh:coefs}}]{cmd:"}, {cmd:"RGBA"}, or {cmd:"RGBA1"}
    (lowercase spelling allowed). The default is {cmd:"RGB"}. This default can
    also be selected by typing {cmd:""}.

{phang}
    {it:p} is a real vector of the positions of the colors to be modified.
    Positive numbers refer to colors from the start; negative numbers refer to
    colors from the end. {it:S}{cmd:.reset()} aborts with error if {it:p}
    addresses positions that do not exists. If {it:p} is omitted, the default
    is to modify all colors. This default can also be selected by typing
    {cmd:.} (missing).

{pstd}
    Example:

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.set((100,150,200) \ (200,50,50), "RGB")"'}
        . {stata `"mata: S.add((100,50,50) \ (200,50,50) \ (300,50,50), "HCL")"'}
        . {stata "colorpalette mata(S)"}
        . {stata `"mata: S.reset((100,50,50) \ (100,-20,10), "Luv", (2,-1))"'}
        . {stata "colorpalette mata(S)"}
        . {stata `"mata: S.set((100,150,200,.8) \ (200,50,50,.7) \ (100,200,50,1), "RGBA")"'}
        . {stata "colorpalette mata(S)"}

{marker get}{...}
{dlgtab:Export colors}

{pstd}
    To retrieve the colors from {it:S} and return them in a particular
    color space, type

        {it:C} = {it:S}{cmd:.get}[{cmd:_added}]{cmd:(}[{it:space}]{cmd:)}

{pstd}
    where {it:space} is a string scalar specifying the color space. It can
    be {cmd:"HEX"}, {cmd:"RGB"}, {cmd:"RGB1"}, {cmd:"lRGB"}, {cmd:"HSV"},
    {cmd:"HSL"}, {cmd:"CMYK"}, {cmd:"CMYK1"}, {cmd:"XYZ"}, {cmd:"XYZ1"},
    {cmd:"xyY"}, {cmd:"xyY1"}, {cmd:"Lab"}, {cmd:"LCh"}, {cmd:"Luv",}
    {cmd:"HCL"}, {cmd:"CAM02} [{help colrspace##CAM02:{it:mask}}]{cmd:"},
    {cmd:"JMh} [{it:{help colrspace##JMh:coefs}}]{cmd:"},
    {cmd:"Jab} [{it:{help colrspace##JMh:coefs}}]{cmd:"}, {cmd:"RGBA"}, or {cmd:"RGBA1"}
    (lowercase spelling allowed). The default is {cmd:"RGB"}. This default can
    also be selected by typing {cmd:""}. {it:S}{cmd:.get()} returns all
    colors; {it:S}{cmd:.get_added()} only returns the colors that have been
    added last.

{pstd}
    Example:

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.palette("s2",5)"'}
        . {stata `"mata: S.Colors()"'}
        . {stata `"mata: S.get()"'}
        . {stata `"mata: S.get("RGB1")"'}
        . {stata `"mata: S.get("lRGB")"'}
        . {stata `"mata: S.get("XYZ")"'}
        . {stata `"mata: S.get("Lab")"'}
        . {stata `"mata: S.get("Jab")"'}
        . {stata `"mata: S.get("Jab LCD")"'}
        . {stata `"mata: S.get("CAM02 QsH")"'}
        . {stata `"mata: S.opacity((100,90,80,70,60))"'}
        . {stata `"mata: S.get("RGBa")"'}

{marker convert}{...}
{dlgtab:Convert colors without storing}

{pstd}
    Instead of storing colors in {it:S} using {it:S}{cmd:.set()} and then
    retrieving the colors in a particular space using function {it:S}{cmd:.get()},
    colors can also be converted directly from from one space to another using the
    {it:S}{cmd:.convert()} function. {it:S}{cmd:.convert()} will not
    store any colors or otherwise manipulate the content of {it:S}. The
    syntax is:

        {it:C} = {it:S}{cmd:.convert(}{it:C0}{cmd:,} {it:from}{cmd:,} {it:to}{cmd:)}

{pstd}
    where {it:C0} is a matrix of input colors values in color space {it:from},
    and {it:to} is a destination color space. {it:from} and {it:to} can be
    {cmd:"HEX"}, {cmd:"RGB"}, {cmd:"RGB1"}, {cmd:"lRGB"}, {cmd:"HSV"},
    {cmd:"HSL"}, {cmd:"CMYK"}, {cmd:"CMYK1"}, {cmd:"XYZ"}, {cmd:"XYZ1"},
    {cmd:"xyY"}, {cmd:"xyY1"}, {cmd:"Lab"}, {cmd:"LCh"}, {cmd:"Luv",}
    {cmd:"HCL"}, {cmd:"CAM02} [{help colrspace##CAM02:{it:mask}}]{cmd:"},
    {cmd:"JMh} [{it:{help colrspace##JMh:coefs}}]{cmd:"}, or
    {cmd:"Jab} [{it:{help colrspace##JMh:coefs}}]{cmd:"}
    (lowercase spelling allowed). The default is {cmd:"RGB"}. This default can
    also be selected by typing {cmd:""}. If {it:from} is {cmd:"HEX"}, {it:C0} is
    a string vector containing {it:n} hex colors. In all other cases, {it:C0} is a
    {it:n} x {it:c} real matrix of {it:n} color values in the respective
    coding scheme. See the diagram in {help colrspace##cspace:Color spaces}
    for the paths along which the colors will be translated.

{pstd}
    Example:

        . {stata "mata: S = ColrSpace()"}
        . {stata "mata: RGB = (25, 70, 120) \ (150, 60, 60)"}
        . {stata `"mata: S.convert(RGB, "RGB", "xyY")"'}
        . {stata `"mata: S.convert(RGB, "RGB", "JMh")"'}
        . {stata `"mata: Jab = S.convert(RGB, "RGB", "Jab")"'}
        . {stata `"mata: S.convert(Jab, "Jab", "HSV")"'}
        . {stata `"mata: HCL = S.convert(Jab, "Jab", "HCL")"'}
        . {stata `"mata: S.convert(HCL, "HCL", "RGB")"'}


{pstd}
    {it:S}{cmd:.convert()} can also be used for grayscale conversion or
    color vision deficiency simulation (see below). The syntax is

        {it:C} = {it:S}{cmd:.convert(}{it:C0}{cmd:,} {it:from}{cmd:,} {cmd:"gray"}[{cmd:,} {it:proportion}{cmd:,} {it:method}]{cmd:)}

        {it:C} = {it:S}{cmd:.convert(}{it:C0}{cmd:,} {it:from}{cmd:,} {cmd:"cvd"}[{cmd:,} {it:severity}{cmd:,} {it:type}]{cmd:)}

{pstd}
    where {it:proportion} and {it:method} are as described in
    {help colrspace##gray:Grayscale conversion} and {it:severity} and
    {it:type} are as described in
    {help colrspace##cvd:Color vision deficiency simulation}. The adjusted colors will
    be returned in the same color space or coding scheme as the input colors.


{marker opint}{...}
{title:Set/retrieve opacity and intensity}

{dlgtab:Set opacity}

{pstd}
    To set the opacity of the colors in {it:S}, type

        {it:S}{cmd:.}[{cmd:add_}]{cmd:opacity}[{cmd:_added}]{cmd:(}{it:opacity}[{cmd:,} {it:noreplace}]{cmd:)}

{pstd}
    {it:S}{cmd:.opacity()} sets opacify for all existing colors; use
    {it:S}{cmd:.opacity_added()} if you only want to set opacify for the
    colors that have been added last. Furthermore, use
    {it:S}{cmd:.add_opacity()} or {it:S}{cmd:.add_opacity_added()}
    to leave the existing colors unchanged and append a copy of the colors with the
    new opacity settings. Arguments are as follows.

{phang}
    {it:opacity} is a real vector of opacity values in [0,100]. A value of 0
    makes the color fully transparent, a value of 100 makes the color fully
    opaque. If the number of specified opacity values is smaller than the
    number of existing colors, the opacity values will be recycled;
    if the number of opacity values is larger than the number of colors, the
    colors will be recycled. To skip assigning opacity to a particular
    color, you may set the corresponding element in {it:opacity} to
    {cmd:.} (missing).

{phang}
    {it:noreplace}!=0 specifies that existing opacity values should not be
    replaced. By default, {it:S}{cmd:.opacity()} resets opacity for all colors
    irrespective of whether they already have an opacity value or not.

{dlgtab:Retrieving opacity}

{pstd}
    To retrieve a real colvector containing the opacity values of the colors in
    {it:S}, type

        {it:opacity} = {it:S}{cmd:.opacity}[{cmd:_added}]{cmd:()}

{pstd}
    {it:opacity} will be equal to {cmd:.} (missing) for colors that do not have
    an opacity value. {it:S}{cmd:.opacity()} returns the opacity values of all
    colors; {it:S}{cmd:.opacity_added()} only returns the opacity values of the
    colors that have been added last.

{marker intensity}{...}
{dlgtab:Setting intensity}

{pstd}
    To set the intensity adjustment multipliers of the colors in {it:S}, type

        {it:S}{cmd:.}[{cmd:add_}]{cmd:intensity}[{cmd:_added}]{cmd:(}{it:intensity}[{cmd:,} {it:noreplace}]{cmd:)}

{pstd}
    {it:S}{cmd:.intensity()} sets the intensity multipliers for all existing colors; use
    {it:S}{cmd:.intensity_added()} if you only want to set intensity for the
    colors that have been added last. Furthermore, use
    {it:S}{cmd:.add_intensity()} and {it:S}{cmd:.add_intensity_added()}
    to leave the existing colors unchanged and append a copy of the colors with the
    new intensity settings. Arguments are as follows.

{phang}
    {it:intensity} is a real vector of intensity adjustment multipliers in [0,255]. A multiplier
    smaller than 1 makes the color lighter, a multiplier larger than one make the
    color darker. If the number of specified intensity multipliers is smaller than
    the number of existing colors, the intensity multipliers will be
    recycled; if the number of intensity multipliers is larger than the number of
    colors, the colors will be recycled. To skip assigning an intensity multiplier to
    a particular color, you may set the corresponding element in {it:intensity}
    to {cmd:.} (missing).

{phang}
    {it:noreplace}!=0 specifies that existing intensity adjustment multipliers should not be
    replaced. By default, {it:S}{cmd:.intensity()} resets the intensity multipliers for all colors
    irrespective of whether they already have an intensity multipliers or not.

{pstd}
    Note that {it:S}{cmd:.intensity()} does not manipulate the stored
    coordinates of a color, it just adds an extra piece of information. This
    extra information, the intensity multiplier, is added to a color
    specification when exporting the colors using {it:S}{cmd:.colors()}. If you want
    to actually transform the stored color values instead of just recording
    an intensity multiplier, you can use function
    {helpb colrspace##intensify:{it:S}.intensify()}.

{dlgtab:Retrieving intensity}

{pstd}
    To retrieve a real colvector containing the intensity adjustment
    multipliers of the colors in {it:S}, type

        {it:intensity} = {it:S}{cmd:.intensity}[{cmd:_added}]{cmd:()}

{pstd}
    {it:intensity} will be equal to {cmd:.} (missing) for colors that do not have
    an intensity multiplier. {it:S}{cmd:.intensity()} returns the intensity multipliers of all
    colors; {it:S}{cmd:.intensity_added()} only returns the intensity multipliers of the
    colors that have been added last.

{dlgtab:Examples}

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.palette("s2", 4)"'}
        . {stata "mata: S.opacity((., 80, ., 60))"}
        . {stata "mata: S.intensity((.7, ., .8, .))"}
        . {stata "mata: S.Colors()"}

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.colors("cranberry")"'}
        . {stata "mata: S.intensity(range(1,.1,.10))"}
        . {stata "colorpalette mata(S)"}


{marker ipolate}{...}
{title:Interpolate, mix, recycle, select, order}

{dlgtab:Interpolation}

{pstd}
    To apply linear interpolation to the colors in {it:S}, type:

        {it:S}{cmd:.}[{cmd:add_}]{cmd:ipolate}[{cmd:_added}]{cmd:(}{it:n}[{cmd:,} {it:space}{cmd:,} {it:range}{cmd:,} {it:power}{cmd:,} {it:positions}{cmd:,} {it:padded}]{cmd:)}

{pstd}
    Opacity values and intensity adjustment multipliers, if existing, will also be interpolated.
    {it:S}{cmd:.ipolate()} takes all existing colors as input and replaces them with
    the interpolated colors; use {it:S}{cmd:.ipolate_added()} if you only want to interpolate the
    colors added last. Furthermore, use {it:S}{cmd:.add_ipolate()} or {it:S}{cmd:.add_ipolate_added()}
    to leave the existing colors unchanged and append the interpolated
    colors. Arguments are as follows.

{phang}
    {it:n} is a real scalar specifying the number of destination colors. {it:S}{cmd:.ipolate()}
    will interpolate the existing (origin) colors to {it:n} new
    colors (thus increasing or decreasing the number of colors, depending on whether
    {it:n} is larger or smaller than the number of origin colors).

{phang}
    {it:space} selects the color space in which the colors are
    interpolated. {it:space} can be {cmd:"RGB"}, {cmd:"lRGB"}, {cmd:"HSV"},
    {cmd:"HSL"}, {cmd:"CMYK"}, {cmd:"XYZ"},
    {cmd:"xyY"}, {cmd:"Lab"}, {cmd:"LCh"}, {cmd:"Luv",}
    {cmd:"HCL"}, {cmd:"CAM02} [{help colrspace##CAM02:{it:mask}}]{cmd:"},
    {cmd:"JMh} [{it:{help colrspace##JMh:coefs}}]{cmd:"}, or
    {cmd:"Jab} [{it:{help colrspace##JMh:coefs}}]{cmd:"}
    (lowercase spelling allowed). The default is
    {cmd:"Jab}. This default can also be selected by typing {cmd:""}. When
    interpolating from one hue to the next (relevant for {cmd:"HSV"},
    {cmd:"HSL"}, {cmd:"LCh"}, {cmd:"HCL"}, {cmd:"JMh}, and {cmd:"CAM02"} when
    {it:mask} contains {cmd:h}), {it:S}{cmd:.ipolate()} will travel around the
    color wheel in the direction in which the two hues are closer to each other.

{phang}
    {it:range} = {cmd:(}{it:lb}[{cmd:,} {it:ub}]{cmd:)} specifies range of the
    destination colors. The default is {cmd:(0,1)}. This default can also be
    selected by typing {cmd:.} (missing). If {it:lb} is larger than {it:ub},
    the destination colors will be arranged in reverse order. Extrapolation
    will be applied if the specified range exceeds [0,1].

{phang}
    {it:power} is a real scalar affecting the distribution of the destination
    colors across {it:range}. The default is to distribute them evenly. This
    default can also be selected by typing {cmd:.} (missing) or setting
    {it:power} to 1. A {it:power} value larger than 1 squishes the positions
    towards {it:lb}. If interpolating between two colors, this means that the
    first color will dominate most of the interpolation range (slow to fast
    transition). A value between 0 and 1 squishes the positions towards
    {it:ub}, thus making the second color the dominant color for most of the
    range (fast to slow transition). Another way to think of the effect of
    {it:power} is that it moves the center of the color gradient up (if {it:power}
    is larger than 1) or down (if {it:power} is between 0 and 1).

{phang}
    {it:positions} is a real vector specifying the positions of the origin
    colors. The default is to place them on a regular grid from 0
    and 1. This default can also be selected by typing {cmd:.} (missing). If 
    {it:positions} has less elements than there are colors, default 
    positions are used for the remaining colors. If the same position is 
    specified for multiple colors, these colors will be averaged before 
    applying interpolation.

{phang}
    {it:padded}!=0 requests padded interpolation. By default, if {it:padded} is
    omitted or equal to 0, the first color and the last color are taken as the
    end points of the interpolation range; these colors thus remain unchanged
    (as long as default settings are used for {it:range} and {it:position}). If
    {it:padded}!=0, the positions of the colors are interpreted as interval
    midpoints, such that the interpolation range is padded by half an interval on
    each side. This causes the destination colors to be spread out slightly
    more (less) than the origin colors, if the number of destination colors is
    larger (smaller) than the number of origin colors.

{pstd}
    Examples:

        . {stata "mata: Jab = ColrSpace()"}
        . {stata `"mata: Jab.colors("#337ab7 #f0ad4e")"'}
        . {stata `"mata: JMh = J(1, 1, Jab)"'}             {it:(make copy)}
        . {stata `"mata: Jab.ipolate(30)"'}
        . {stata `"mata: JMh.ipolate(30, "JMh")"'}
        . {stata "colorpalette: mata(Jab) / mata(JMh)"}

        . {stata "mata: A = ColrSpace()"}
        . {stata `"mata: A.colors("#fafa6e #2A4858")"'}
        . {stata `"mata: B = C = D = J(1, 1, A)"'}         {it:(make copies)}
        . {stata `"mata: A.ipolate(30, "HCL")"'}
        . {stata `"mata: B.ipolate(30, "HCL", (.1,.9))"'}  {it:(select range)}
        . {stata `"mata: C.ipolate(30, "HCL", ., 1.5)"'}   {it:(make 1st color dominant)}
        . {stata `"mata: D.ipolate(30, "HCL", ., .6)"'}    {it:(make 2nd color dominant)}
        . {stata "colorpalette: mata(A) / mata(B) / mata(C) / mata(D)"}

        . {stata "mata: A = ColrSpace()"}
        . {stata `"mata: A.colors("black red yellow")"'}
        . {stata `"mata: B = C = J(1, 1, A)"'}
        . {stata `"mata: A.ipolate(30)"'}                       {it:(red in middle)}
        . {stata `"mata: B.ipolate(30, "", ., ., (0, .3, 1))"'} {it:(shift left)}
        . {stata `"mata: C.ipolate(30, "", ., ., (0, .7, 1))"'} {it:(shift right)}
        . {stata "colorpalette: mata(A) / mata(B) / mata(C)"}

{pstd}
    For convenience, {cmd:ColrSpace} also provides an interpolation
    function that does not involve translation between colorspaces and does not
    store any colors in {it:S}. This direct interpolation function is

        {it:C} = {it:S}{cmd:.colipolate(}{it:C0}, {it:n}[{cmd:,} {it:range}{cmd:,} {it:power}{cmd:,} {it:positions}{cmd:,} {it:padded}]{cmd:)}

{pstd}
    where {it:C0} is an {it:n0} x {it:c} matrix of {it:n0} origin colors
    that are interpolated to {it:n} destination colors.

{marker mix}{...}
{dlgtab:Mixing}

{pstd}
    To mix (i.e. average) the colors in {it:S}, type:

        {it:S}{cmd:.}[{cmd:add_}]{cmd:mix}[{cmd:_added}]{cmd:(}[{it:space}{cmd:,} {it:w}]{cmd:)}

{pstd}
    Opacity values and intensity adjustment multipliers, if defined, will also be mixed
    (i.e. averaged). {it:S}{cmd:.mix()} takes all existing colors as input and
    replaces them with the mixed color; use {it:S}{cmd:.mix_added()} if you
    only want to mix the colors added last. Furthermore, use
    {it:S}{cmd:.add_mix()} or {it:S}{cmd:.add_mix_added()} to leave the
    existing colors unchanged and append the mixed color. Arguments are as
    follows.

{phang}
    {it:space} selects the color space in which the colors are
    mixed. {it:space} can be {cmd:"RGB"}, {cmd:"lRGB"}, {cmd:"HSV"},
    {cmd:"HSL"}, {cmd:"CMYK"}, {cmd:"XYZ"},
    {cmd:"xyY"}, {cmd:"Lab"}, {cmd:"LCh"}, {cmd:"Luv",}
    {cmd:"HCL"}, {cmd:"CAM02} [{help colrspace##CAM02:{it:mask}}]{cmd:"},
    {cmd:"JMh} [{it:{help colrspace##JMh:coefs}}]{cmd:"}, or
    {cmd:"Jab} [{it:{help colrspace##JMh:coefs}}]{cmd:"}
    (lowercase spelling allowed). The default is {cmd:"Jab"}. This default can
    also be selected by typing {cmd:""}. When mixing hues (relevant for
    {cmd:"HSV"}, {cmd:"HSL"}, {cmd:"LCh"}, {cmd:"HCL"}, {cmd:"JMh}, and
    {cmd:"CAM02"} when {it:mask} contains {cmd:h}), {it:S}{cmd:.mix()} will
    compute the mean of angles as described at
    {browse "http://en.wikipedia.org/wiki/Mean_of_circular_quantities":Wikipedia (2018e)}
    (using weighted sums of the cartesian coordinates if weights are specified); this
    is slightly different from the procedure employed by {it:S}{cmd:.ipolate()}.

{phang}
    {it:w} is a real vector containing weights. Color mixing works by
    transforming the colors to the selected color space, taking the means of
    the attributes across colors, and then transforming the resulting "average"
    color back to the original space. {it:w} specifies the weights given to the
    individual colors when computing the means. If {it:w} contains less
    elements than there are colors, the weights will be recycled. Omit {it:w},
    or specify {it:w} as {cmd:1} or as {cmd:.} (missing) to use unweighted
    means.

{pstd}
    Example:

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.colors("black red yellow")"'}
        . {stata "mata: S.get()"}
        . {stata `"mata: S.mix("lRGB")"'}
        . {stata "mata: S.get()"}
        . {stata `"mata: S.colors("black red yellow")"'}
        . {stata `"mata: S.mix("lRGB", (.5, 1, 1))"'}
        . {stata "mata: S.get()"}

{marker recycle}{...}
{dlgtab:Recycling}

{pstd}
    To recycle the colors in {it:S}, type

        {it:S}{cmd:.}[{cmd:add_}]{cmd:recycle}[{cmd:_added}]{cmd:(}{it:n}{cmd:)}

{pstd}
    where {it:n} is a real scalar specifying the number of desired colors.
    {it:S}{cmd:.recycle()} will create {it:n} colors by recycling the colors
    until the desired number of colors is reached. If {it:n} is smaller than
    the number of existing colors, {it:S}{cmd:.recycle()} will select the first
    {it:n} colors. {it:S}{cmd:.recycle()} operates on all existing colors; use
    {it:S}{cmd:.recycle_added()} if you only want to recycle the colors added
    last. Furthermore, use {it:S}{cmd:.add_recycle()} or
    {it:S}{cmd:.add_recycle_added()} to leave the existing colors unchanged and
    append the recycled colors.

{pstd}
    Example:

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.colors("black red yellow")"'}
        . {stata "mata: S.recycle(7)"}
        . {stata "mata: S.colors()"}
        . {stata "mata: S.recycle(2)"}
        . {stata "mata: S.colors()"}

{pstd}
    For convenience, {cmd:ColrSpace} also provides a recycling function that
    does not store any colors in {it:S}. This direct recycling function is

        {it:C} = {it:S}{cmd:.colrecycle(}{it:C0}, {it:n}{cmd:)}

{pstd}
    where {it:C0} is an {it:n0} x {it:c} matrix of {it:n0} input colors values
    that are recycled to {it:n} output colors.

{marker select}{...}
{dlgtab:Selecting and ordering}

{pstd}
    To select (and order) colors in {it:S}, type

        {it:S}{cmd:.}[{cmd:add_}]{cmd:select}[{cmd:_added}]{cmd:(}{it:p}{cmd:)}

{pstd}
    where {it:p} is a real vector of the positions of the colors to be selected
    (permutation vector). Positive numbers refer to colors from the start;
    negative numbers refer to colors from the end. Colors not covered in {it:p}
    will be dropped and the selected colors will be ordered as specified in
    {it:p}. {it:S}{cmd:.select()} operates on all existing colors; use
    {it:S}{cmd:.select_added()} if you only want to manipulate the colors added
    last. Furthermore, use {it:S}{cmd:.add_select()} or
    {it:S}{cmd:.add_select_added()} to leave the existing colors unchanged and
    append the selected colors.

{pstd}
    To order the colors in {it:S}, type

        {it:S}{cmd:.}[{cmd:add_}]{cmd:order}[{cmd:_added}]{cmd:(}{it:p}{cmd:)}

{pstd}
    where {it:p} is a real vector specifying the desired order of the colors
    (permutation vector). Positive numbers refer to colors from the start;
    negative numbers refer to colors from the end. Colors not covered in
    {it:p} will be placed last, in their original order. {it:S}{cmd:.order()}
    operates on all existing colors; use {it:S}{cmd:.order_added()} if you only
    want to manipulate the colors added last. Furthermore, use
    {it:S}{cmd:.add_order()} or {it:S}{cmd:.add_order_added()} to leave the
    existing colors unchanged and append the reordered colors.

{pstd}
    To reverse the colors in {it:S}, type:

        {it:S}{cmd:.}[{cmd:add_}]{cmd:reverse}[{cmd:_added}]{cmd:()}

{pstd}
    {it:S}{cmd:.reverse()} operates on all existing colors; use
    {it:S}{cmd:.reverse_added()} if you only want to manipulate the colors
    added last. Furthermore, use {it:S}{cmd:.add_reverse()} or
    {it:S}{cmd:.add_reverse_added()} to leave the existing colors unchanged and
    append the reversed colors.

{pstd}
    {it:S}{cmd:.reverse()} is equivalent to {it:S}{cmd:.order(}{it:S}{cmd:.N()::1)} or
    {it:S}{cmd:.select(}{it:S}{cmd:.N()::1)}.

{pstd}
    Examples:

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.colors("black red yellow blue green")"'}
        . {stata "mata: S.select((4,3,4))"}
        . {stata "mata: S.colors()"}

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.colors("black red yellow blue green")"'}
        . {stata "mata: S.order((4,3,4))"}
        . {stata "mata: S.colors()"}

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.colors("black red yellow blue green")"'}
        . {stata "mata: S.reverse()"}
        . {stata "mata: S.colors()"}


{marker intensify}{...}
{title:Intensify, saturate, luminate}

{dlgtab:Intensify}

{pstd}
    To adjust the intensity of the colors in {it:S}, type

        {it:S}{cmd:.}[{cmd:add_}]{cmd:intensify}[{cmd:_added}]{cmd:(}{it:m}{cmd:)}

{pstd}
    where {it:m} is a real vector of intensity adjustment multipliers in [0,255]. A
    multiplier smaller than 1 makes the color lighter, a multiplier larger than one make the
    color darker. If the number of specified multipliers is smaller than
    the number of colors, the multipliers will be
    recycled; if the number of multipliers is larger than the number of
    colors, the colors will be recycled. To skip adjusting the intensity of a
    particular color, you may set the corresponding multiplier to
    {cmd:.} (missing). {it:S}{cmd:.intensify()} operates on all existing colors; use
    {it:S}{cmd:.intensify_added()} if you only want to manipulate the colors
    added last. Furthermore, use {it:S}{cmd:.add_intensify()} or
    {it:S}{cmd:.add_intensify_added()} to leave the existing colors unchanged and
    append the manipulated colors.

{pstd}
    {cmd:ColrSpace} uses the same algorithm as is used in official Stata to adjust
    the color intensity. Applying {it:S}{cmd:.intensify()} thus results in colors
    that look the same as colors that have been specified using intensity
    multiplier syntax (see help {help colorstyle##intensity:{it:colorstyle}}). The
    algorithm works by increasing or decreasing the RGB
    values proportionally, with rounding to the nearest
    integer and adjustment to keep all values within [0,255].

{pstd}
    Example:

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.colors("navy maroon forest_green")"'}
        . {stata `"mata: S.select((1,1,2,2,3,3))"'}     {it:(duplicate colors)}
        . {stata `"mata: S.intensify((., .5))"'}
        . {stata "colorpalette mata(S), rows(2)"}

{marker saturate}{...}
{dlgtab:Saturate}

{pstd}
    To change the saturation (colorfulness) of the colors in {it:S}, type:

        {it:S}{cmd:.}[{cmd:add_}]{cmd:saturate}[{cmd:_added}]{cmd:(}{it:d}[{cmd:,} {it:method}{cmd:,} {it:level}]{cmd:)}

{pstd}
    {it:S}{cmd:.saturate()} operates on all existing colors; use
    {it:S}{cmd:.saturate_added()} if you only want to manipulate the colors
    added last. Furthermore, use {it:S}{cmd:.add_saturate()} or
    {it:S}{cmd:.add_saturate_added()} to leave the existing colors unchanged and
    append the manipulated colors. Arguments are as follows.

{phang}
    {it:d} is a real vector of saturation adjustments addends. Positive values
    increase saturation, negative values decrease saturation. If the number of
    specified addends is smaller than the number of colors, the
    addends will be recycled; if the number of addends is larger than the number of
    colors, the colors will be recycled. Typically, reasonable addends are in a
    range of about +/- 50.

{phang}
    {it:method} selects the color space in which the colors are
    manipulated. It can be {cmd:"LCh"}, {cmd:"HCL"}, {cmd:"JCh"} (CIECAM02 JCh),
    or {cmd:"JMh"} (lowercase spelling allowed). The
    default is {cmd:"LCh"}. This default can also be selected by typing
    {cmd:""}. {it:S}{cmd:.saturate()} works by converting the colors to
    the selected color space, adding {it:d} to the C channel (or M'
    in case of J'M'h), and then converting the colors back (after resetting
    negative chroma values to zero).

{phang}
    {it:level}!=0 specifies that {it:d} provides chroma levels, not addends. In
    this case, the C channel will be set to {it:d}. Reasonable values typically
    lie in a range of 0-100, although higher values are possible. Negative values will
    be reset to 0.

{pstd}
    Example:

        . {stata "mata: A = ColrSpace()"}
        . {stata `"mata: A.palette("RdYlGn")"'}
        . {stata `"mata: B = J(1, 1, A)"'}           {it:(make copy of A)}
        . {stata `"mata: B.saturate(25)"'}
        . {stata "colorpalette: mata(A) / mata(B)"}

{pstd}
    {it:S}{cmd:.saturate()} has been inspired by the
    {cmd:saturate()} and {cmd:desaturate()} functions in Gregor Aisch's 
    {browse "http://gka.github.io/chroma.js/":chroma.js}.

{marker luminate}{...}
{dlgtab:Luminate}

{pstd}
    To change the luminance of the colors in {it:S}, type

        {it:S}{cmd:.}[{cmd:add_}]{cmd:luminate}[{cmd:_added}]{cmd:(}{it:d}[{cmd:,} {it:method}{cmd:,} {it:level}]{cmd:)}

{pstd}
    {it:S}{cmd:.luminate()} operates on all existing colors; use
    {it:S}{cmd:.luminate_added()} if you only want to manipulate the colors
    added last. Furthermore, use {it:S}{cmd:.add_luminate()} or
    {it:S}{cmd:.add_luminate_added()} to leave the existing colors unchanged and
    append the manipulated colors. Arguments are as follows.

{phang}
    {it:d} is a real vector of luminance adjustments addends. Positive values
    increase luminance, negative values decrease luminance. If the number of
    specified addends is smaller than the number of colors, the
    addends will be recycled; if the number of addends is larger than the number of
    colors, the colors will be recycled. Typically, reasonable addends are in a
    range of about +/- 50.

{phang}
    {it:method} selects the color space in which the colors are manipulated. It
    can be {cmd:"Lab"}, {cmd:"LCh"}, {cmd:"Luv"}, {cmd:"HCL"}, {cmd:"JCh"}
    (CIECAM02 JCh), {cmd:"JMh"} or {cmd:"Jab"} (lowercase spelling 
    allowed). The default is {cmd:"JMh"}. This default can also be selected by
    typing {cmd:""}. {it:S}{cmd:.luminate()} works by converting the colors to
    the selected color space, adding {it:d} to the L channel (or J in case of
    CIECAM02 JCh, J' in case of J'M'h or J'a'b'), and then converting the
    colors back (after resetting negative luminance values to zero). Results
    will be identical between {cmd:"Lab"} and {cmd:"LCh"}, between {cmd:"Luv"}
    as {cmd:"HCL"}, and between {cmd:"JMh"} and {cmd:"Jab"}.

{phang}
    {it:level}!=0 specifies that {it:d} provides luminance levels, not addends. In
    this case, the L channel will be set to {it:d}. Reasonable values typically
    lie in a range of 0-100. Negative values will be reset to 0.

{pstd}
    Example:

        . {stata "mata: A = ColrSpace()"}
        . {stata `"mata: A.palette("ptol", 10)"'}
        . {stata `"mata: B = J(1, 1, A)"'}           {it:(make copy of A)}
        . {stata `"mata: B.luminate(20)"'}
        . {stata "colorpalette, lc(black): mata(A) / mata(B)"}

{pstd}
    {it:S}{cmd:.luminate()} has been inspired by the
    {cmd:darken()} and {cmd:brighten()} functions in Gregor Aisch's 
    {browse "http://gka.github.io/chroma.js/":chroma.js}.


{marker gray}{...}
{title:Grayscale conversion}

{pstd}
    To convert the colors in {it:S} to gray, type

        {it:S}{cmd:.}[{cmd:add_}]{cmd:gray}[{cmd:_added}]{cmd:(}[{it:proportion}{cmd:,} {it:method}]{cmd:)}

{pstd}
    {it:S}{cmd:.gray()} transforms all existing colors; use
    {it:S}{cmd:.gray_added()} if you only want to transform the colors
    added last. Furthermore, use {it:S}{cmd:.add_gray()} or
    {it:S}{cmd:.add_gray_added()} to leave the existing colors unchanged and
    append the transformed colors. Arguments are as follows.

{phang}
    {it:proportion} in [0,1] specifies the proportion of gray. The default
    is {cmd:1} (complete conversion to gray). This default can also be selected
    by typing {cmd:.} (missing).

{phang}
    {it:method} specifies the color space in which the colors are
    manipulated. It can be {cmd:"LCh"}, {cmd:"HCL"}, {cmd:"JCh"} (CIECAM02 JCh),
    or {cmd:"JMh"} (lowercase spelling allowed). The
    default is {cmd:"LCh"}. This default can also be selected by typing
    {cmd:""}. Grayscale cconversion works by converting the colors the selected
    color space, reducing the C channel (or M' in case of J'M'h) towards zero,
    and then converting the colors back.

{pstd}
    Example:

        . {stata "mata: A = ColrSpace()"}
        . {stata `"mata: A.palette("s1")"'}
        . {stata `"mata: B = C = J(1, 1, A)"'}      {it:(make copies)}
        . {stata `"mata: B.gray(.7)"'}
        . {stata `"mata: C.gray()"'}
        . {stata "colorpalette, lc(black): mata(A) / mata(B) / mata(C)"}

{pstd}
    Grayscale conversion is also supported by {it:S}{cmd:.convert()}; see
    {help colrspace##convert:Convert colors without storing}.


{marker cvd}{...}
{title:Color vision deficiency simulation}

{pstd}
    To convert the colors in {it:S} such that they look how they would appear to
    people suffering from color vision deficiency (color blindness), type

        {it:S}{cmd:.}[{cmd:add_}]{cmd:cvd}[{cmd:_added}]{cmd:(}[{it:severity}{cmd:,} {it:type}]{cmd:)}

{pstd}
    {it:S}{cmd:.cvd()} transforms all existing colors; use
    {it:S}{cmd:.cvd_added()} if you only want to transform the colors
    added last. Furthermore, use {it:S}{cmd:.add_cvd()} or
    {it:S}{cmd:.add_cvd_added()} to leave the existing colors unchanged and
    append the transformed colors. Arguments are as follows.

{phang}
    {it:severity} in [0,1] specifies the severity of the deficiency. The default
    is {cmd:1} (maximum severity, i.e. deuteranopia, protanopia, or
    tritanopia, respectively). This default can also be selected
    by typing {cmd:.} (missing).

{phang}
    {it:type} specifies the type of color vision deficiency. It can be
    {cmd:"deuteranomaly"}, {cmd:"protanomaly"}, or {cmd:"tritanomaly"}
    (abbreviations allowed). The default is {cmd:"deuteranomaly"}. This default
    can also be selected by typing {cmd:""}. See
    {browse "http://en.wikipedia.org/wiki/Color_blindness":Wikipedia (2019a)} for basic
    information on the different types of color blindness.

{pstd}
    {cmd:ColrSpace} implements color vision deficiency simulation based on
    {browse "http://doi.org/10.1109/TVCG.2009.113":Machado et al. (2009)}, using the
    transformation matrices provided at
    {browse "http://www.inf.ufrgs.br/~oliveira/pubs_files/CVD_Simulation/CVD_Simulation.html":www.inf.ufrgs.br/~oliveira}
    (employing linear interpolation between matrices for intermediate severity values). The
    transformations matrix for a specific combination of {it:severity} and {it:type} can be
    retrieved as follows:

        {it:M} = {it:S}{cmd:.cvd_M(}[{it:severity}{cmd:,} {it:type}]{cmd:)}

{pstd}
    Example:

        . {stata "mata: A = ColrSpace()"}
        . {stata `"mata: A.palette("s2", 5)"'}
        . {stata `"mata: d = D = p = P = T = J(1, 1, A)"'}  {it:(make copies)}
        . {stata `"mata: d.cvd(.5);      d.pname("deuteranomaly")"'}
        . {stata `"mata: D.cvd();        D.pname("deuteranopia")"'}
        . {stata `"mata: p.cvd(.5, "p"); p.pname("protanomaly")"'}
        . {stata `"mata: P.cvd(1, "p");  P.pname("protanopia")"'}
        . {stata `"mata: T.cvd(1, "t");  T.pname("tritanopia")"'}
        . {stata "colorpalette, lc(black): m(A) / m(d) / m(D) / m(p) / m(P) / m(T)"}

{pstd}
    Color vision deficiency simulation is also supported by {it:S}{cmd:.convert()}; see
    {help colrspace##convert:Convert colors without storing}.


{marker palettes}{...}
{title:Color palettes}

{dlgtab:Standard palettes}

{pstd}
    To import colors from a named color palette, type:

        {it:C} = {it:S}{cmd:.}[{cmd:add_}]{cmd:palette(}[{cmd:"}{it:name}{cmd:"}{cmd:,} {it:n}{cmd:,} {it:noexpand}]{cmd:)}

{pstd}
    {it:S}{cmd:.palette()} replaces existing colors by the new colors; use
    {it:S}{cmd:.add_palette()} if you want to append the new colors. Arguments are as follows.

{phang}
    {it:name} selects the palette and can be one of the following (also see
    help {helpb colorpalette}, if installed, for more information on these palettes):

{p2colset 13 38 40 2}{...}
{p2col:{cmd:s1}}15 qualitative colors as in Stata's {helpb scheme s1:s1color} scheme{p_end}
{p2col:{cmd:s1r}}15 qualitative colors as in Stata's {helpb scheme s1:s1rcolor} scheme{p_end}
{p2col:{cmd:s2}}15 qualitative colors as in Stata's {helpb scheme s2:s2color} scheme{p_end}
{p2col:{cmd:economist}}15 qualitative colors as in Stata's {helpb scheme economist:economist} scheme{p_end}
{p2col:{cmd:mono}}15 gray scales (qualitative) as in Stata's monochrome schemes{p_end}
{p2col:{cmd:cblind}}9 colorblind-friendly colors (qualitative) by {browse "http://jfly.iam.u-tokyo.ac.jp/color/":Okabe and Ito (2002)}{p_end}
{p2col:{cmd:plottig}}15 qualitative colors as in {cmd:plottig} by {browse "http://www.stata-journal.com/article.html?article=gr0070":Bischof (2017b)}{p_end}
{p2col:{cmd:538}}13 qualitative colors as in {cmd:538} by {browse "http://ideas.repec.org/c/boc/bocode/s458404.html":Bischof (2017a)}{p_end}
{p2col:{cmd:tfl}}7 qualitative colors as in {cmd:mrc} by {browse "http://ideas.repec.org/c/boc/bocode/s457703.html":Morris (2013)}{p_end}
{p2col:{cmd:mrc}}8 qualitative colors as in {cmd:tfl} by {browse "http://ideas.repec.org/c/boc/bocode/s458103.html":Morris (2015)}{p_end}
{p2col:{cmd:burd}}13 qualitative colors as in {cmd:burd} by {browse "http://ideas.repec.org/c/boc/bocode/s457623.html":Briatte (2013)}{p_end}
{p2col:{cmd:lean}}15 gray scales (qualitative) as in {cmd:lean} by {browse "http://www.stata-journal.com/article.html?article=gr0002":Juul (2003)}{p_end}
{p2col:{cmd:webcolors}}all 148 {help colrspace##webcolors:web colors}, alphabetically sorted{p_end}
{p2col:{cmd:webcolors pink}}6 pink {help colrspace##webcolors:web colors}{p_end}
{p2col:{cmd:webcolors purple}}19 purple {help colrspace##webcolors:web colors}{p_end}
{p2col:{cmd:webcolors redorange}}14 red and orange {help colrspace##webcolors:web colors}{p_end}
{p2col:{cmd:webcolors yellow}}11 yellow {help colrspace##webcolors:web colors}{p_end}
{p2col:{cmd:webcolors green}}22 green {help colrspace##webcolors:web colors}{p_end}
{p2col:{cmd:webcolors cyan}}8 cyan {help colrspace##webcolors:web colors}{p_end}
{p2col:{cmd:webcolors blue}}16 blue {help colrspace##webcolors:web colors}{p_end}
{p2col:{cmd:webcolors brown}}18 brown {help colrspace##webcolors:web colors}{p_end}
{p2col:{cmd:webcolors white}}17 white {help colrspace##webcolors:web colors}{p_end}
{p2col:{cmd:webcolors gray}}10 gray {help colrspace##webcolors:web colors}{p_end}
{p2col:{cmd:webcolors grey}}10 grey {help colrspace##webcolors:web colors} (same color codes as {cmd:gray}){p_end}
{p2col:{cmd:d3 10}}10 qualitative colors from {browse "http://d3js.org/":D3.js}{p_end}
{p2col:{cmd:d3 20}}20 qualitative colors in pairs from {browse "http://d3js.org/":D3.js}{p_end}
{p2col:{cmd:d3 20b}}20 qualitative colors in groups of four from {browse "http://d3js.org/":D3.js}{p_end}
{p2col:{cmd:d3 20c}}20 qualitative colors in groups of four from {browse "http://d3js.org/":D3.js}{p_end}
{p2col:{cmd:Accent}}8 accented colors (qualitative) from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Dark2}}8 dark colors (qualitative) from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Paired}}12 paired colors (qualitative) from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Pastel1}}9 pastel colors (qualitative) from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Pastel2}}8 pastel colors (qualitative) from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Set1}}9 qualitative colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Set2}}8 qualitative colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Set3}}12 qualitative colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Blues}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:BuGn}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:BuPu}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:GnBu}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Greens}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Greys}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:OrRd}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Oranges}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:PuBu}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:PuBuGn}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:PuRd}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Purples}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:RdPu}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Reds}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:YlGn}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:YlGnBu}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:YlOrBr}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:YlOrRd}}3-9 sequential colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:BrBG}}3-11 diverging colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:PRGn}}3-11 diverging colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:PiYG}}3-11 diverging colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:PuOr}}3-11 diverging colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:RdBu}}3-11 diverging colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:RdGy}}3-11 diverging colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:RdYlBu}}3-11 diverging colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:RdYlGn}}3-11 diverging colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:Spectral}}3-11 diverging colors from {browse "http://colorbrewer2.org/":ColorBrewer}{p_end}
{p2col:{cmd:ptol qualitative}}1-12 qualitative colors by {browse "http://personal.sron.nl/~pault/colourschemes.pdf":Tol (2012)}{p_end}
{p2col:{cmd:ptol diverging}}3-11 diverging colors by {browse "http://personal.sron.nl/~pault/colourschemes.pdf":Tol (2012)}{p_end}
{p2col:{cmd:ptol rainbow}}4-12 rainbow colors by {browse "http://personal.sron.nl/~pault/colourschemes.pdf":Tol (2012)} (sequential){p_end}
{p2col:{cmd:tableau}}20 qualitative colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin carcolor}}6 car colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin carcolor algorithm}}6 algorithm-selected car colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin food}}7 food colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin food algorithm}}7 algorithm-selected food colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin features}}5 feature colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin features algorithm}}5 algorithm-selected feature colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin activities}}5 activity colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin activities algorithm}}5 algorithm-selected activity colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin fruits}}7 fruit colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin fruits algorithm}}7 algorithm-selected fruit colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin vegetables}}7 vegetable colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin vegetables algorithm}}7 algorithm-selected vegetable colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin drinks}}7 drinks colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin drinks algorithm}}7 algorithm-selected drinks colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin brands}}7 brands colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:lin brands algorithm}}7 algorithm-selected brands colors by {browse "http://dx.doi.org/10.1111/cgf.12127":Lin et al. (2013)}{p_end}
{p2col:{cmd:spmap blues}}2-99 sequential colors by {browse "http://ideas.repec.org/c/boc/bocode/s456812.html":Pisati (2007)}{p_end}
{p2col:{cmd:spmap greens}}2-99 sequential colors by {browse "http://ideas.repec.org/c/boc/bocode/s456812.html":Pisati (2007)}{p_end}
{p2col:{cmd:spmap greys}}2-99 sequential colors by {browse "http://ideas.repec.org/c/boc/bocode/s456812.html":Pisati (2007)}{p_end}
{p2col:{cmd:spmap reds}}2-99 sequential colors by {browse "http://ideas.repec.org/c/boc/bocode/s456812.html":Pisati (2007)}{p_end}
{p2col:{cmd:spmap rainbow}}2-99 rainbow colors (sequential) by {browse "http://ideas.repec.org/c/boc/bocode/s456812.html":Pisati (2007)}{p_end}
{p2col:{cmd:spmap heat}}2-16 heat colors (sequential) by {browse "http://ideas.repec.org/c/boc/bocode/s456812.html":Pisati (2007)}{p_end}
{p2col:{cmd:spmap terrain}}2-16 terrain colors (sequential) by {browse "http://ideas.repec.org/c/boc/bocode/s456812.html":Pisati (2007)}{p_end}
{p2col:{cmd:spmap topological}}2-16 topological colors (sequential) by {browse "http://ideas.repec.org/c/boc/bocode/s456812.html":Pisati (2007)}{p_end}
{p2col:{cmd:sfso brown}}6 sequential colors by SFSO (2017){p_end}
{p2col:{cmd:sfso orange}}6 sequential colors by SFSO (2017){p_end}
{p2col:{cmd:sfso red}}6 sequential colors by SFSO (2017){p_end}
{p2col:{cmd:sfso pink}}6 sequential colors by SFSO (2017){p_end}
{p2col:{cmd:sfso purple}}6 sequential colors by SFSO (2017){p_end}
{p2col:{cmd:sfso violet}}6 sequential colors by SFSO (2017){p_end}
{p2col:{cmd:sfso blue}}7 sequential colors by SFSO (2017){p_end}
{p2col:{cmd:sfso ltblue}}6 sequential colors by SFSO (2017){p_end}
{p2col:{cmd:sfso turquoise}}6 sequential colors by SFSO (2017){p_end}
{p2col:{cmd:sfso green}}6 sequential colors by SFSO (2017){p_end}
{p2col:{cmd:sfso olive}}6 sequential colors by SFSO (2017){p_end}
{p2col:{cmd:sfso black}}6 sequential colors by SFSO (2017){p_end}
{p2col:{cmd:sfso parties}}11 qualitative colors by SFSO (2017){p_end}
{p2col:{cmd:sfso languages}}5 qualitative colors by SFSO (2017){p_end}
{p2col:{cmd:sfso votes}}10 diverging colors by SFSO (2017){p_end}

{pmore}
    The palette names can be abbreviated and typed in lowercase letters (for example,
    {cmd:"BuGn"} could be typed as {cmd:"bugn"}, {cmd:"lin carcolor algorithm"} could be
    typed as {cmd:"lin car a"}). If abbreviation is ambiguous, the first matching name
    in the above list will be used. Default is {cmd:"s2"}; this default
    can also be selected by typing {cmd:""}.

{pmore}
    {browse "http://colorbrewer2.org/":ColorBrewer} is a set of color schemes developed by
    {browse "http://doi.org/10.1559/152304003100010929":Brewer et al. (2003)}; also
    see Brewer (2016). The colors are licensed under Apache License Version 2.0; see
    the copyright notes at
    {browse "http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html":ColorBrewer_updates.html}.

{phang}
    {it:n} is the number of colors to be retrieved from the palette. Many
    palettes, such as, e.g., the sequential and
    diverging ColorBrewer palettes, are adaptive to {it:n} in the sense that
    they return different colors depending on {it:n}. Other palettes, such
    as {cmd:"s2"}, contain a fixed set of colors. In any case, if {it:n} is
    different from the (maximum or minimum) number of colors defined by a
    palette, the colors are either recycled (qualitative palettes) or
    interpolated (all other palettes) such that the number of retrieved colors is
    equal to {it:n}.

{phang}
    {it:noexpand}!=0 omits recycling or interpolating colors if {it:n}, the number of
    requested colors, is larger (smaller) than the maximum (minimum) number of
    colors defined by a palette. That is, if {it:noexpand}!=0 is specified, the
    resulting number of colors in {it:S} may be different from the requested number
    of colors. Exception: {it:noexpand}!=0 does not suppress "recycling" of
    qualitative palettes if {it:n} is smaller than the (minimum) number of colors
    defined by the palette. In this case, the first {it:n} colors of the palette
    are retrieved irrespective of whether {it:noexpand}!=0 is specified or not.

{pstd}
    Example:

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.palette("lin fruits")"'}
        . {stata `"mata: S.add_palette("lin veg")"'}
        . {stata `"mata: S.pname("fruits and vegetables")"'}
        . {stata "colorpalette mata(S)"}

{marker matplotlib}{...}
{dlgtab:Matplotlib colormaps}

{pstd}
    A selection of colormaps from
    {browse "http://matplotlib.org":matplotlib}, a Python 2D plotting library
    ({browse "http://dx.doi.org/10.1109/MCSE.2007.55":Hunter 2007}), is provided
    by function {it:S}{cmd:.matplotlib()}. The syntax
    is:

        {it:S}{cmd:.}[{cmd:add_}]{cmd:matplotlib(}[{cmd:"}{it:name}{cmd:"}{cmd:,} {it:n}{cmd:,} {it:range}]{cmd:)}

{pstd}
    {it:S}{cmd:.matplotlib()} replaces existing colors by the new colors; use
    {it:S}{cmd:.add_matplotlib()} if you want to append the new colors. Arguments
    are as follows.

{phang}
    {it:name} selects the colormap and can be one of {cmd:viridis},
    {cmd:magma}, {cmd:inferno}, {cmd:plasma}, {cmd:cividis},
    {cmd:twilight}, {cmd:twilight shifted}, {cmd:autumn}, {cmd:spring},
    {cmd:summer}, {cmd:winter}, {cmd:bone}, {cmd:cool}, {cmd:copper},
    {cmd:coolwarm}, {cmd:jet}, or {cmd:hot}. The names can be
    abbreviated; if abbreviation is ambiguous, the first matching name in the
    above list will be used. For example, {cmd:"twilight shifted"} could be typed
    {cmd:"t s"}. Default is {cmd:"viridis"}; this default can also
    be selected by typing {cmd:""}.

{phang}
    {it:n} is the number of colors to be retrieved from the colormap. The default
    is 15.

{phang}
     {it:range} = {cmd:(}{it:lb}[{cmd:,} {it:ub}]{cmd:)} specifies the range of
     the colormap to be used, with {it:lb} and {it:ub} within [0,1] (values
     smaller than 0 or larger than 1 will be interpreted as 0 or 1, respectively). The
     default is {cmd:(0,1)}. This default can also be selected by typing
     {cmd:.} (missing). If {it:lb} is larger then {it:ub}, the colors are
     retrieved in reverse order.

{pstd}
    Example:

        . {stata "mata: A = B = ColrSpace()"}
        . {stata `"mata: A.matplotlib("viridis")"'}
        . {stata `"mata: B.matplotlib("magma", ., (.2,1))"'}
        . {stata "colorpalette: mata(A) / mata(B)"}

{pstd}
    For convenience, {cmd:ColrSpace} also provides function

        {it:RGB1} = {it:S}{cmd:.matplotlib_ip(}{it:R}{cmd:,} {it:G}{cmd:,} {it:B}{cmd:,} {it:n}[{cmd:,} {it:range}]{cmd:)}

{pstd}
    that can be used to create linear segmented colormaps. Some of the colormaps above
    are implemented in terms of this function. {it:R}, {it:G}, and {it:B} are matrices
    specifying the anchor points of the segments (each row consist of three values: the
    anchor, the value of the color on the left of the anchor, and the value of the
    color on the right). See the corresponding
    {browse "http://matplotlib.org/tutorials/colors/colormap-manipulation.html#creating-linear-segmented-colormaps":tutorial page}
    at {browse "http://matplotlib.org/":matplotlib.org} for details. {it:S}{cmd:.matplotlib_ip()}
    does not check the consistency of the specified matrices and may return invalid
    results if consistency is violated.


{marker cgen}{...}
{title:Color generators}

{pstd}
    To generate colors in different spaces you can use the {it:S}{cmd:.generate()}
    function. The syntax is:

        {it:S}{cmd:.}[{cmd:add_}]{cmd:generate("HUE"}         [{cmd:,} {it:n}{cmd:,} {it:H}{cmd:,} {it:C}{cmd:,} {it:L}{cmd:,} {it:reverse}]{cmd:)}
        {it:S}{cmd:.}[{cmd:add_}]{cmd:generate("HCL} [{it:class}]{cmd:"} [{cmd:,} {it:n}{cmd:,} {it:H}{cmd:,} {it:C}{cmd:,} {it:L}{cmd:,} {it:P}]{cmd:)}
        {it:S}{cmd:.}[{cmd:add_}]{cmd:generate("LCh} [{it:class}]{cmd:"} [{cmd:,} {it:n}{cmd:,} {it:L}{cmd:,} {it:C}{cmd:,} {it:h}{cmd:,} {it:P}]{cmd:)}
        {it:S}{cmd:.}[{cmd:add_}]{cmd:generate("JMh} [{it:class}]{cmd:"} [{cmd:,} {it:n}{cmd:,} {it:J}{cmd:,} {it:M}{cmd:,} {it:h}{cmd:,} {it:P}]{cmd:)}
        {it:S}{cmd:.}[{cmd:add_}]{cmd:generate("HSV} [{it:class}]{cmd:"} [{cmd:,} {it:n}{cmd:,} {it:H}{cmd:,} {it:S}{cmd:,} {it:V}{cmd:,} {it:P}]{cmd:)}
        {it:S}{cmd:.}[{cmd:add_}]{cmd:generate("HSL} [{it:class}]{cmd:"} [{cmd:,} {it:n}{cmd:,} {it:H}{cmd:,} {it:S}{cmd:,} {it:L}{cmd:,} {it:P}]{cmd:)}

{pstd}
    {it:S}{cmd:.generate()} replaces existing colors by the new colors; use
    {it:S}{cmd:.add_generate()} if you want to append the new colors.

{pstd}
    The first argument selects the color generator. The argument can
    be typed in lowercase letters. The default is {cmd:"HUE"}; this default
    can also be selected by typing {cmd:""}. The different color generators are
    as follows:

{pmore}
    {cmd:"HUE"} generates HCL colors with evenly spaced hues. The algorithm has been
    modeled after function {cmd:hue_pal()} from R's {cmd:scales} package by
    Hadley Wickham (see {browse "http://github.com/hadley/scales"}). The default
    parameters are {it:H} = {cmd:(15, 375)}, {it:C} = {cmd:100}, and {it:L} = {cmd:65}.
    If the difference between the two values of {it:H} is a multiple
    of 360, the second value will be reduced by 360/{it:n} (so that the space between
    the last and the first color is the same as between the other colors).

{pmore}
    {cmd:"HCL} [{it:class}]{cmd:"} generates colors in the HCL space
    (radial CIE L*u*v*). The algorithm has been modeled after R's {cmd:colorspace} package by
    {browse "http://CRAN.R-project.org/package=colorspace":Ihaka et al. (2016)}; also
    see {browse "http://dx.doi.org/10.1016/j.csda.2008.11.033":Zeileis et al. (2009)}
    and {browse "http://hclwizard.org":hclwizard.org}. Optional {it:class} can be
    {cmd:"qualitative"} (the default), {cmd:"sequential"}, or {cmd:"diverging"}
    (abbreviations allowed). Let h1 and h2 be two hues on the 360
    degree color wheel, c1 and c2 two chroma levels, l1 and
    l2 two luminance levels, p1 and p2 two power parameters, and
    i an index from 1 to {it:n}. The colors are then generated as follows:

{p2colset 13 29 31 2}{...}
{p2col:{cmd:qualitative}}{cmd:(}h1 + (h2-h1) * (i-1)/({it:n}-1){cmd:,}
    c1{cmd:,} l1{cmd:)}
    {p_end}
{p2col:}defaults: h1 = 15, h2 = h1+360*({it:n}-1)/{it:n}, c1 = 100, l1 = 65

{p2col:{cmd:sequential}}{cmd:(}h2 - (h2-h1) * j,
    c2 - (c2-c1) * j^p1{cmd:,}
    l2 - (l2-l1) * j^p2{cmd:)}{break}
    with j = ({it:n}-{it:i})/({it:n}-1)
    {p_end}
{p2col:}defaults: h1 = 260, h2 = h1, c1 = 80, c2 = 10, l1 = 25, l2 = 95, p1 = 1, p2 = p1

{p2col:{cmd:diverging}}{cmd:(}cond(j>0, h1, h2){cmd:,}
    c1 * abs(j)^p1{cmd:,}
    l2 - (l2-l1) * abs(j)^p2{cmd:)}{break}
    with j = ({it:n}-2*{it:i}+1)/({it:n}-1)
    {p_end}
{p2col:}defaults: h1 = 260, h2 = 0, c1 = 80, l1 = 30, l2 = 95, p1 = 1, p2 = p1

{pmore}
    {cmd:"LCh"} [{it:class}]{cmd:"} generates colors in the LCh space (radial CIE L*a*b*). The
    algorithm has been modeled in analogy to {cmd:"HCL"}. The default
    parameters are as follows.

{p2colset 13 29 31 2}{...}
{p2col:{cmd:qualitative}}l1 = 65, c1 = 70, h1 = 30, h2 = h1+360*({it:n}-1)/{it:n}
    {p_end}
{p2col:{cmd:sequential}}l1 = 25, l2 = 95, c1 = 72, c2 = 6, h1 = 290, h2 = h1, p1 = 1, p2 = p1
    {p_end}
{p2col:{cmd:diverging}}l1 = 30, l2 = 95, c1 = 60, h1 = 290, h2 = 10, p1 = 1, p2 = p1

{pmore}
    {cmd:"JMh} [{it:class}]{cmd:"} generates colors in the J'M'h space. The algorithm has
    been modeled in analogy to {cmd:"HCL"}, with J' replacing L and M' replacing C. The
    default parameters are as follows.

{p2colset 13 29 31 2}{...}
{p2col:{cmd:qualitative}}j1 = 67, m1 = 35, h1 = 25, h2 = h1+360*({it:n}-1)/{it:n}
    {p_end}
{p2col:{cmd:sequential}}j1 = 25, j2 = 96, m1 = 32, m2 = 7, h1 = 260, h2 = h1, p1 = 1, p2 = p1
    {p_end}
{p2col:{cmd:diverging}}j1 = 30, j2 = 96, m1 = 30, h1 = 260, h2 = 8, p1 = 1, p2 = p1

{pmore}
    {cmd:"HSV} [{it:class}]{cmd:"} generates colors in the HSV space. The algorithm has
    been modeled in analogy to {cmd:"HCL"}, with S replacing C and V replacing L. The default
    parameters are as follows.

{p2colset 13 29 31 2}{...}
{p2col:{cmd:qualitative}}h1 = 0, h2 = h1+360*({it:n}-1)/{it:n}, s1 = .6, v1 = .9
    {p_end}
{p2col:{cmd:sequential}}h1 = 240, h2 = h1, s1 = .8, s2 = .05, v1 = .6, v2 = 1, p1 = 1.2, p2 = p1
    {p_end}
{p2col:{cmd:diverging}}h1 = 220, h2 = 350, s1 = .8, v1 = .6, v2 = .95, p1 = 1.2, p2 = p1

{pmore}
    {cmd:"HSL} [{it:class}]{cmd:"} generates colors in the HSL space. The algorithm has
    been modeled in analogy to {cmd:"HCL"}, with S replacing C. The default parameters are as
    follows.

{p2colset 13 29 31 2}{...}
{p2col:{cmd:qualitative}}h1 = 0, h2 = h1+360*({it:n}-1)/{it:n}, s1 = .7, l1 = .6
    {p_end}
{p2col:{cmd:sequential}}h1 = 240, h2 = h1, s1 = .65, s2 = .65, l1 = .35, l2 = .975, p1 = 1.2, p2 = p1
    {p_end}
{p2col:{cmd:diverging}}h1 = 220, h2 = 350, s1 = .65, l1 = .35, l2 = .95, p1 = 1.2, p2 = p1

{phang}
    {it:n} specifies the number of colors to be generated. The default is 15.

{phang}
    {it:H} (or {it:h}) is a real vector specifying one or two hues in degrees of the
    color wheel. The default hues can be selected by typing {cmd:.} (missing).

{phang}
    {it:C} (or {it:M'}) is a real scalar specifying a single chroma (colorfulness, color intensity)
    level for {cmd:"HUE"} or a real vector specifying one or two chroma levels for {cmd:"HCL"},
    {cmd:"LCh"}, or {cmd:"JMh"}. The default levels can be selected by
    typing {cmd:.} (missing).

{phang}
    {it:L} (or {it:J'}) is a real scalar specifying a single luminance/lightness level for {cmd:"HUE"} or a real
    vector specifying one or two luminance/lightness levels for {cmd:"HCL"},
    {cmd:"LCh"}, {cmd:"JMh"}, or {cmd:"HSL"}. The default levels can be selected by
    typing {cmd:.} (missing).

{phang}
    {it:S} is a real vector specifying one or two saturation levels for
    {cmd:"HSV"} or {cmd:"HSL"}. The default levels can be selected by
    typing {cmd:.} (missing).

{phang}
    {it:V} is a real vector specifying one or two value levels for
    {cmd:"HSV"}. The default levels can be selected by
    typing {cmd:.} (missing).

{phang}
    {it:P} is a real vector specifying one or two power parameters. The default
    parameters can be selected by typing {cmd:.} (missing).

{phang}
    {it:reverse}!=0 causes {cmd:"HUE"} to travel counter-clockwise around the
    color wheel. By default, {cmd:"HUE"} travels clockwise.

{pstd}
    Examples:

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.generate("HUE", 5)"'}
        . {stata "colorpalette mata(S)"}

        . {stata `"mata: S.generate("HCL diverging", 30)"'}
        . {stata "colorpalette: mata(S)"}

        . {stata `"mata: S.generate("HCL diverging", 30, (0, 150), 70, (50, 98))"'}
        . {stata "colorpalette: mata(S)"}


{marker delta}{...}
{title:Color differences and contrast ratios}

{dlgtab:Color differences}

{pstd}
    To compute differences between colors in {it:S}, type

        {it:D} = {it:S}{cmd:.delta}[{cmd:_added}]{cmd:(}[{it:P}{cmd:,} {it:method}{cmd:,} {it:noclip}]{cmd:)}

{pstd}
    where {it:P} is a {it:r} x 2 matrix with each row selecting two colors to
    be compared. For example, {it:P} = {cmd:(3,5)} would compare the 3rd and
    the 5th color; {it:P} = {cmd:(1,2) \ (3,5)} would make two comparisons: 1st
    to 2nd and 3rd to 5th. The default, if {it:P} is omitted, is to make
    {it:n}-1 consecutive comparisons, where {it:n} is the number of existing
    colors: 1st to 2nd, 2nd to 3rd, ..., ({it:n}-1)th
    to {it:n}th; this is equivalent to {it:P} =
    {cmd:((1::}{it:S}{cmd:.N()-1),(2::}{it:S}{cmd:.N()))}. This default
    can also be selected by typing {cmd:.} (missing). {it:S}{cmd:.delta()}
    operates on all existing colors, that is, {it:P} selects among all colors;
    in {it:S}{cmd:.delta_added()} {it:P} only selects among the colors added
    last. Further options are as follows.

{phang}
    {it:method} selects the method used to compute the color differences. It can
    be {cmd:"E76"} for the 1976 CIELAB Delta E definition (equal to the
    euclidean distance in {cmd:"Lab"}), any of {cmd:"RGB"}, {cmd:"RGB1"},
    {cmd:"lRGB"}, {cmd:"XYZ"}, {cmd:"XYZ1"},
    {cmd:"xyY1"}, {cmd:"Lab"}, {cmd:"LCh"}, {cmd:"Luv",} {cmd:"HCL"},
    {cmd:"JCh"}, or {cmd:"JMh} [{it:{help colrspace##JMh:coefs}}]{cmd:"}
    to compute the differences as euclidean distances in the respective color
    space (lowercase spelling allowed; {cmd:"JCh"} selecting J, C, and h of
    CIECAM02), or {cmd:"Jab} [{it:{help colrspace##JMh:coefs}}]{cmd:"}
    to compute the differences as described by
    {browse "http://doi.org/10.1007/978-1-4419-6190-7_2":Luo and Li (2013, chapter 2.6.1)}. The
    default is {cmd:"Jab"}. This default can also be selected by typing {cmd:""}. Formally,
    a color difference can be written as

            d = sqrt( (x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2 )

{pmore}
    where x#, y#, and z# are the coordinates of the two colors
    in a particular space. For {cmd:"E76"}, y = L*, x = a*, z = b* from the
    CIE L*a*b* color space; for {cmd:"Jab"}, y = J'/K_L, x = a', z = b'
    from the CIECAM J'a'b' space, where K_L is a transformation
    coefficient set by {it:{help colrspace##JMh:coefs}}. For background information
    on color difference also see
    {browse "http://en.wikipedia.org/wiki/Color_difference":Wikipedia (2019b)}.

{phang}
    {it:noclip}!=0 prevents converting the colors to valid RGB values before
    computing the differences. By default, {it:S}{cmd:.delta()} translates the
    colors to linear RGB and clips the coordinates at 0 and 1, before converting
    the colors to the color space selected by {it:method}, so that the
    computed differences are consistent with how the colors are perceived
    on an RGB device. Specify {it:noclip}!=0 to skip this extra step.

{pstd}
    Opacity settings and intensity adjustment multipliers are ignored when computing the
    color differences.

{pstd}
    Example:

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.colors("#337ab7 #f0ad4e")"'}
        . {stata `"mata: S.ipolate(6, "", (0, .5))"'}
        . {stata `"mata: S.delta((J(5,1,1), (2::6)))"'}     {it:(compare 1st to other colors)}

          {it:(illustrate using a graph ...)}
        . {stata `"mata: D = S.delta((J(5,1,1), (2::6)))"'}
        . {stata `"mata: D = `"""' :+ "{&Delta}E' = " :+ strofreal(D,"%9.3g") :+ `"""'"'}
        . {stata `"mata: D = strofreal(1::5) :+ " 3 " :+  D"'}
        . {stata `"mata: st_local("D", invtokens(D'))"'}
        . {stata `"colorpalette mata(S), order(1 1 1 1 1) gropts(text(`D'))"'}

{marker contrast}{...}
{dlgtab:Contrast ratios}

{pstd}
    To compute contrast ratios between colors in {it:S}, type

        {it:R} = {it:S}{cmd:.contrast}[{cmd:_added}]{cmd:(}[{it:P}]{cmd:)}

{pstd}
    where {it:P} is a {it:r} x 2 matrix with each row selecting two colors to
    be compared. For example, {it:P} = {cmd:(3,5)} would compare the 3rd and
    the 5th color; {it:P} = {cmd:(1,2) \ (3,5)} would make two comparisons: 1st
    to 2nd and 3rd to 5th. The default, if {it:P} is omitted, is to make
    {it:n}-1 consecutive comparisons, where {it:n} is the number of existing
    colors: 1st to 2nd, 2nd to 3rd, ..., ({it:n}-1)th
    to {it:n}th; this is equivalent to {it:P} =
    {cmd:((1::}{it:S}{cmd:.N()-1),(2::}{it:S}{cmd:.N()))}. This default
    can also be selected by typing {cmd:.} (missing). {it:S}{cmd:.contrast()}
    operates on all existing colors, that is, {it:P} selects among all colors;
    in {it:S}{cmd:.contrast_added()} {it:P} only selects among the colors added last.

{pstd}
    The contrast ratios are computed according to the Web Content Accessibility
    Guidelines (WCAG) 2.0 at
    {browse "https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef":www.w3.org}. Let
    Y0 be the Y attribute of the lighter color, and Y1 be the
    Y attribute of the darker color, in CIE XYZ space (in Y_white =
    100 scaling). The contrast ratio is then defined as (Y0 + 5) / (Y1 + 5).
    Typically, a contrast ratio of at least 4.5 is recommended between
    foreground text and background fill.

{pstd}
    Opacity settings and intensity adjustment multipliers are ignored when computing the
    contrast ratios.

{pstd}
    Example: Say, you want to print text inside bars and want the
    text and the bar fill to have the same basic color. One idea is to use colors
    with reduced intensity for the fill and print the text in the original
    color. {it:S}{cmd:.contrast()} may be helpful for finding out by how much you
    need to reduce intensity so that there is enough contrast between text and
    bar fill.

        . {stata "mata: S = ColrSpace()"}
        . {stata `"mata: S.colors("navy maroon")"'}
        . {stata `"mata: S.add_intensify(.6)"'}
        . {stata `"mata: S.contrast((1,3) \ (2,4))"'} {it:(not enough contrast)}
        . {stata `"mata: C = S.Colors()"'}
        . {stata `"mata: t = `" 2 "Text", c(%s) box m(medium) bc(%s)"'"'}
        . {stata `"mata: st_local("t1", sprintf("1"+t, C[1], C[3]))"'}
        . {stata `"mata: st_local("t2", sprintf("2"+t, C[2], C[4]))"'}
        . {stata `"colorpalette mata(S), gropts(text(`t1') text(`t2'))"'}

        . {stata `"mata: S.select((1,2))"'}
        . {stata `"mata: S.add_intensify((.4,.3))"'}
        . {stata `"mata: S.contrast((1,3) \ (2,4))"'} {it:(contrast now ok)}
        . {stata `"mata: C = S.Colors()"'}
        . {stata `"mata: t = `" 2 "Text", c(%s) box m(medium) bc(%s)"'"'}
        . {stata `"mata: st_local("t1", sprintf("1"+t, C[1], C[3]))"'}
        . {stata `"mata: st_local("t2", sprintf("2"+t, C[2], C[4]))"'}
        . {stata `"colorpalette mata(S), gropts(text(`t1') text(`t2'))"'}


{marker util}{...}
{title:Some utilities}

{dlgtab:Number of colors}

{pstd}
    To retrieve the number of colors defined in {it:S}, type

        {it:n} = {it:S}{cmd:.N}[{cmd:_added}]{cmd:()}

{pstd}
    {it:S}{cmd:.N()} returns the total number of colors; {it:S}{cmd:.N_added()}
    returns the number of colors added last.

{marker pclass}{...}
{dlgtab:Palette class}

{pstd}
    To assign a palette class to the colors in {it:S}, type

        {it:S}{cmd:.pclass(}{it:class}{cmd:)}

{pstd}
    where {it:class} is a string scalar such as, e.g., {cmd:"qualitative"} or
    {cmd:"diverging"}. To retrieve the palette class, type

        {it:class} = {it:S}{cmd:.pclass()}

{pstd}
    Functions {it:S}{cmd:.palette()}, {it:S}{cmd:.matplotlib()}, and
    {it:S}{cmd:.generate()} automatically assign a palette class.

{marker pname}{...}
{dlgtab:Palette name}

{pstd}
    To assign a palette name to the colors in {it:S}, type

        {it:S}{cmd:.pname(}{it:name}{cmd:)}

{pstd}
    where {it:name} is a string scalar. To retrieve the palette name, type

        {it:name} = {it:S}{cmd:.pname()}

{pstd}
    Functions {it:S}{cmd:.palette()} and {it:S}{cmd:.matplotlib()} automatically
    assign a palette name.

{marker isipolate}{...}
{dlgtab:Interpolation status}

{pstd}
    {cmd:ColrSpace} maintains a 0/1 flag of whether {it:S}{cmd:.ipolate()} has
    been applied. To retrieve the status of the flag, type

        {it:flag} = {it:S}{cmd:.isipolate()}

{marker clip}{...}
{dlgtab:Clipping}

{pstd}
    For convenience, {cmd:ColrSpace} provides a function that can be used for
    clipping. The syntax is

        {it:C} = {it:S}{cmd:.clip(}{it:C0}{cmd:,} {it:a}{cmd:,} {it:b})

{pstd}
    where {it:C0} is a real matrix of input values, {it:a} is a real scalar
    specifying the lower bound, and {it:b} is a real scalar specifying the upper
    bound. Values in {it:C0} smaller than {it:a} will be set to {it:a}; values larger
    than {it:b} will be set to {it:b}; values between {it:a} and {it:b} as well as
    missing values will be left as is.


{marker source}{...}
{title:Source code and certification script}

{pstd}
    {cmd:lcolrspace.mlib} has been compiled in Stata 14.2. The source code can be
    found in file {help colrspace_source:colrspace_source.sthlp}.

{pstd}
    A certification script testing internal consistency and comparing results to some
    test values and results from the {cmd:colorspacious} Python library by
    Smith (2018) (see file
    {browse "http://github.com/njsmith/colorspacious/blob/master/colorspacious/gold_values.py":gold_values.py}
    at Github) as well as to results obtained from the color calculators at
    {browse "http://colorizer.org/":colorizer.org} and
    {browse "http://www.brucelindbloom.com/index.html?ColorCalculator.html":www.brucelindbloom.com},
    can be found at
    {browse "http://fmwww.bc.edu/repec/bocode/c/colrspace_cscript.do"}.


{marker ref}{...}
{title:References}

{phang}
    Bischof, D. 2017a. G538SCHEMES: module to provide graphics schemes for
    http://fivethirtyeight.com. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s458404.html"}.
    {p_end}
{phang}
    Bischof, D. 2017b. {browse "http://www.stata-journal.com/article.html?article=gr0070":New graphic schemes for Stata: plotplain and plottig}.
    The Stata Journal 17(3): 748–759.
    {p_end}
{phang}
    Brewer, C.A., G.W. Hatchard, M.A. Harrower. 2003. {browse "http://doi.org/10.1559/152304003100010929":ColorBrewer in Print: A Catalog of Color Schemes for Maps}.
    Cartography and Geographic Information Science 30(1): 5–32.
    {p_end}
{phang}
    Brewer, C.A. 2016. Designing Better Maps. A Guide for GIS Users. 2nd ed. Redlands, CA: Esri Press.
    {p_end}
{phang}
    Briatte, F. 2013. SCHEME-BURD: Stata module to provide a
    ColorBrewer-inspired graphics scheme with qualitative and blue-to-red
    diverging colors. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s457623.html"}.
    {p_end}
{phang}
    Hunter, J.D. 2007. {browse "http://dx.doi.org/10.1109/MCSE.2007.55":Matplotlib: A 2D graphics environment}. Computing
    in Science & Engineering 9(3): 90-95.
    {p_end}
{phang}
    Ihaka, R., P. Murrell, K. Hornik, J.C. Fisher, R. Stauffer, A. Zeileis.
    2016. colorspace: Color Space Manipulation. R package version 1.3-2.
    Available from {browse "http://CRAN.R-project.org/package=colorspace"}.
    {p_end}
{phang}
    International Electrotechnical Commission (IEC). 2003. International
    Standard IEC 61966-2-1:1999/AMD1:2003. Amendment 1 – Multimedia systems and
    equipment – Color measurement and management – Part 2-1: Color management –
    Default RGB color space - sRGB. Available from
    {browse "http://www.sis.se/api/document/preview/562720/"}.
    {p_end}
{phang}
    Juul, S. 2003. {browse "http://www.stata-journal.com/article.html?article=gr0002":Lean mainstream schemes for Stata 8 graphics}. The Stata
    Journal 3(3): 295-301.
    {p_end}
{phang}
    Lin, S., J. Fortuna, C. Kulkarni, M. Stone,
    J. Heer. 2013. {browse "http://dx.doi.org/10.1111/cgf.12127":Selecting Semantically-Resonant Colors for Data Visualization}. Computer
    Graphics Forum 32(3pt4): 401-410.
    {p_end}
{phang}
    Lindbloom, B.J. 2017a. Chromatic Adaptation. Revision 06 Apr 2017. Available from
    {browse "http://www.brucelindbloom.com/Eqn_ChromAdapt.html"}.
    {p_end}
{phang}
    Lindbloom, B.J. 2017b. RGB Working Space Information. Revision 06 Apr 2017. Available from
    {browse "http://www.brucelindbloom.com/WorkingSpaceInfo.html"}.
    {p_end}
{phang}
    Lindbloom, B.J. 2017c. RGB/XYZ Matrices. Revision 07 Apr 2017. Available from
    {browse "http://www.brucelindbloom.com/Eqn_RGB_XYZ_Matrix.html"}.
    {p_end}
{phang}
    Luo, R.M., G. Cui, C. Li. 2006.
    {browse "http://doi.org/10.1002/col.20227":Uniform Colour Spaces Based on CIECAM02 Colour Appearance Model}. COLOR
    research and application 31(4): 320–330.
    {p_end}
{phang}
    Luo, M.R., C. Li. 2013. {browse "http://doi.org/10.1007/978-1-4419-6190-7_2":CIECAM02 and Its Recent Developments}. P. 19-58
    in: C. Fernandez-Maloigne (ed.). Advanced Color Image Processing and Analysis. New
    York: Springer.
    {p_end}
{phang}
    Machado, G.M., M.M. Oliveira, L.A.F. Fernandes. 2009.
    {browse "http://doi.org/10.1109/TVCG.2009.113":A Physiologically-based Model for Simulation of Color Vision Deficiency}. IEEE
    Transactions on Visualization and Computer Graphics 15(6): 1291-1298.
    {p_end}
{phang}
    Morris, T. 2013. SCHEME-MRC: Stata module to provide graphics scheme for UK
    Medical Research Council. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s457703.html"}.
    {p_end}
{phang}
    Morris, T. 2015. SCHEME-TFL: Stata module to provide graph scheme, based on
    Transport for London's corporate colour pallette. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s458103.html"}.
    {p_end}
{phang}
    Novak, J. (2016). What every coder should know about gamma. 2016 Sep 21. Available from
    {browse "http://blog.johnnovak.net/2016/09/21/what-every-coder-should-know-about-gamma/"}.
    {p_end}
{phang}
    Okabe, M., K. Ito. 2002. Color Universal Design (CUD). How to make figures and presentations that
    are friendly to Colorblind people. Available from
    {browse "http://jfly.iam.u-tokyo.ac.jp/color/"}.
    {p_end}
{phang}
    Pascale, D. 2003. A review of RGB color spaces ... from xyY to
    R'G'B'. Montreal: The BabelColor Company. Available from
    {browse "http://www.babelcolor.com/index_htm_files/A%20review%20of%20RGB%20color%20spaces.pdf"}.
    {p_end}
{phang}
    Pisati, M. 2007. SPMAP: Stata module to visualize spatial data. Available
    from {browse "http://ideas.repec.org/c/boc/bocode/s456812.html"}.
    {p_end}
{phang}
    SFSO (Swiss Federal Statistical Office). 2017. Layoutrichtlinien. Gestaltungs und
    Redaktionsrichtlinien für Publikationen, Tabellen und grafische
    Assets. Version 1.1.1. Neuchâtel: Bundesamt f{c u:}r Statistik.
    {p_end}
{phang}
    Smith, N.J. (2018). colorspacious 1.1.2: A powerful, accurate, and easy-to-use
    Python library for doing colorspace conversions. Available from
    {browse "http://pypi.org/project/colorspacious"} (DOI
    {browse "http://doi.org/10.5281/zenodo.1214904":10.5281/zenodo.1214904}).
    {p_end}
{phang}
    Tol, P. 2012. Colour Schemes. SRON Technical Note, Doc. no. SRON/EPS/TN/09-002. Available
    from {browse "http://personal.sron.nl/~pault/colourschemes.pdf"}.
    {p_end}
{phang}
    Wikipedia. 2018a. CIE 1931 color space. Revision 22 October 2018. Available from
    {browse "http://en.wikipedia.org/wiki/CIE_1931_color_space"}.
    {p_end}
{phang}
    Wikipedia. 2018b. CIELAB color space. Revision 28 November 2018. Available from
    {browse "http://en.wikipedia.org/wiki/CIELAB_color_space"}.
    {p_end}
{phang}
    Wikipedia. 2018c. CIELUV. Revision 27 August 2018. Available from
    {browse "http://en.wikipedia.org/wiki/CIELUV"}.
    {p_end}
{phang}
    Wikipedia. 2018d. HSL and HSV. Revision 6 November 2018. Available from
    {browse "http://en.wikipedia.org/wiki/HSL_and_HSV"}.
    {p_end}
{phang}
    Wikipedia. 2018e. Mean of circular quantities. Revision 23 November 2018. Available from
    {browse "http://en.wikipedia.org/wiki/Mean_of_circular_quantities"}.
    {p_end}
{phang}
    Wikipedia. 2018f. RGB color model. Revision 22 October 2018. Available from
    {browse "http://en.wikipedia.org/wiki/RGB_color_model"}.
    {p_end}
{phang}
    Wikipedia. 2018g. RGB color space. Revision 8 June 2018. Available from
    {browse "http://en.wikipedia.org/wiki/RGB_color_space"}.
    {p_end}
{phang}
    Wikipedia. 2018h. Standard illuminant. Revision 18 July 2018. Available from
    {browse "http://en.wikipedia.org/wiki/Standard_illuminant"}.
    {p_end}
{phang}
    Wikipedia. 2019a. Color blindness. Revision 7 January 2019. Available from
    {browse "http://en.wikipedia.org/wiki/Color_blindness"}.
    {p_end}
{phang}
    Wikipedia. 2019b. Color difference. Revision 9 January 2019. Available from
    {browse "http://en.wikipedia.org/wiki/Color_difference"}.
    {p_end}
{phang}
    Wikipedia. 2019c. Web colors. Revision 6 January 2019. Available from
    {browse "http://en.wikipedia.org/wiki/Web_colors"}.
    {p_end}
{phang}
    Zeileis, A., K. Hornik, P. Murrell. 2009.
    {browse "http://dx.doi.org/10.1016/j.csda.2008.11.033":Escaping RGBland: Selecting Colors for Statistical Graphics}.
    Computational Statistics & Data Analysis 53: 3259-3270.
    {p_end}


{marker author}{...}
{title:Author}

{pstd}
    Ben Jann, University of Bern, ben.jann@soz.unibe.ch

{pstd}
    Thanks for citing this software as

{pmore}
    Jann, B. (2019). colrspace: Stata module providing a class-based color management system in Mata. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s458597.html"}.


{marker alsosee}{...}
{title:Also see}

{psee}
    Online:  help for {helpb colorpalette} (if installed), {help colorstyle}

