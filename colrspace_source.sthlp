*! version 1.0.2  10may2020  Ben Jann
* {smcl}
* {title:lcolrspace.mlib source code}
*
* {help colrspace_source##class:Class and struct definitions}
* {help colrspace_source##new:Constructor}
* {help colrspace_source##add:Add/added wrappers}
* {help colrspace_source##util:Some utilities}
* {help colrspace_source##illuminants:Illuminants}
* {help colrspace_source##rgbspaces:RGB working spaces}
* {help colrspace_source##viewcond:CIECAM02 viewing conditions}
* {help colrspace_source##chadapt:Chromatic adaption}
* {help colrspace_source##string:String input/output}
* {help colrspace_source##set:Set or retrieve colors}
* {help colrspace_source##opacity:Set or retrieve opacity and intensity}
* {help colrspace_source##ipolate:Color interpolation and mixing}
* {help colrspace_source##order:Recycle, select, and order colors}
* {help colrspace_source##intens:Intensify, saturate, luminate}
* {help colrspace_source##gray:Grayscale conversion}
* {help colrspace_source##cvd:Color vision deficiency simulation}
* {help colrspace_source##diff:Color differences and contrast ratios}
* {help colrspace_source##convert:Translation between color spaces}
* {help colrspace_source##translate:Elementary translators}
* {help colrspace_source##gen:Color generators}
* {help colrspace_source##web:Named web colors}
* {help colrspace_source##palettes:Palettes}
* {help colrspace_source##matplotlib:Matplotlib colormaps}
* 
* {bf:Setup (Stata locals)} {hline}
* {asis}

version 14.2
mata mata set matastrict on

// class & struct
local MAIN   ColrSpace
local Main   class `MAIN' scalar
local CAM02  `MAIN'_CAM02
local Cam02  struct `CAM02' scalar
local AA     class AssociativeArray scalar
// real
local RS     real scalar
local RR     real rowvector
local RC     real colvector
local RV     real vector
local RM     real matrix
// counters
local Int    real scalar
local IntR   real rowvector
local IntC   real colvector
local IntV   real vector
local IntM   real matrix
// string
local SS     string scalar
local SR     string rowvector
local SC     string colvector
local SV     string vector
local SM     string matrix
// transmorphic
local T      transmorphic
local TS     transmorphic scalar
local TV     transmorphic vector
local TM     transmorphic matrix
// pointer
local PV     pointer vector
local PS     pointer scalar
// boolean
local Bool   real scalar
local BoolC  real colvector
local TRUE   1
local FALSE  0
// palettes
local PAL    `SC' `MAIN'
// locals for add/added wrappers
local add       set generate palette matplotlib
local added     info Info contrast delta get reset
local add_added colors Colors opacity alpha intensity intensify saturate ///
                luminate gray cvd ipolate recycle select order reverse
local ADD `T'
local comma
foreach f in `add' `add_added' {
    if "`f'"=="set" local ff add
    else            local ff add_`f'
    local ADD `ADD'`comma' `ff'()
    local comma ","
}
local ADDED `T'
local comma
foreach f in `added' `add_added' {
    local ADDED `ADDED' `comma' `f'_added()
    local comma ","
}
local ADD_ADDED `T'
local comma
foreach f in `add_added' {
    local ADD_ADDED `ADD_ADDED'`comma' add_`f'_added()
    local comma ","
}

* {smcl}
* {marker class}{bf:Class and struct definitions} {hline}
* {asis}

mata:

struct `CAM02' {
    // viewing conditions
    `RS'    Yb         // background luminance factor
    `RS'    LA         // adapting field luminance
    `RS'    F, c, Nc   // surround conditions
    `RV'    KLc1c2     // default J'a'b' coefficients
    // various parameters/constants
    `Bool'  set        // already set?
    `RC'    D
    `RS'    FL, n, z, Ncb, Nbb, Aw
    `RM'    CAT02, iCAT02, HPE, iHPE, HUE
}

class `MAIN' {
    // initialize default whitepoint and working space
    private:
        void    new()
    
    // add/added wrappers
    public:
        `ADD'                 // add_?() functions
        `ADDED'               // ?_added() functions
        `ADD_ADDED'           // add_?_added() functions
        `RS'    N_added()     // number of added colors
    private:
        void    append()      // append new colors
        void    update()      // update appended colors
        `Int'   N0            // number of colors before last addition
        
    
    // Color containers and some utilities
    public:
        `RS'    N()           // number of colors
        `T'     pclass()      // set or return type of palette
        `T'     pname()       // set or return name of palette
        `Bool'  isipolate()   // 1 if interpolated; 0 else
        `RM'    RGB()         // get copy of RGB; undocumented
        `SM'    INFO()        // retrieve copy of info; undocumented
        `BoolC' STOK()        // retrieve copy of stok; undocumented
        `RM'    clip()        // clip values
    private:
        `RM'    RGB           // N x 3 matrix of RGB 0-1 codes
        `RC'    alpha         // N x 1 vectors of opacity values in [0,1]
        `RC'    intensity     // N x 1 vectors of intensity values in [0,1]
        `SM'    info          // N x 2 string vector of color information
        `BoolC' stok          // N x 1 vector: Stata compatible "name"
        `SS'    pclass        // class of palette: qualitative, sequential, diverging
        `SS'    pname         // palette name
        `Bool'  isip          // 1 if interpolated; 0 else
        `SC'    SPACES        // main list of supported color metrics
        `SC'    SPACES2       // additional color metrics
        `SM'    EDGELIST      // edge list for color conversions
    private:
        `RV'    _clip()       // clip vector
        `RS'    __clip()      // clip value
        void    rgb_set()     // set RGB and reinitialize all other containers
        void    rgb_reset()   // reset RGB leaving other containers as is
        void    info_reset()  // reset info based on specified colors
        `SC'    _info_reset()
        `SS'    gettok()      // split first token from rest
        `Bool'  smatch()      // check abbreviated string
        `SS'    findkey()     // find key in list (ignoring case; allowing abbreviation)
        void    assert_cols() // assert number of columns
        void    assert_size() // assert number of columns and rows

    // XYZ reference white
    public:
        `T'     xyzwhite()    // set/retrieve XYZ whitepoint
    private:
        `AA'    illuminants
        void    illuminants()
        `RR'    white
        `RR'    _white(), _white_set(), _white_get()

    // RGB working spaces
    public:
        void    rgbspace()    // set RGB working space
        `T'     rgb_gamma()   // set/retrieve gamma compression parameters
        `T'     rgb_white()   // set/retrieve RGB reference white
        `T'     rgb_xy()      // set/retrieve primaries of RGB working space
        `T'     rgb_M()       // set/retrieve RGB-XYZ transformation matrix
        `T'     rgb_invM()    // set/retrieve XYZ-RGB transformation matrix
    private:
        `RV'    rgb_gamma
        `RR'    rgb_white
        `RM'    rgb_xy, rgb_M, rgb_invM

    // CIECAM02 viewing conditions and J'a'b' coefficients
    public:
        `T'     viewcond()    // set/retrieve CAM02 viewing conditions
        `T'     ucscoefs()    // parse coefficients for J'M'h and J'a'b'
    private:
        `Cam02' C02
        `RS'    viewcond_parsenum()
        void    surround()
        `RR'    surround_get()
        `RR'    ucscoefs_get()
    
    // Chromatic adaption
    public:
        `RM'    XYZ_to_XYZ()  // chromatic adaption
        `T'     chadapt()     // set/retrieve chromatic adaption method
        `RM'    tmatrix()     // retrieve chromatic adaption matrix
    private:
        `SS'    chadapt       // chromatic adaption setting

    // String IO
    public:
        `T'     colors()      // parse or return string colors (scalar)
        `T'     Colors()      // parse or return string colors (vector)
        `T'     info()        // parse or return color info (scalar)
        `T'     Info()        // parse or return color info (vector)
    private:
        `SS'    colors_get(), info_get()
        `SC'    Colors_get(), Info_get()
        void    colors_set(), info_set()
        void    Colors_set(), Info_set()
        void    parse_split(), parse_convert()
        `RR'    parse_named()
        `SS'    parse_stcolorstyle(), _parse_stcolorstyle(), parse_webcolor()
        void    ERROR_color_invalid(), ERROR_color_not_found()
        `SR'    _tokens()     // modified version of tokens

    // Set or retrieve colors
    public:
        void    set(), reset()
        `TM'    get()
    private:
        void    _set()

    // Set or retrieve opacity and intensity
    public:
        `T'     opacity(), alpha(), intensity()
    private:
        void    _alpha()

    // Color interpolation and mixing
    public:
        void    ipolate()     // interpolate colors
        `RM'    colipolate()  // interpolate columns
        void    mix()         // mix colors
    private:
        `RM'    ipolate_get(), mix_get(), _ipolate(), _ipolate_pos()
        `RC'    _ipolate_halign()
        `RV'    _ipolate_setrange()
        void    ipolate_set(), _ipolate_fromto(), _ipolate_collapse()

    // Recycle, select, and order
    public:
        void    recycle()     // recycle colors
        `TM'    colrecycle()  // recycle columns
        void    select()      // select (and reorder) colors
        void    order(), reverse() // reorder colors
    private:
        void    _select()

    // Intensify, saturate, luminate
    public:
        void    intensify(), saturate(), luminate()
    private:
        `RR'    _intensify()

    // Grayscale conversion
    public:
        void    gray()
    private:
        `RM'    GRAY()

    // Color vision deficiency
    public:
        void    cvd()         // apply color vision deficiency simulation
        `RM'    cvd_M()       // retrieve CVD transformation matrix
    private:
        `RM'    CVD()
        `RM'    cvd_M_d(), cvd_M_p(), cvd_M_t()

    // Color differences and contrast ratios
    public:
        `RC'    contrast(), delta()
    private:
        `RC'    delta_jab(), delta_euclid()

    // Translation between color spaces (without storing the colors)
    public:
        `TM'    convert()
    private:
        `Bool'  convert_parse()
        `SM'    convert_getpath()
        `TM'    convert_run()
    
    // Elementary translators
    private:
        // HEX
        `SC'    RGB_to_HEX()
        `RM'    HEX_to_RGB()
        `SS'    _RGB_to_HEX()
        `RR'    _HEX_to_RGB()
        // CMYK
        `RM'    CMYK1_to_CMYK(), CMYK_to_CMYK1()
        `RM'    RGB1_to_CMYK1(), CMYK1_to_RGB1()
        `RR'    _RGB1_to_CMYK1(), _CMYK1_to_RGB1()
        // RGB
        `RM'    RGB1_to_RGB(), RGB_to_RGB1()
        `RM'    RGB1_to_lRGB(), lRGB_to_RGB1()
        // CIE XYZ / CIE xyY
        `RM'    lRGB_to_XYZ(), XYZ_to_lRGB(), XYZ_to_XYZ1(), XYZ1_to_XYZ()
        `RM'    XYZ_to_xyY(), xyY_to_XYZ(), xyY_to_xyY1(), xyY1_to_xyY()
        // CIE L*a*b* / CIE LCh
        `RM'    XYZ_to_Lab(),  Lab_to_XYZ(), Lab_to_LCh(), LCh_to_Lab()
        `RR'    _XYZ_to_Lab(),   _Lab_to_XYZ()
        `RS'    _XYZ_to_Lab_f(), _Lab_to_XYZ_f()
        // CIE L*u*v* / HCL
        `RM'    XYZ_to_Luv(),  Luv_to_XYZ(), Luv_to_HCL(), HCL_to_Luv()
        `RR'    _XYZ_to_Luv(), _Luv_to_XYZ()
        `RS'    _XYZ_to_Luv_u(), _XYZ_to_Luv_v()
        // CIE CAM02 / J'a'b'
        `RM'    XYZ_to_CAM02(), CAM02_to_XYZ()
        `RR'    _XYZ_to_CAM02(), _CAM02_to_XYZ()
        `RM'    CAM02_to_CAM02()
        void    CAM02_to_CAM02_Q(), CAM02_setup()
        `RS'    CAM02_H(), CAM02_invH()
        `RM'    CAM02_to_Jab(), Jab_to_CAM02()
        `RM'    CAM02_to_JMh(), JMh_to_CAM02()
        // HSV
        `RM'    RGB1_to_HSV(),  HSV_to_RGB1()
        `RR'    _RGB1_to_HSV(), _HSV_to_RGB1()
        // HSL
        `RM'    RGB1_to_HSL(),  HSL_to_RGB1()
        `RR'    _RGB1_to_HSL(), _HSL_to_RGB1()
    
    // Color generators
    public:
        void    generate()
    private:
        void    generate_HUE(), generate_OTH(), generate_setup()
        `RM'    generate_qual(), generate_seq(), generate_div(),
                generate_heat0(), generate_terrain0()
    
    // Web colors
    private:
        `AA'    webcolors
        void    webcolors()
    
    // Palettes
    public:
        void    palette()
    private:
        `SC'    P_()
        `SC'    P_s1(), P_s1r(), P_s2(), P_economist(), P_mono(), P_cblind(),
                P_plottig(), P_538(), P_tfl(), P_mrc(), P_burd(), P_lean(),
                P_webc(), P_webc_pi(), P_webc_pu(), P_webc_rd(), P_webc_ye(),
                P_webc_gn(), P_webc_cy(), P_webc_bl(), P_webc_br(),
                P_webc_wh(), P_webc_gray(), P_webc_grey(),
                P_d3_10(), P_d3_20(), P_d3_20b(), P_d3_20c(), P_Accent(),
                P_Dark2(), P_Paired(), P_Pastel1(), P_Pastel2(), P_Set1(),
                P_Set2(), P_Set3(), P_Blues(), P_BuGn(), P_BuPu(), P_GnBu(),
                P_Greens(), P_Greys(), P_OrRd(), P_Oranges(), P_PuBu(),
                P_PuBuGn(), P_PuRd(), P_Purples(), P_RdPu(), P_Reds(),
                P_YlGn(), P_YlGnBu(), P_YlOrBr(), P_YlOrRd(), P_BrBG(),
                P_PRGn(), P_PiYG(), P_PuOr(), P_RdBu(), P_RdGy(), P_RdYlBu(),
                P_RdYlGn(), P_Spectral(), P_ptol_qualitative(),
                P_ptol_diverging(), P_ptol_rainbow(), P_tableau(),
                P_lin_carcolor(), P_lin_carcolor_a(), P_lin_food(),
                P_lin_food_a(), P_lin_features(), P_lin_features_a(),
                P_lin_activities(), P_lin_activities_a(), P_lin_fruits(),
                P_lin_fruits_a(), P_lin_vegetables(), P_lin_vegetables_a(),
                P_lin_drinks(), P_lin_drinks_a(), P_lin_brands(),
                P_lin_brands_a(), P_spmap_blues(), P_spmap_greens(),
                P_spmap_greys(), P_spmap_reds(), P_spmap_rainbow(),
                P_spmap_heat(), P_spmap_terrain(), P_spmap_topological(),
                P_sfso_brown(), P_sfso_orange(), P_sfso_red(), P_sfso_pink(),
                P_sfso_purple(), P_sfso_violet(), P_sfso_blue(),
                P_sfso_ltblue(), P_sfso_turquoise(), P_sfso_green(),
                P_sfso_olive(), P_sfso_black(), P_sfso_parties(),
                P_sfso_languages(), P_sfso_votes()
    
    // matplotlib colormaps
    public:
        void    matplotlib()
        `RM'    matplotlib_ip()
    private:
        `RC'    _matplotlib_ip()
        void    inferno(), magma(), plasma(), viridis(), cividis(), twilight()
}

end

* {smcl}
* {marker new}{bf:Constructor} {hline}
* {asis}

mata:

void `MAIN'::new()
{
    rgbspace("")
    xyzwhite("")
    viewcond(.)
    ucscoefs("")
    chadapt("")
    rgb_set(J(0, 3, .))
    isip = `FALSE'
    SPACES   = ("CMYK1", "RGB1", "lRGB", "HSV", "HSL", "XYZ", "xyY", 
                "Lab", "LCh", "Luv", "HCL", "CAM02", "JMh", "Jab")'
    SPACES2  = ("HEX", "CMYK", "RGB", "XYZ1", "xyY1")'
    EDGELIST = ("RGB1", "RGB"  ) \ ("RGB"  , "HEX"  ) \
               ("RGB1", "CMYK1") \ ("CMYK1", "CMYK" ) \
               ("RGB1", "HSV"  ) \ ("RGB1" , "HSL"  ) \
               ("RGB1", "lRGB" ) \ ("lRGB" , "XYZ"  ) \
               ("XYZ" , "XYZ1" ) \ ("XYZ"  , "xyY"  ) \ ("xyY"  , "xyY1" ) \ 
               ("XYZ" , "Lab"  ) \ ("Lab"  , "LCh"  ) \
               ("XYZ" , "Luv"  ) \ ("Luv"  , "HCL"  ) \
               ("XYZ" , "CAM02") \ ("CAM02", "JMh"  ) \ ("CAM02", "Jab"  )
    EDGELIST = EDGELIST \ EDGELIST[,(2,1)] \ ("RGB1", "GRAY") \ ("RGB1", "CVD")
    N0 = 0
}

end

* {smcl}
* {marker add}{bf:Add/added wrappers} {hline}
* {asis}

foreach f in `add' `add_added' {
    if "`f'"=="set" local ff add
    else            local ff add_`f'
    mata: ///
    `T' `MAIN'::`ff'(| `T' o1, `T' o2, `T' o3, `T' o4, `T' o5, `T' o6) ///
    {; ///
        `Main' S; ///
        `T'    T; ///
        S = this; ///
        if      (args()==0) T = S.`f'(); ///
        else if (args()==1) T = S.`f'(o1); ///
        else if (args()==2) T = S.`f'(o1, o2); ///
        else if (args()==3) T = S.`f'(o1, o2, o3); ///
        else if (args()==4) T = S.`f'(o1, o2, o3, o4); ///
        else if (args()==5) T = S.`f'(o1, o2, o3, o4, o5); ///
        else if (args()==6) T = S.`f'(o1, o2, o3, o4, o5, o6); ///
        append(S); ///
        return(T); ///
    }
}
foreach f in `added' `add_added' {
    mata: ///
    `T' `MAIN'::`f'_added(| `T' o1, `T' o2, `T' o3, `T' o4, `T' o5, `T' o6) ///
    {; ///
        `Main' S; ///
        `T'    T; ///
        S = this; ///
        S.select((N0+1)::max((N(), N0+1))); ///
        if      (args()==0) T = S.`f'(); ///
        else if (args()==1) T = S.`f'(o1); ///
        else if (args()==2) T = S.`f'(o1, o2); ///
        else if (args()==3) T = S.`f'(o1, o2, o3); ///
        else if (args()==4) T = S.`f'(o1, o2, o3, o4); ///
        else if (args()==5) T = S.`f'(o1, o2, o3, o4, o5); ///
        else if (args()==6) T = S.`f'(o1, o2, o3, o4, o5, o6); ///
        update(S); ///
        return(T); ///
    }
}
foreach f in `add_added' {
    mata: ///
    `T' `MAIN'::add_`f'_added(| `T' o1, `T' o2, `T' o3, `T' o4, `T' o5, `T' o6) ///
    {; ///
        `Main' S; ///
        `T'    T; ///
        S = this; ///
        S.select((N0+1)::max((N(), N0+1))); ///
        if      (args()==0) T = S.`f'(); ///
        else if (args()==1) T = S.`f'(o1); ///
        else if (args()==2) T = S.`f'(o1, o2); ///
        else if (args()==3) T = S.`f'(o1, o2, o3); ///
        else if (args()==4) T = S.`f'(o1, o2, o3, o4); ///
        else if (args()==5) T = S.`f'(o1, o2, o3, o4, o5); ///
        else if (args()==6) T = S.`f'(o1, o2, o3, o4, o5, o6); ///
        append(S); ///
        return(T); ///
    }
}

mata:

void `MAIN'::append(`Main' S)
{
    N0        = N()
    RGB       = RGB       \ S.RGB()
    alpha     = alpha     \ S.alpha()
    intensity = intensity \ S.intensity()
    info      = info      \ S.INFO()
    stok      = stok      \ S.STOK()
    if (S.pclass()!="")        pclass = S.pclass()
    if (S.pname()!="")         pname  = S.pname()
    if (S.isipolate()==`TRUE') isip   = `TRUE'
}

void `MAIN'::update(`Main' S)
{
    if (N0<N()) {
        RGB       = RGB[|1,1 \ N0,.|]   \ S.RGB()
        alpha     = alpha[|1 \ N0|]     \ S.alpha()
        intensity = intensity[|1 \ N0|] \ S.intensity()
        info      = info[|1,1 \ N0,.|]  \ S.INFO()
        stok      = stok[|1 \ N0|]      \ S.STOK()
    }
    if (S.pclass()!="")        pclass = S.pclass()
    if (S.pname()!="")         pname  = S.pname()
    if (S.isipolate()==`TRUE') isip   = `TRUE'
}

end

* {smcl}
* {marker util}{bf:Some utilities} {hline}
* {asis}

mata:

`RS' `MAIN'::N() return(rows(RGB))

`RS' `MAIN'::N_added() return(rows(RGB) - N0)

`T' `MAIN'::pclass(| `SS' s)
{
    if (args()==0) return(pclass)
    pclass = s
}

`T' `MAIN'::pname(| `SS' s)
{
    if (args()==0) return(pname)
    pname = s
}

`Bool' `MAIN'::isipolate() return(isip)

`RM' `MAIN'::RGB() return(RGB)

`SM' `MAIN'::INFO() return(info)

`BoolC' `MAIN'::STOK() return(stok)

`RM' `MAIN'::clip(`RM' C0, `RS' a, `RS' b)
{
    `Int' i
    `RM'  C

    C = C0
    for (i=cols(C); i; i--) C[,i] = _clip(C[,i], a, b)
    return(C)
}

`RV' `MAIN'::_clip(`RV' C0, `RS' a, `RS' b)
{
    `Int' i
    `RM'  C

    C = C0
    for (i=length(C); i; i--) C[i] = __clip(C[i], a, b)
    return(C)
}

`RS' `MAIN'::__clip(`RS' c, `RS' a, `RS' b) 
    return(c<a ? a : (c<=b ? c : (c>=. ? c : b)))

void `MAIN'::rgb_set(`RM' rgb)
{
    assert_cols(rgb, 3)
    RGB   = rgb
    alpha = intensity = J(N(), 1, .)
    stok  = J(N(), 1, `FALSE')
    info  = J(N(), 2, "")
    isip  = `FALSE'
}

void `MAIN'::rgb_reset(`RM' rgb, | `IntV' p)
{
    if (length(p)==0) {
        assert_size(rgb, N(), 3)
        RGB  = rgb
        stok = J(N(), 1, `FALSE')
        return
    }
    assert_size(rgb, length(p), 3)
    RGB[p,] = rgb
    stok[p] = J(length(p), 1, `FALSE')
}

void `MAIN'::info_reset(`SS' c, `T' C, | `SS' fmt, `IntV' p)
{
    `SC' INFO
    
    INFO = _info_reset(c, C, fmt)
    if (length(p)==0) {
        info = J(length(INFO), 1, ""), INFO
        return
    }
    info[p,] = (J(length(p), 1, ""), INFO)
}

`SC' `MAIN'::_info_reset(`SS' c, `T' C, `SS' fmt)
{
    `Int' i
    `SC'  info
    
    if (isstring(C)) {
        info = J(length(C), 1, (c!="" ? c + " " : ""))
        if (cols(C)!=1) info = info + C'
        else            info = info + C
        return(info)
    }
    info = J(rows(C), 1, (c!="" ? c + " " : ""))
    for (i=1; i<=cols(C); i++) {
        if (i>1) info = info :+ " "
        info = info + strofreal(C[,i], fmt)
    }
    return(info)
}

`SS' `MAIN'::gettok(`SS' s0, | `SS' rest)
{
    // gets the first word and returns remainder in -rest-; removes 
    // blanks around first word and around rest
    `SS'  s
    `Int' p
    
    s = strtrim(s0)
    if (p = strpos(s, " ")) {
        rest = strtrim(substr(s, p+1, .))
        return(substr(s, 1, p-1))
    }
    rest = ""
    return(s)
}

`Bool' `MAIN'::smatch(`SS' s, `SS' s0)
{   // checks whether s matches s0, word by word, allowing abbreviation
    // assumes s to be lower case and checks against lowercase(s0)
    // abbreviation to "nothing" also counts as a match; i.e. empty s will 
    // match anything
    // in case of a match, s is replaced by s0
    `Int'  i, c, c0
    `SR'   S, S0
    `SS'   si
    
    S = tokens(s); c = cols(S)
    if (c==0) { // s is empty
        s = s0
        return(`TRUE')
    }
    S0 = tokens(s0); c0 = cols(S0)
    if (c0==0) return(`FALSE') // no match if s0 is empty
    if (c>c0)  return(`FALSE') // no match if s has more words than s0
    if (c0==1) {
        if (S==substr(strlower(S0), 1, strlen(S))) {
            s = s0
            return(`TRUE')
        }
        return(`FALSE')
    }
    if (c<c0) S = S, J(1, c0-c, "")
    for (i=c0; i; i--) {
        si = S[i]
        if (si!=substr(strlower(S0[i]), 1, strlen(si))) return(`FALSE')
    }
    s = s0
    return(`TRUE')
}

`SS' `MAIN'::findkey(`SS' s0, `SC' KEYS0, | `SS' def)
{   // gets matching key, ignoring case and allowing abbreviation; returns
    // alphabetically first match in case of multiple matches
    // returns def is s0 is empty
    // returns empty string if key not found
    `Int' i, r
    `SS'  s
    `SC'  KEYS, keys
    `RC'  p
    
    s = strlower(s0)
    if (strtrim(s)=="") return(def)
    r = rows(KEYS0)
    if (r==0) return("")
    KEYS = KEYS0; keys = strlower(KEYS)
    p = ::order(keys, 1)
    for (i=1; i<=r; i++) {
        if (smatch(s, keys[p[i]])) return(KEYS[p[i]])
    }
    return("")
}

void `MAIN'::assert_cols(`T' M, `RS' c)
{
    if (cols(M)!=c) {
        printf("{err}input must have %g columns\n", c)
        exit(3200)
    }
}

void `MAIN'::assert_size(`T' M, `RS' r, `RS' c)
{
    if (rows(M)!=r | cols(M)!=c) {
        printf("{err}input must be %g x %g\n", r, c)
        exit(3200)
    }
}

end

* {smcl}
* {marker illuminants}{bf:Illuminants (CIE 1931 2° and CIE 1964 10°)} {hline}
* Sources:
*   {browse "http://www.babelcolor.com/index_htm_files/A%20review%20of%20RGB%20color%20spaces.pdf"}
*   {browse "http://www.brucelindbloom.com/index.html?Eqn_ChromAdapt.html"} (BL)
*   {browse "https://en.wikipedia.org/wiki/Standard_illuminant"} (Wiki)
* {asis}

mata:

void `MAIN'::illuminants()
{
    illuminants.notfound(J(1,0,.))
    // Incandescent / Tungsten, 2856 K
    illuminants.put("A"             , (109.85 , 100, 35.585))
    illuminants.put("A 10 degree"   , (111.144, 100, 35.2  ))
    // Direct Sunlight at Noon, 4874 K (obsolete)
    illuminants.put("B"             , ( 99.09 , 100, 85.324))  // default variant
    illuminants.put("B BL"          , ( 99.072, 100, 85.223))  // BL
    illuminants.put("B 10 degree"   , (0.34980, 0.35270))  // Wiki 
    // North Sky Daylight, 6774 K (obsolete)
    illuminants.put("C"             , ( 98.074, 100, 118.232))
    illuminants.put("C 10 degree"   , ( 97.285, 100, 116.145))
    // Daylight, used for Color Rendering, 5000 K (Wiki: Horizon Light, 5003 K)
    illuminants.put("D50"           , ( 96.422, 100,  82.521))
    illuminants.put("D50 10 degree" , ( 96.72 , 100,  81.427))
    // Daylight, used for Photography, 5500 K (Wiki: Mid-morning / Mid-afternoon Daylight, 5503 K)
    illuminants.put("D55"           , ( 95.682, 100,  92.149))
    illuminants.put("D55 10 degree" , ( 95.799, 100,  90.926))
    // New version of North Sky Daylight, 6504 K (Wiki: Noon Daylight)
    illuminants.put("D65"           , ( 95.047, 100, 108.883))
    illuminants.put("D65 10 degree" , ( 94.811, 100, 107.304))
    // Daylight, 7500 K (Wiki: North sky Daylight, 7504 K)
    illuminants.put("D75"           , ( 94.972, 100, 122.638))
    illuminants.put("D75 10 degree" , ( 94.416, 100, 120.641))
    // High eff. blue phosphor monitors, 9300 K
    illuminants.put("9300K"         , ( 97.135, 100, 143.929))
    // Uniform energy illuminant, 5400 K (Wiki: 5454 K)
    illuminants.put("E"             , (100    , 100, 100))
    // Wiki: Daylight Fluorescent, 6430 K
    illuminants.put("F1"            , (0.31310, 0.33727))
    illuminants.put("F1 10 degree"  , (0.31811, 0.33559))
    // Cool White Fluorescent (CWF), 4200 K (Wiki: 4230 K)
    illuminants.put("F2"            , ( 99.186, 100,  67.393))
    illuminants.put("F2 10 degree"  , (103.279, 100,  69.027))
    // Wiki: White Fluorescent, 3450 K
    illuminants.put("F3"            , (0.40910, 0.39430))
    illuminants.put("F3 10 degree"  , (0.41761, 0.38324))
    // Wiki: Warm White Fluorescent, 2940 K
    illuminants.put("F4"            , (0.44018, 0.40329))
    illuminants.put("F4 10 degree"  , (0.44920, 0.39074))
    // Wiki: Daylight Fluorescent, 6350 K
    illuminants.put("F5"            , (0.31379, 0.34531))
    illuminants.put("F5 10 degree"  , (0.31975, 0.34246))
    // Wiki: Lite White Fluorescent, 4150 K
    illuminants.put("F6"            , (0.37790, 0.38835))
    illuminants.put("F6 10 degree"  , (0.38660, 0.37847))
    // Broad-band Daylight Fluorescent, 6500 K (Wiki: D65 simulator, Daylight simulator)
    illuminants.put("F7"            , ( 95.041, 100, 108.747))
    illuminants.put("F7 10 degree"  , ( 95.792, 100, 107.686))
    // Wiki: D50 simulator, Sylvania F40 Design 50, 5000 K
    illuminants.put("F8"            , (0.34588, 0.35875))
    illuminants.put("F8 10 degree"  , (0.34902, 0.35939))
    // Wiki: Cool White Deluxe Fluorescent, 4150 K
    illuminants.put("F9"            , (0.37417, 0.37281))
    illuminants.put("F9 10 degree"  , (0.37829, 0.37045))
    // Wiki: Philips TL85, Ultralume 50, 5000 K
    illuminants.put("F10"           , (0.34609, 0.35986))
    illuminants.put("F10 10 degree" , (0.35090, 0.35444))
    // Narrow-band White Fluorescent, 4000 K (Wiki: Philips TL84, Ultralume 40)
    illuminants.put("F11"           , (100.962, 100,  64.35 ))
    illuminants.put("F11 10 degree" , (103.863, 100,  65.607))
    // Wiki: Philips TL83, Ultralume 30, 3000 K
    illuminants.put("F12"           , (0.43695, 0.40441))
    illuminants.put("F12 10 degree" , (0.44256, 0.39717))
}

`T' `MAIN'::xyzwhite(| `TV' X, `RS' Y, `RS' Z)
{
    if (args()==0) return(white)
    if      (args()==3) white = _white((X,Y,Z))
    else if (args()==2) white = _white((X,Y))
    else                white = _white(X)
    C02.set = 0 // reset CIECAM02 containers
}

`RR' `MAIN'::_white(`TV' white)
{
    if (length(white)==0) return(_white_set(_white_get("")))
    if (white==.)         return(_white_set(_white_get("")))
    if (isstring(white))  return(_white_set(_white_get(white)))
    return(_white_set(white))
}

`RR' `MAIN'::_white_set(`RV' white)
{
    if (missing(white)) exit(error(127)) // missings not allowed
    if (length(white)==2) { // xy
        if (cols(white)==1) return(xyY_to_XYZ((white', 100)))
        return(xyY_to_XYZ((white, 100)))
    }
    if (length(white)==3) { // XYZ
        if (cols(white)==1) return(white')
        return(white)
    }
    exit(error(503)) // wrong size
}

`RR' `MAIN'::_white_get(`SS' illuminant0)
{
    `SS' illuminant
    `RR' white
    
    if (illuminants.N()==0) illuminants()
    illuminant = strtrim(illuminant0)
    if (illuminant=="") illuminant = "D65" // default
    white = illuminants.get(illuminant)
    if (length(white)==0) {
        illuminant = findkey(illuminant, illuminants.keys())
        if (illuminant!="") white = illuminants.get(illuminant)
        else {
            white = strtoreal(tokens(illuminant0))
            if ((length(white)!=3 & length(white)!=2) | missing(white)) {
                display("{err}illuminant '" + illuminant0 + "' not allowed")
                exit(3498)
            }
        }
    }
    return(white)
}

end

* {smcl}
* {marker rgbspaces}{bf:RGB working spaces} {hline}
* Sources:
*   {browse "http://www.babelcolor.com/index_htm_files/A%20review%20of%20RGB%20color%20spaces.pdf"}
*   {browse "http://www.brucelindbloom.com/index.html?WorkingSpaceInfo.html"} (BL)
* {asis}

mata:

void `MAIN'::rgbspace(| `SS' space0)
{
    `SS' space
    
    space = strtrim(space0)
    if (space=="") space = "sRGB" // default
    space = strlower(space)
    if      (smatch(space, "Adobe 1998")) {     // Adobe RGB (1998)
        rgb_gamma(2.2) 
        rgb_white("D65") 
        rgb_xy((0.6400, 0.3300) \ (0.2100, 0.7100) \ (0.1500, 0.0600))
    }
    else if (smatch(space, "Apple")) {          // Apple RGB
        rgb_gamma(1.8)
        rgb_white("D65")
        rgb_xy((0.6250, 0.3400) \ (0.2800, 0.5950) \ (0.1550, 0.0700))
    }
    else if (smatch(space, "Best")) {           // Best RGB
        rgb_gamma(2.2)
        rgb_white("D50")
        rgb_xy((0.7347, 0.2653) \ (0.2150, 0.7750) \ (0.1300, 0.0350))
    }
    else if (smatch(space, "Beta")) {           // Beta RGB
        rgb_gamma(2.2)
        rgb_white("D50")
        rgb_xy((0.6888, 0.3112) \ (0.1986, 0.7551) \ (0.1265, 0.0352))
    }
    else if (smatch(space, "Bruce")) {          // Bruce RGB
        rgb_gamma(2.2)
        rgb_white("D65")
        rgb_xy((0.6400, 0.3300) \ (0.2800, 0.6500) \ (0.1500, 0.0600))
    }
    else if (smatch(space, "CIE")) {            // CIE RGB
        rgb_gamma(2.2)
        rgb_white("E")
        rgb_xy((0.7350, 0.2650) \ (0.2740, 0.7170) \ (0.1670, 0.0090))
    }
    else if (smatch(space, "ColorMatch")) {     // ColorMatch RGB
        rgb_gamma(1.8)
        rgb_white("D50")
        rgb_xy((0.6300, 0.3400) \ (0.2950, 0.6050) \ (0.1500, 0.0750))
    }
    else if (smatch(space, "Don 4")) {          // Don RGB 4
        rgb_gamma(2.2)
        rgb_white("D50")
        rgb_xy((0.6960, 0.3000) \ (0.2150, 0.7650) \ (0.1300, 0.0350))
    }
    else if (smatch(space, "ECI v2")) {         // ECI RGB v2
        rgb_gamma(3, 0.16, 216/24389 /*=0.08/(24389/2700)*/, 24389/2700)
        rgb_white("D50")
        rgb_xy((0.6700, 0.3300) \ (0.2100, 0.7100) \ (0.1400, 0.0800))
    }
    else if (smatch(space, "Ekta PS5")) {       // Ekta Space PS5
        rgb_gamma(2.2)
        rgb_white("D50")
        rgb_xy((0.6950, 0.3050) \ (0.2600, 0.7000) \ (0.1100, 0.0050))
    }
    else if (smatch(space, "Generic")) {        // Generic RGB (source?)
        rgb_gamma(1.8)
        rgb_white("D65")
        rgb_xy((0.6295, 0.3407) \ (0.2949, 0.6055) \ (0.1551, 0.0762))
    }
    else if (smatch(space, "HDTV")) {           // HDTV (HD-CIF)
        rgb_gamma(1/0.45, 0.099, 0.018, 4.5)
        rgb_white("D65")
        rgb_xy((0.6400, 0.3300) \ (0.3000, 0.6000) \ (0.1500, 0.0600))
    }
    else if (smatch(space, "NTSC")) {           // NTSC RGB
        rgb_gamma(1/0.45, 0.099, 0.018, 4.5)
        rgb_white("C")
        rgb_xy((0.6700, 0.3300) \ (0.2100, 0.7100) \ (0.1400, 0.0800))
    }
    else if (smatch(space, "PAL/SECAM")) {      // PAL/SECAM RGB
        rgb_gamma(1/0.45, 0.099, 0.018, 4.5)
        rgb_white("D65")
        rgb_xy((0.6400, 0.3300) \ (0.2900, 0.6000) \ (0.1500, 0.0600))
    }
    else if (smatch(space, "ProPhoto")) {       // ProPhoto RGB
        rgb_gamma(1.8)
        rgb_white("D50")
        rgb_xy((0.7347, 0.2653) \ (0.1596, 0.8404) \ (0.0366, 0.0001))
    }
    else if (smatch(space, "SGI")) {            // SGI
        rgb_gamma(1.47)
        rgb_white("D65")
        rgb_xy((0.6250, 0.3400) \ (0.2800, 0.5950) \ (0.1550, 0.0700))
    }
    else if (smatch(space, "SMPTE-240M")) {     // SMPTE-240M
        rgb_gamma(1/0.45, 0.112, 0.023, 4.0)
        rgb_white("D65")
        rgb_xy((0.6300, 0.3400) \ (0.3100, 0.5950) \ (0.1550, 0.0700))
    }
    else if (smatch(space, "SMPTE-C")) {        // SMPTE-C RGB
        rgb_gamma(1/0.45, 0.099, 0.018, 4.5)
        rgb_white("D65")
        rgb_xy((0.6300, 0.3400) \ (0.3100, 0.5950) \ (0.1550, 0.0700))
    }
    else if (smatch(space, "sRGB")) {          // sRGB (default variant)
        rgb_gamma(2.4, 0.055, 0.0031308, 12.92)
        rgb_white("D65")
        // using primaries from www.brucelindbloom.com
        rgb_xy((0.6400, 0.3300) \ (0.3000, 0.6000) \ (0.1500, 0.0600))
        // with this method the correspondence between RGB white and the 
        // white point is exact; this is not true for sRGB2 and sRGB3
    }
    else if (smatch(space, "sRGB2")) {           // sRGB (2nd variant)
        rgb_gamma(2.4, 0.055, 0.0031308, 12.92)
        rgb_white("D65")
        // using XYZ to RGB matrix given in IEC 61966-2-1
        rgb_invM(( 3.2406, -1.5372, -0.4986) \
                 (-0.9689,  1.8758,  0.0415) \
                 ( 0.0557, -0.2040,  1.0570))
    }
    else if (smatch(space, "sRGB3")) {          // sRGB (3rd variant)
        rgb_gamma(2.4, 0.055, 0.0031308, 12.92)
        rgb_white("D65")
        // using RGB to XYZ matrix given in IEC 61966-2-1
        rgb_M(( .4124, .3576, .1805) \
              ( .2126, .7152, .0722) \
              ( .0193, .1192, .9505))
    }
    else if (smatch(space, "Wide Gamut")) {     // Wide Gamut RGB
        rgb_gamma(2.2)
        rgb_white("D50")
        rgb_xy((0.7347, 0.2653) \ (0.1152, 0.8264) \ (0.1566, 0.0177))
    }
    else if (smatch(space, "Wide Gamut BL")) {  // Wide Gamut RGB (BL variant)
        rgb_gamma(2.2)
        rgb_white("D50")
        // using primaries from www.brucelindbloom.com
        rgb_xy((0.7350, 0.2650) \ (0.1150, 0.8260) \ (0.1570, 0.0180))
    }
    else {
        display("{err}rgbspace '" + space0 + "' not found")
        exit(3499)
    }
}

`T' `MAIN'::rgb_gamma(| `TV' gamma0, `RS' offset, `RS' transition, `RS' slope)
{
    `RV' gamma
    
    if (args()==0) return(rgb_gamma)
    if (args()==1) {
        if (isstring(gamma0)) gamma = strtoreal(tokens(gamma0))
        else                  gamma = gamma0
    }
    else if (args()==4) gamma = (gamma0, offset, transition, slope)
    else _error(3001)   // wrong number of args
    if (missing(gamma)) exit(error(127))   // missings not allowed
    if (length(gamma)!=1 & length(gamma)!=4) exit(error(503)) // wrong size
    rgb_gamma = gamma
    stok = J(N(), 1, `FALSE')
}

`T' `MAIN'::rgb_white(| `TV' X, `RS' Y, `RS' Z)
{
    if (args()==0) return(rgb_white)
    if      (args()==3) rgb_white = _white((X,Y,Z))
    else if (args()==2) rgb_white = _white((X,Y))
    else                rgb_white = _white(X)
    if (length(rgb_xy)) rgb_xy(rgb_xy) // recompute transformation matrices
    stok = J(N(), 1, `FALSE')
}

`T' `MAIN'::rgb_xy(| `RM' xy)
{
    if (args()==0) return(rgb_xy)
    assert_size(xy, 3, 2)
    if (missing(xy)) exit(error(127)) // missings not allowed
    // see http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
    rgb_M = J(3,1,1)
    rgb_M = ((xy[,1]:/xy[,2]), rgb_M, (rgb_M:-xy[,1]:-xy[,2]):/xy[,2])'
    rgb_M = rgb_M :* (luinv(rgb_M) * rgb_white')'
    rgb_invM = luinv(rgb_M)
    rgb_xy = xy
    stok = J(N(), 1, `FALSE')
}

`T' `MAIN'::rgb_M(| `RM' M)
{
    if (args()==0) return(rgb_M / 100)
    assert_size(M, 3, 3)
    if (missing(M)) exit(error(127)) // missings not allowed
    rgb_M = M * 100
    rgb_invM = luinv(rgb_M)
    rgb_xy = J(0,0,.)
    stok = J(N(), 1, `FALSE')
}

`T' `MAIN'::rgb_invM(| `RM' invM)
{
    if (args()==0) return(rgb_invM * 100)
    assert_size(invM, 3, 3)
    if (missing(invM)) exit(error(127)) // missings not allowed
    rgb_invM = invM / 100
    rgb_M = luinv(rgb_invM)
    rgb_xy = J(0,0,.)
    stok = J(N(), 1, `FALSE')
}

end

* {smcl}
* {marker viewcond}{bf:CIECAM02 viewing conditions} {hline}
* Source:
*   Luo, M.R., C. Li (2013). CIECAM02 and its recent developments. P 19-58 in: 
*   C. Fernandez-Maloigne (ed). Advanced color image processing and analysis. 
*   New York: Springer. {browse "https://doi.org/10.1007/978-1-4419-6190-7_2"}
* {asis}

mata:

`T' `MAIN'::viewcond(| `TV' opt1, `RS' LA, `TV' F, `RS' c, `RS' Nc)
{
    `RS' Yb
    
    if (args()==0) return((C02.Yb, C02.LA, C02.F, C02.c, C02.Nc))
    if (args()==1) {
        if (length(opt1)==0 | opt1==.) Yb = .
        else if (isstring(opt1)) {
            Yb = viewcond_parsenum(gettok(opt1, opt1))
            LA = viewcond_parsenum(gettok(opt1, opt1))
            F  = opt1
        }
        else {
            if (length(opt1)!=5) exit(error(503)) // wrong size
            Yb = opt1[1]; LA = opt1[2]; F = opt1[(3,4,5)]; 
        }
    }
    else if (args()==5) {; Yb = opt1; F = (F, c, Nc); }
    else if (args()!=3) _error(3001) // wrong number of args
    else Yb = opt1
    C02.Yb = (Yb<. ? Yb : 20)
    C02.LA = (LA<. ? LA : (64/pi())/5)
    surround(F)
    C02.set = 0 // reset CIECAM02 containers
}

`RS' `MAIN'::viewcond_parsenum(`SS' s)
{
    `RS' r

    if (s=="" | s==".") return(.)
    r = strtoreal(s)
    if (missing(r)) {
        display("{err}'" + s + "' not allowed")
        exit(3498)
    }
    return(r)
}

void `MAIN'::surround(`TV' S0)
{
    `RV' S
    
    if      (length(S0)==0) S = surround_get("")
    else if (S0==.)         S = surround_get("")
    else if (isstring(S0))  S = surround_get(S0)
    else                    S = S0
    if (missing(S)) exit(error(127))   // missings not allowed
    if (length(S)!=3) exit(error(503)) // wrong size
    C02.F = S[1]; C02.c = S[2]; C02.Nc = S[3]
}

`RR' `MAIN'::surround_get(`SS' S0)
{
    `SS' S
    `RR' FcNc

    // presets
    S = strlower(S0)               /*  F   c    Nc  */
    if (smatch(S, "average")) return(( 1, .69 ,  1))
    if (smatch(S, "dim"))     return((.9, .59 , .9))
    if (smatch(S, "dark"))    return((.8, .525, .8))
    // custom values
    FcNc = strtoreal(tokens(S0))
    if (length(FcNc)!=3 | missing(FcNc)) {
        display("{err}surround '" + S0 + "' not allowed")
        exit(3498)
    }
    return(FcNc)
}

`T' `MAIN'::ucscoefs(| `TV' S0, `RS' c1, `RS' c2)
{
    `RV' S
    
    if (args()==0) return(C02.KLc1c2)
    if (args()==3)          S = (S0, c1, c2)
    else if (args()==2)     _error(3001)   // wrong number of args
    else if (length(S0)==0) S = ucscoefs_get("")
    else if (S0==.)         S = ucscoefs_get("")
    else if (isstring(S0))  S = ucscoefs_get(S0)
    else                    S = S0
    if (missing(S)) exit(error(127))   // missings not allowed
    if (length(S)!=3) exit(error(503)) // wrong size
    C02.KLc1c2 = S
}

`RR' `MAIN'::ucscoefs_get(`SS' S0)
{
    `SS' S
    `RR' KLc1c2

    // presets
    S = strlower(S0)          /*  KL    c1     c2   */
    if (smatch(S ,"ucs")) return(1   , 0.007, 0.0228)
    if (smatch(S ,"lcd")) return(0.77, 0.007, 0.0053)
    if (smatch(S ,"scd")) return(1.24, 0.007, 0.0363)
    // custom values
    KLc1c2 = strtoreal(tokens(S0))
    if (length(KLc1c2)!=3 | missing(KLc1c2)) {
        display("{err}ucscoefs '" + S0 + "' not allowed")
        exit(3498)
    }
    return(KLc1c2)
}

end

* {smcl}
* {marker chadapt}{bf:Chromatic adaption} {hline}
* Source: {browse "http://www.brucelindbloom.com/Eqn_ChromAdapt.html"}
* {asis}

mata:

`RM' `MAIN'::XYZ_to_XYZ(`RM' xyz, `TV' from, `TV' to)
{
    `Int' i
    `RS'  d
    `RC'  S, D
    `RM'  XYZ, M
    
    assert_cols(xyz, 3)
    S = _white(from)'; D = _white(to)'
    XYZ = xyz
    M = tmatrix(chadapt)
    if (chadapt=="CAT02") {
        d = __clip(C02.F * (1 - (1/3.6) * exp((-C02.LA - 42)/92)), 0, 1)
        M = luinv(M) * ((d * (S[2]:/D[2]) :* (M * D) :/ (M * S) :+ 1 :- d) :* M)
    }
    else  M = luinv(M) * (((M * D) :/ (M * S)) :* M)
        // equivalent to: luinv(M) * diag((M * D) :/ (M * S)) * M
    _transpose(M)
    for (i=rows(XYZ); i; i--) XYZ[i,] = XYZ[i,] * M
    return(XYZ)
}

`T' `MAIN'::chadapt(| `SS' S0)
{
    `SS' S
    
    if (args()==0) return(chadapt)
    S = strlower(S0)
    if      (smatch(S, "Bfd"))      chadapt = S
    else if (smatch(S, "identity")) chadapt = S 
    else if (smatch(S, "vKries"))   chadapt = S 
    else if (smatch(S, "CAT02"))    chadapt = S 
    else {
        display("{err}method '" + S0 + "' not allowed")
        exit(3498)
    }
}

`RM' `MAIN'::tmatrix(| `SS' mname0) 
{
    `SS' mname
    
    mname = strlower(mname0)
    if (smatch(mname, "Bfd")) {        // Bradford
        return(( 0.8951 ,  0.2664 , -0.1614 ) \
               (-0.7502 ,  1.7135 ,  0.0367 ) \
               ( 0.0389 , -0.0685 ,  1.0296 ))
    }
    if (smatch(mname, "identity")) {   // XYZ Scaling
        return(I(3))
    }
    if (smatch(mname, "vKries")) {     // Von Kries
        return(( 0.40024,  0.70760, -0.08081) \
               (-0.22630,  1.16532,  0.04570) \
               ( 0      ,  0      ,  0.91822))
    }
    if (smatch(mname, "CAT02")) {      // CAT02
        return(( 0.7328 ,  0.4296 , -0.1624 ) \
               (-0.7036 ,  1.6975 ,  0.0061 ) \
               ( 0.0030 ,  0.0136 ,  0.9834 ))
    }
    if (smatch(mname, "HPE")) {        // Hunt-Pointer-Estevez
        return(( 0.38971,  0.68898, -0.07868) \
               (-0.22981,  1.18340,  0.04641) \
               ( 0      ,  0      ,  1      ))
    }
    display("{err}tmatrix '"+ mname0 +  "' not found")
    exit(3499)
}

end

* {smcl}
* {marker string}{bf:String input/output (Stata interface)} {hline}
* {asis}

mata:

`T' `MAIN'::colors(| `TS' opt1, `SS' opt2)
{
    if (args()==0)                     return(colors_get(`FALSE'))
    if (args()==1 & isstring(opt1)==0) return(colors_get(opt1))
    colors_set(opt1, opt2)
}

`T' `MAIN'::Colors(| `TV' opt)
{
    if (args()==0)        return(Colors_get(`FALSE'))
    if (isstring(opt)==0) return(Colors_get(opt))
    Colors_set(opt)
}

`SS' `MAIN'::colors_get(`Bool' rgbforce)
{
    `Int' i
    `SC'  C

     C = Colors_get(rgbforce)
     for (i = N(); i; i--) {
         if (strpos(C[i], " ")) C[i] = `"""' + C[i] + `"""'
     }
     return(invtokens(C'))
}

`SC' `MAIN'::Colors_get(`Bool' rgbforce)
{
    `Int' i
    `SC'  C
    `RM'  RGB
     
     RGB = get("RGB")
     i = N()
     C = J(i, 1, "")
     for (; i; i--) {
         if (rgbforce)             C[i] = invtokens(strofreal(RGB[i,]))
         else if (stok[i]==`TRUE') C[i] = info[i,2]
         else                      C[i] = invtokens(strofreal(RGB[i,]))
         if (alpha[i]<.)           C[i] = C[i] + "%" + strofreal(alpha[i]*100)
         if (intensity[i]<.)       C[i] = C[i] + "*" + strofreal(intensity[i])
     }
     return(C)
}

void `MAIN'::colors_set(`SS' c, `SS' wchar) Colors_set(_tokens(c, wchar))

void `MAIN'::Colors_set(`SV' C)
{
    parse_split(C)
    parse_convert()
}

void `MAIN'::parse_split(`SV' C)
{
    `Int' n, i
    `SS'  tok
    `T'   t
    
    n = length(C)
    rgb_set(J(n, 3, .))
    t = tokeninit("", ("%","*"), "")
    for (i=n; i; i--) {
        tokenset(t, C[i])
        info[i,2] = strtrim(tokenget(t))
        if ((tok = tokenget(t))=="") continue
        if (tok=="%") {
            alpha[i] = strtoreal(tokenget(t))/100
            if (alpha[i]<0 | alpha[i]>1) ERROR_color_invalid(C[i])
            if ((tok = tokenget(t))=="") continue
            if (tok=="*") {
                intensity[i] = strtoreal(tokenget(t))
                if (intensity[i]<0 | intensity[i]>255) ERROR_color_invalid(C[i])
            }
        }
        else if (tok=="*") {
            intensity[i] = strtoreal(tokenget(t))
            if (intensity[i]<0 | intensity[i]>255) ERROR_color_invalid(C[i])
            if ((tok = tokenget(t))=="") continue
            if (tok=="%") {
                alpha[i] = strtoreal(tokenget(t))/100
                if (alpha[i]<0 | alpha[i]>1) ERROR_color_invalid(C[i])
            }
        }
        else ERROR_color_invalid(C[i])
        if (tokenrest(t)=="") continue
        ERROR_color_invalid(C[i])
    }
}

void `MAIN'::parse_convert()
{
    `Int'  r, i, l
    `RR'   TMP
    `SR'   tok
    `SS'   t
    `SC'   type
    `IntC' p

    r = N()
    type = J(r, 1, "")
    for (i=r; i; i--) {
        tok = strtrim(info[i,2])
        if (substr(tok,1,1)=="#") { // HEX color
            RGB[i,] = _HEX_to_RGB(tok)/255
            if (missing(RGB[i,])) ERROR_color_invalid(info[i,2])
            continue
        }
        tok = tokens(tok)
        l = length(tok)
        if (l==0) ERROR_color_invalid(info[i,2])
        if (l==2) ERROR_color_invalid(info[i,2])
        if (l==1) { // named color
            RGB[i,] = parse_named(tok, i)
            info[i,2] = tok
            continue
        }
        if (l==3) { // RGB [0-255]
            TMP = strtoreal(tok)
            if (_clip(round(TMP),0,255)!=TMP) ERROR_color_invalid(info[i,2])
            RGB[i,] = TMP/255
            if (missing(RGB[i,])) ERROR_color_invalid(info[i,2])
            info[i,2] = ""
            continue
        }
        if (l==4) { // check whether CMYK
            if (strtoreal(tok[1])<.) { 
                TMP = strtoreal(tok)
                if (all(TMP:<=1)) { // CMYK [0-1]
                    if (any(TMP:<0)) ERROR_color_invalid(info[i,2])
                    RGB[i,] = _CMYK1_to_RGB1(TMP)
                }
                else {              // CMYK [0-255]
                    if (_clip(round(TMP),0,255)!=TMP) ERROR_color_invalid(info[i,2])
                    RGB[i,] = _CMYK1_to_RGB1(TMP/255) 
                }
                if (missing(RGB[i,])) ERROR_color_invalid(info[i,2])
                stok[i] = `TRUE'
                continue
            }
        }
        t = strlower(tok[1]) // check whether CMYK
        if (t==substr("cmyk1", 1, max((2, strlen(t))))) {
            if (l!=5) ERROR_color_invalid(info[i,2])
            TMP = strtoreal(tok[|2 \ .|])
            if (t=="cmyk1") RGB[i,] = _CMYK1_to_RGB1(TMP)     // CMYK [0-1]
            else            RGB[i,] = _CMYK1_to_RGB1(TMP/255) // CMYK [0-255]
            if (missing(RGB[i,])) ERROR_color_invalid(info[i,2])
            stok[i] = `TRUE'
            continue
        }
        if (l==5) { // check whether RGBA/RGBA1
            if (t=="rgba" | t=="rgba1") {
                TMP = strtoreal(tok[5])
                if (TMP<0 | TMP>1) ERROR_color_invalid(info[i,2])
                if (alpha[i]<.) {
                    display("{err}opacity not allowed with RGBA")
                    exit(3498)
                }
                alpha[i] = TMP
                if (t=="rgba") RGB[i,] = strtoreal(tok[|2 \ 4|])/255
                else           RGB[i,] = strtoreal(tok[|2 \ 4|])
                continue
            }
        }
        type[i] = invtokens(tok[|1 \ l-3|])   // get color space info
        if (type[i]=="") ERROR_color_invalid(info[i,2])
        RGB[i,] = strtoreal(tok[|l-3+1 \ .|]) // get value (last 3 elements)
        if (missing(RGB[i,])) ERROR_color_invalid(info[i,2])
    }
    // convert remaining colors
    for (i=r; i; i--) {
        t = type[i]
        if (t=="") continue
        if (convert_parse(tok, t, 0)) ERROR_color_invalid(info[i,2])
        p = ::select(1::r, type:==t)
        RGB[p,] = convert(RGB[p,], t, "RGB1")
        type[p] = J(length(p), 1, "")
    }
}

`RR' `MAIN'::parse_named(`SS' s, `Int' i)
{
    `SS' c
    `RR' RGB1
    
    // named color provided by official Stata (as of Stata 15.1)
    if (anyof(("black", "blue", "bluishgray", "bluishgray8", "brown", "chocolate",
    "cranberry", "cyan", "dimgray", "dkgreen", "dknavy", "dkorange", "ebblue",
    "ebg", "edkbg", "edkblue", "eggshell", "eltblue", "eltgreen", "emerald",
    "emidblue", "erose", "forest_green", "gold", "gray", "green", "gs0", "gs1",
    "gs10", "gs11", "gs12", "gs13", "gs14", "gs15", "gs16", "gs2", "gs3", "gs4",
    "gs5", "gs6", "gs7", "gs8", "gs9", "khaki", "lavender", "lime", "ltblue",
    "ltbluishgray", "ltbluishgray8", "ltkhaki", "magenta", "maroon", "midblue",
    "midgreen", "mint", "navy", "navy8", "none", "olive", "olive_teal", "orange",
    "orange_red", "pink", "purple", "red", "sand", "sandb", "sienna", "stone",
    "sunflowerlime", "teal", "white", "yellow"), s)) {
        c = _parse_stcolorstyle(findfile("color-"+s+".style"))
    }
    if (c!="") {
        RGB1 = strtoreal(tokens(c))/255
        if (length(RGB1)!=3) ERROR_color_invalid(s)
        stok[i] = `TRUE'
        return(RGB1)
    }
    // web color
    c = parse_webcolor(s)
    if (c!="") {
        RGB1 = _HEX_to_RGB(c)/255
        if (missing(RGB1)) ERROR_color_invalid(s)
        return(RGB1)
    }
    // user color provided as color-<name>.style
    c = parse_stcolorstyle(s)
    if (c!="") {
        RGB1 = strtoreal(tokens(c))/255
        if (length(RGB1)!=3) ERROR_color_invalid(s)
        stok[i] = `TRUE'
        return(RGB1)
    }
    // color not found
    ERROR_color_not_found(s)
}

`SS' `MAIN'::parse_stcolorstyle(`SS' s) // read RGB from color-<name>.style
{   
    `SS' fn, dir, basename
    pragma unset dir
    pragma unset basename

    if (!st_isname(s)) return("")
    fn = findfile("color-"+s+".style")
    if (fn=="") return("")
    // findfile() is not case sensitive, but -graph- is; must check case
        pathsplit(fn, dir, basename) 
        if (length(dir(dir, "files", basename))==0) return("") // no match
    return(_parse_stcolorstyle(fn))
}

`SS' `MAIN'::_parse_stcolorstyle(`SS' fn)
{
    `RS' fh
    `SS' line
    `SM' EOF
    
    if (fn=="") return("")
    fh  = fopen(fn, "r")
    EOF = J(0, 0, "")
    while ((line=fget(fh))!=EOF) {
        line = strtrim(stritrim(line))
        if (substr(line, 1, 8)=="set rgb ") {
            line = tokens(substr(line, 9, .))
            if (length(line)!=1) continue // invalid
            fclose(fh)
            return(line)
        }
    }
    fclose(fh)
    return("") // no valid color definition found
}

`SS' `MAIN'::parse_webcolor(`SS' s0)
{
    `SS'  s, c
    
    if (webcolors.N()==0) webcolors()
    c = webcolors.get(s0)
    if (c=="") {
        s = findkey(s0, webcolors.keys())
        if (s!="") {
            s0 = s
            c = webcolors.get(s0)
        }
    }
    return(c)
}

void `MAIN'::ERROR_color_not_found(`SS' s)
{
    display("{err}color '" + s + "' not found")
    exit(3499)
}

void `MAIN'::ERROR_color_invalid(`SS' s)
{
    display("{err}color '" + s + "' is invalid")
    exit(3498)
}

`T' `MAIN'::info(| `TS' opt1, `SS' opt2)
{
    if (args()==0)                     return(info_get(`FALSE'))
    if (args()==1 & isstring(opt1)==0) return(info_get(opt1))
    info_set(opt1, opt2)
}

`T' `MAIN'::Info(| `TV' opt)
{
    if (args()==0)        return(Info_get(`FALSE'))
    if (isstring(opt)==0) return(Info_get(opt))
    Info_set(opt)
}

`SS' `MAIN'::info_get(`Bool' rgbforce)
{
    `Int' i
    `SC'  C
     
     C = Info(rgbforce)
     if (allof(C, "")) return("")
     for (i = N(); i; i--) {
         if      (C[i]=="")          C[i] = `""""'
         else if (strpos(C[i], " ")) C[i] = `"""' + C[i] + `"""'
     }
     return(invtokens(C'))
}

`SC' `MAIN'::Info_get(`Bool' rgbforce)
{
    `Int' i
    `SC'  C
     
     i = N()
     C = J(i, 1, "")
     for (; i; i--) {
         if (info[i,1]!="")       C[i] = info[i,1]
         else {
             if (stok[i]!=`TRUE') C[i] = info[i,2]
             else if (rgbforce)   C[i] = info[i,2]
         }
     }
     return(C)
}

void `MAIN'::info_set(`SS' c, `SS' wchar)
{
    Info_set(_tokens(c, wchar))
}

void `MAIN'::Info_set(`SV' C)
{
    `Int' i
    
    for (i = min((length(C), N())); i; i--) info[i,1] = C[i]
}

// modified version of tokens; omits delimiters and inserts empty elements 
// between delimiters (as well as at the start if the string begins with a
// delimiter); for example, _tokens(";a;;;b;c", ";") will result in
// ("", "a", "", "", "b", "c")
`SR' `MAIN'::_tokens(`SS' c, `SS' wchar)
{
    `Int'  i, j
    `Bool' gap
    `SR'   C
    
    if (strtrim(wchar)=="") return(tokens(c))
    C = tokens(c, wchar)
    gap = `TRUE'
    j = 0
    for (i=1; i<=length(C); i++) {
        if (strpos(wchar, C[i])) {
            if (gap) C[++j] = ""
            else     gap = `TRUE'
            continue
        }
        gap = `FALSE'
        C[++j] = C[i] 
    }
    if (j) C = C[|1 \ j|]
    return(C)
}

end

* {smcl}
* {marker set}{bf:Set or retrieve colors} {hline}
* {asis}

mata:

void `MAIN'::set(`T' C, | `SS' space) _set(C, space, 0)

void `MAIN'::reset(`T' C, | `SS' space, `IntV' p) _set(C, space, 1, p)

void `MAIN'::_set(`T' C, `SS' space, `Bool' reset, | `IntV' p0)
{
    `SS'   s
    `SR'   S
    `RC'   a
    `IntV' p
    pragma unset S
    
    // preprocess p
    if (reset) {
        p = p0
        if (p==.) p = J(1,0,.)
        else {
            p = (sign(p):!=-1):*p :+ (sign(p):==-1):*(N():+1:+p)
            if (any(p:<1 :| p:>N())) {
                display("{err}p contains invalid indices")
                exit(3300)
            }
        }
    }
    // set colors
    s = strtrim(strlower(space))
    if (s=="rgba" | s=="rgba1") {
        if (s=="rgba") s = "RGB"
        else           s = "RGB1"
        assert_cols(C, 4)
        a = C[,4]
        if (any((a:>1) :| (a:<0))) {
            display("{err}alpha must be in [0,1]")
            exit(3300)
        }
        if (reset) rgb_reset(convert(C[,(1,2,3)], s, "RGB1"), p)
        else       rgb_set(convert(C[,(1,2,3)], s, "RGB1"))
        if (reset) {
            if (length(p)) alpha[p] = C[,4]
            else           alpha = C[,4]
        }
        else alpha = C[,4]
        info_reset("", J(rows(C),1,.), "", p)
        return
    }
    if (reset) rgb_reset(convert(C, space, "RGB1"), p)
    else       rgb_set(convert(C, space, "RGB1"))
    // generate info
    (void) convert_parse(S, space, 0)
    if      (S[1]=="RGB")   info_reset("", J(rows(C),1,.), "", p)
    else if (S[1]=="RGB1")  info_reset("", J(rows(C),1,.), "", p)
    else if (S[1]=="HEX")   info_reset("", C, "", p)
    else if (S[1]=="CMYK")  info_reset("", C, "%9.0f", p)
    else if (S[1]=="CMYK1") info_reset("", C, "%9.3g", p)
    else if (anyof(("lRGB", "XYZ1", "xyY", "xyY1", "HSV", "HSL"), S[1]))
                            info_reset(S[1], C, "%9.3g", p)
    else if (S[1]=="CAM02") info_reset(S[2]!="" ? S[2] : "CAM02", C, "%9.0f", p)
    else                    info_reset(S[1], C, "%9.0f", p)
}

`TM' `MAIN'::get(| `SS' space)
{
    `SS' s
    
    s = strtrim(strlower(space))
    if (s=="rgba")  return((convert(RGB, "RGB1", "RGB"), editmissing(alpha, 1)))
    if (s=="rgba1") return((RGB, editmissing(alpha, 1)))
    return(convert(RGB, "RGB1", space))
}

end

* {smcl}
* {marker opacity}{bf:Set or retrieve opacity and intensity} {hline}
* {asis}

mata:

`T' `MAIN'::opacity(| `RV' O, `RS' noreplace)
{
    if (args()==0) return(alpha*100)
    if (args()<2) noreplace = `FALSE'
    if (any( ((O:<.):&(O:>100)) :| (O:<0) )) {
        display("{err}opacity must be in [0,100]")
        exit(3300)
    }
    _alpha(O/100, noreplace)
}

`T' `MAIN'::alpha(| `RV' A, `RS' noreplace)
{
    if (args()==0) return(alpha)
    if (args()<2) noreplace = `FALSE'
    if (any( ((A:<.):&(A:>1)) :| (A:<0) )) {
        display("{err}alpha must be in [0,1]")
        exit(3300)
    }
    _alpha(A, noreplace)
}


void `MAIN'::_alpha(`RV' A0, `RS' noreplace)
{
    `Int' i
    `RC'  A
    
    if (length(A0)==0) return
    if (cols(A0)>1) A = A0'
    else            A = A0
    if      (rows(A)<N()) A = colrecycle(A, N())
    else if (rows(A)>N()) recycle(rows(A))
    if (noreplace) {
        for (i=N(); i; i--) {
            if (alpha[i]<.) A[i] = alpha[i]
        }
    }
    alpha = A
}

`T' `MAIN'::intensity(| `RV' I0, `RS' noreplace)
{
    `Int' i
    `RC'  I

    if (args()==0) return(intensity)
    if (args()<2) noreplace = `FALSE'
    if (length(I0)==0) return
    if (any( ((I0:<.):&(I0:>255)) :| (I0:<0) )) {
        display("{err}intensity multiplier must be in [0,255]")
        exit(3300)
    }
    if (cols(I0)>1) I = I0'
    else            I = I0
    if      (rows(I)<N()) I = colrecycle(I, N())
    else if (rows(I)>N()) recycle(rows(I))
    if (noreplace) {
        for (i=N(); i; i--) {
            if (intensity[i]<.) I[i] = intensity[i]
        }
    }
    intensity = I
}

end

* {smcl}
* {marker ipolate}{bf:Color interpolation and mixing} {hline}
* {asis}

mata:

void `MAIN'::ipolate(`Int' n, | `SS' space0, `RV' range, `RS' power, `RV' pos, 
    `Bool' pad)
{
    `Int'  jh
    `SS'   space, mask
    `RC'   A, I
    `RM'   C

    if (args()<6) pad = `FALSE'
    // skip interpolation if n is missing
    if (n>=.) return
    // parse space
    space = findkey(gettok(space0, mask=""), SPACES, "Jab")
    if (space=="") {
        display("{err}space '" + space0 + "' not allowed")
        exit(3498)
    }
    // convert RGB1 to interpolation space
    C = ipolate_get(space, mask, jh=0)
    if (mask!="") space = space + " " + mask
    // get opacity and intensity
    if (any(alpha:<.))     A = editmissing(alpha, 1)
    else                   A = J(N(), 0, .)
    if (any(intensity:<.)) I = editmissing(intensity, 1)
    else                   I = J(N(), 0, .)
    // interpolate
    C = colipolate((C,A,I), n, range, power, pos, pad)
    if (length(I)) {; I = C[,cols(C)]; C = C[|1,1 \ n,cols(C)-1|]; }
    if (length(A)) {; A = C[,cols(C)]; C = C[|1,1 \ n,cols(C)-1|]; }
    // convert back to RGB1
    if (jh) C[,jh] = mod(C[,jh] :+ .5, 360) :- .5
    set(C, space)
    isip = `TRUE'
    // reset opacity and intensity if necessary
    if (length(A)) {
        if (pad) alpha = clip(A, 0, 1)
        else     alpha = A
    }
    if (length(I)) {
        if (pad) intensity = clip(I, 0, 255)
        else     intensity = I
    }
}

`RM' `MAIN'::ipolate_get(`SS' space, `SS' mask, `Int' j)
{
    `RM'   C
    
    C = get(space + (mask!="" ? " " + mask : ""))
    if (space=="CAM02") {
        if (mask=="") j = 3 // default mask is JCh
        else          j = strpos(mask, "h")
    }
    else j = strpos(strlower(space), "h")
    if (j) C[,j] = _ipolate_halign(C[,j])
    return(C)
}

`RC' `MAIN'::_ipolate_halign(`RC' C)
{
    `Int' i, j
    `RS'  a, b, c

    for(i=(rows(C)-1); i; i--) {
        c = C[i+1]
        if (c>=.) continue
        j = trunc(c/360)
        b = mod(C[i], 360)
        if (b<mod(C[i+1], 360)) {
            a = j*360 + b
            b = (j+1)*360 + b
        }
        else {
            a = (j-1)*360 + b
            b = j*360 + b
        }
        if (abs(a-c)<=abs(b-c)) C[i] = a
        else                    C[i] = b
    }
    return(C)
}

`RM' `MAIN'::colipolate(`RM' C, `Int' n, | `RV' range0, `RS' power, `RV' pos, 
    `Bool' pad)
{
    `Bool' haspos
    `Int'  r
    `RV'   range
    `RC'   from, to
    
    if (args()<6) pad = `FALSE'
    if (power<=0) {
        printf("{err}power = %g not allowed; must be strictly positive\n", power)
        exit(3498)
    }
    haspos = length(pos)>0 & any(pos:<.)
    if (n>=.) return(C)                           // return unchanged C
    if (n<1)  return(J(0, cols(C), missingof(C))) // return void
    r = rows(C)
    if (r==0) return(J(n, cols(C), missingof(C))) // return missing
    if (r==1) return(J(n, 1, C))                  // duplicate
    range = _ipolate_setrange(range0)
    if (r==n) {
        if (range==(0,1) & haspos==`FALSE') return(C) // no interpolation needed
        if (range==(1,0) & haspos==`FALSE') return(C[r::1,]) // reverse order
    }
    _ipolate_fromto(r, n, range, power, (haspos ? pos : .), pad, from=., to=.)
    if (haspos) return(_ipolate_pos(C, from, to))
    return(_ipolate(C, from, to))
}

`RV' `MAIN'::_ipolate_setrange(`RV' range0)
{
    `RV' range
    
    if      (length(range0)==0)   range = (0,1)
    else if (length(range0)==1)   range = (range0, 1)
    else                          range = (range0[1], range0[2])
    if (range[1]>=.) range[1] = 0
    if (range[2]>=.) range[1] = 1
    return(range)
}

void `MAIN'::_ipolate_fromto(`Int' r, `Int' n, `RV' range, `RS' power, 
    `RV' pos, `Bool' pad, `RC' from, `RC' to)
{
    `RS' i
    
    // from
    from = rangen(0, 1, r)
    if (pos!=.) {
        // import values from pos
        for (i=length(pos); i; i--) {
            if (i>r) continue
            if (pos[i]<.) from[i] = pos[i]
        }
    }
    if (pad) from = from * ((r-1)/r) :+ (1/(2*r))
    // to
    if (pad) range = range * ((n-1)/n) :+ (1/(2*n))
    if (n==1)      to = (range[1]+range[2])/2
    else if (n==2) to = (range[1], range[2])'
    else {
        to = rangen(0, 1, n)
        if (power<.) to = to:^power
        to = to * (range[2]-range[1]) :+ range[1]
    }
}

`RM' `MAIN'::_ipolate_pos(`RM' C0, `RC' from0, `RC' to) 
{   // note: function will only be called if length(from0)>=2
    `RC'  p, a, b, from
    `RM'  C

    a = from0[|1 \ rows(from0)-1|]; b = from0[|2 \ rows(from0)|]
    if (all(a:<b)) return(_ipolate(C0, from0, to)) // strictly ascending
    if (all(a:>b)) return(_ipolate(C0, from0, to)) // strictly descending
    p = ::order(from0, 1)
    from = from0[p]; C = C0[p,]
    a = from[|1 \ rows(from)-1|]; b = from[|2 \ rows(from)|]
    if (any(a:==b)==0) return(_ipolate(C, from, to)) // no doubles
    _ipolate_collapse(C, from)
    if (rows(C)==1) return(J(rows(to), 1, C))
    return(_ipolate(C, from, to))
}

void `MAIN'::_ipolate_collapse(`RM' C, `RC' from)
{
    `Int' i, j, a, b
    
    i = j = b = rows(from)
    for (--i; i; i--) {
        if (from[i]!=from[b]) {
            from[j] = from[b]
            a = i+1
            if (a==b) C[j,] = C[b,]
            else      C[j,] = mean(C[|a,1 \ b,.|])
            j--; b = i
        }
    }
    from[j] = from[b]
    if (b==1) C[j,] = C[b,]
    else      C[j,] = mean(C[|1,1 \ b,.|])
    C = C[|j,1 \ .,.|]; from = from[|j \ .|]
}

`RM' `MAIN'::_ipolate(`RM' y0, `RC' x0, `RC' x1)
{
    `Int' i, j, k, l, n0, n1, c, reverse
    `RM'  y1
    
    n0 = rows(y0); c = cols(y0); n1 = rows(x1); reverse = 0
    if (x1[1]>x1[n1]) {
        reverse = 1
        x1 = x1[n1::1]
    }
    y1 = J(n1, c, .)
    i = 1
    for (j=1; j<=n1; j++) {
        while (x0[i]<x1[j]) {
            i++
            if (i>=n0) {
                i = n0
                break
            }
        }
        l = (i==1 ? 2 : i)
        for (k=c; k; k--) y1[j,k] = y0[l-1,k] + 
            (y0[l,k] - y0[l-1,k]) * (x1[j] - x0[l-1])/(x0[l] - x0[l-1])
    }
    if (reverse) {
        x1 = x1[n1::1]
        return(y1[n1::1,])
    }
    return(y1)
}

void `MAIN'::mix(| `SS' space0, `RV' w0)
{
    `Int'  jh
    `SS'   space, mask
    `RC'   w, A, I
    `RM'   C

    // parse space
    space = findkey(gettok(space0, mask=""), SPACES, "Jab")
    if (space=="") {
        display("{err}space '" + space0 + "' not allowed")
        exit(3498)
    }
    // convert RGB1 to interpolation space
    C = mix_get(space, mask, jh=0)
    if (mask!="") space = space + " " + mask
    // weights
    if (length(w0)==0) w = 1
    else if (w0==.)    w = 1
    else {
        if (cols(w0)>1) w = w0'
        else            w = w0
        if      (rows(w)<N()) w = colrecycle(w, N())
        else if (rows(w)>N()) w = w[|1 \ N()|]
    }
    // get opacity and intensity
    if (any(alpha:<.))     A = editmissing(alpha, 1)
    else                   A = J(N(), 0, .)
    if (any(intensity:<.)) I = editmissing(intensity, 1)
    else                   I = J(N(), 0, .)
    // average
    C = mean((C,A,I), w)
    if (length(I)) {; I = C[cols(C)]; C = C[|1 \ cols(C)-1|]; }
    if (length(A)) {; A = C[cols(C)]; C = C[|1 \ cols(C)-1|]; }
    // convert back to RGB1
    if (jh) {
        C[jh] = mod(atan2(C[jh], C[cols(C)])*180/pi() + .5, 360) - .5
        C = C[|1 \ cols(C)-1|]
    }
    set(C, space)
    // reset opacity if necessary
    if (length(A)) alpha     = A
    if (length(I)) intensity = I
}

`RM' `MAIN'::mix_get(`SS' space, `SS' mask, `Int' j)
{
    `RM'   C
    
    C = get(space + (mask!="" ? " " + mask : ""))
    if (space=="CAM02") {
        if (mask=="") j = 3 // default mask is JCh
        else          j = strpos(mask, "h")
    }
    else j = strpos(strlower(space), "h")
    if (j) {
        C[,j] = C[,j] * (pi() / 180)
        C     = C, sin(C[,j])
        C[,j] = cos(C[,j])
    }
    return(C)
}


end

* {smcl}
* {marker order}{bf:Recycle, select, and order} {hline}
* {asis}

mata:

void `MAIN'::recycle(`Int' n0)
{
    `Int' n
    
    n = n0
    if (n>=. | n<0) return
    if (n==N())     return
    RGB       = colrecycle(RGB, n)
    alpha     = colrecycle(alpha, n)
    intensity = colrecycle(intensity, n)
    info      = colrecycle(info, n)
    stok      = colrecycle(stok, n)
}

`TM' `MAIN'::colrecycle(`TM' M0, `Int' n)
{
    `Int' i, r
    `TM'  M
    
    if (n==0) return(J(0, cols(M0), missingof(M0)))
    r = rows(M0)
    if (r==0 | n==r) return(M0)
    if (n<r) return(M0[|1,1 \ n,cols(M0)|])
    M = M0 \ J(n-r, cols(M0), missingof(M0))
    for (i=(r+1); i<=n; i++) M[i,] = M[mod(i-1, r) + 1,]
    return(M)
}

void `MAIN'::select(`IntV' p0)
{
    `IntC' p
    
    p = p0
    if (cols(p)!=1) _transpose(p)
    p = (sign(p):!=-1):*p :+ (sign(p):==-1):*(N():+1:+p)
    p = ::select(p, p:>=1 :& p:<=N())
    _select(p)
}

void `MAIN'::order(`IntV' p0)
{
    `IntC' p, rest
    
    p = p0
    if (cols(p)!=1) _transpose(p)
    p = (sign(p):!=-1):*p :+ (sign(p):==-1):*(N():+1:+p)
    p = ::select(p, p:>=1 :& p:<=N())
    if (length(p)==0) return
    rest = 1::N()
    rest[p] = J(length(p), 1, .)
    rest = ::select(rest, rest:<.)
    if (length(rest)) p = p \ rest
    _select(p)
}

void `MAIN'::reverse()
{
    if (N()<=1) return
    _select(N()::1)
}

void `MAIN'::_select(`IntM' p)
{
    if (length(p)==0) {
        rgb_set(J(0, 3, .))
        return
    }
    RGB       = RGB[p,]
    alpha     = alpha[p]
    intensity = intensity[p]
    info      = info[p,]
    stok      = stok[p]
}

end

* {smcl}
* {marker intens}{bf:Intensify, saturate, luminate} {hline}
* {asis}

mata:

// Change color intensity
// equivalent to intensity adjustment as implemented in official Stata
// (increase/decrease R, G, and B such that their ratio is maintained)
// 0 <= p < 1 makes color lighter
// 1 <  p <= 255 makes color darker
// output is always within [0,255] and rounded

void `MAIN'::intensify(`RV' p0)
{
    `Int'   i
    `IntC'  id
    `RC'    p
    `RM'    C
    
    if (length(p0)==0) return
    if (any( ((p0:<.):&(p0:>255)) :| (p0:<0) )) {
        display("{err}intensity multiplier must be in [0,255]")
        exit(3300)
    }
    if (cols(p0)>1) p = p0'
    else            p = p0
    if      (rows(p)<N()) p = colrecycle(p, N())
    else if (rows(p)>N()) recycle(rows(p))
    C = get("RGB")
    if (missing(p)) {
        id = ::select(1::N(), p:<.)
        if (length(id)==0) return
        C = C[id,]; p = p[id]
    }
    for (i=rows(C); i; i--) C[i,] = _intensify(C[i,], p[i])
    reset(C, "RGB", id)
}

`RR' `MAIN'::_intensify(`RR' C0, `RS' p)
{   // C0 is assumed to be rounded and clipped to [0,255]
    `RS' m
    `RR' C

    if (p==1) return(C0)
    m = (p<0 ? 0 : (p>255 ? 255 : p))
    if (m<1) return(round(C0*m :+ (255*(1-m))))
    m = 1/m
    C = round(C0*m)
    if (any(C0 :& C:==0)) C = round(C0 / min(::select((255,C0), (255,C0):>0)))
    return(C)
}

// Change saturation/chroma
// similar to color.saturate()/color.desaturate() in chroma.js
// source: https://gka.github.io/chroma.js/

void `MAIN'::saturate(`RV' p0, | `SS' method0, `Bool' level)
{
    `Int'  i
    `IntC' id
    `RC'   p
    `SS'   method
    `RM'   C
    
    if (args()<3) level = `FALSE'
    method = findkey(strlower(method0), ("LCh", "HCL", "JCh", "JMh")', "LCh")
    if (method=="") {
        display("{err}method '" + method0 + "' not allowed")
        exit(3498)
    }
    if (method=="JCh") method = "CAM02 JCh"
    if (length(p0)==0) return
    if (cols(p0)>1) p = p0'
    else            p = p0
    if      (rows(p)<N()) p = colrecycle(p, N())
    else if (rows(p)>N()) recycle(rows(p))
    C = get(method)
    if (missing(p)) {
        id = ::select(1::N(), p:<.)
        if (length(id)==0) return
        C = C[id,]; p = p[id]
    }
    for (i=rows(C); i; i--) {
        if (p[i]>=.) continue
        if (level) C[i,2] = max((p[i],0))
        else       C[i,2] = max((C[i,2] + p[i], 0))
    }
    reset(C, method, id)
}

// Change luminance/brightness
// similar to color.brighten()/color.darken() in chroma.js
// source: https://gka.github.io/chroma.js/

void `MAIN'::luminate(`RV' p0, | `SS' method0, `Bool' level)
{
    `Int'  i, j
    `IntC' id
    `RC'   p
    `SS'   method
    `RM'   C
    
    if (args()<3) level = `FALSE'
    method = findkey(strlower(method0), ("Lab", "LCh", "Luv", "HCL", 
        "JCh", "JMh", "Jab")', "JMh")
    if (method=="") {
        display("{err}method '" + method0 + "' not allowed")
        exit(3498)
    }
    if (method=="JCh") method = "CAM02 JCh"
    if (length(p0)==0) return
    if (cols(p0)>1) p = p0'
    else            p = p0
    if      (rows(p)<N()) p = colrecycle(p, N())
    else if (rows(p)>N()) recycle(rows(p))
    C = get(method)
    if (missing(p)) {
        id = ::select(1::N(), p:<.)
        if (length(id)==0) return
        C = C[id,]; p = p[id]
    }
    if (method=="HCL") j = 3
    else               j = 1
    for (i=rows(C); i; i--) {
        if (p[i]>=.) continue
        if (level) C[i,j] = max((p[i],0))
        else       C[i,j] = max((C[i,j] + p[i], 0))
    }
    reset(C, method, id)
}

end

* {smcl}
* {marker gray}{bf:Gray scale conversion} {hline}
* reduce luminance towards zero
* {asis}

mata:

void `MAIN'::gray(| `RS' p, `SS' method)
{
    `Int' i
    
    RGB = GRAY(RGB, "RGB1", p, method)
    stok = J(N(), 1, `FALSE')
    for (i=N(); i; i--) {
        if (info[i,1]!="") info[i,1] = info[i,1] + " (gs)"
        if (info[i,2]!="") info[i,2] = info[i,2] + " (gs)"
    }
}

`RM' `MAIN'::GRAY(`RM' C, `SS' space, `RS' p0, `SS' method0)
{
    `RS' p
    `SS' method
    `RM' G
    
    p = (p0<. ? p0 : 1)
    if (p<0 | p>1) {
        display("{err}proportion must be within 0 and 1")
        exit(3300)
    }
    // https://en.wikipedia.org/wiki/Grayscale: set all RGB channels to Y of XYZ
    // (and apply gamma) => equivalent to method "HCL" or "LCh" if p = 1
    method = findkey(strlower(method0), ("LCh", "HCL", "JCh", "JMh")', "LCh")
    if (method=="") {
        display("{err}method '" + method0 + "' not allowed")
        exit(3498)
    }
    if (method=="JCh") method = "CAM02 JCh"
    G = convert(C, space, method)
    if (p<. & p!=1) G[,2] = G[,2] * (1-p)
    else            G[,2] = J(rows(G), 1, 0)
    return(convert(G, method, space))
}

end

* {smcl}
* {marker cvd}{bf:Color vision deficiency simulation} {hline}
* Source:
*   Machado, G.M., M.M. Oliveira, L.A.F. Fernandes (2009). A
*   Physiologically-based Model for Simulation of Color Vision Deficiency. IEEE
*   Transactions on Visualization and Computer Graphics 15(6): 1291-1298. 
*   {browse "https://doi.org/10.1109/TVCG.2009.113"}
* Transformation matrices:
*   {browse "http://www.inf.ufrgs.br/~oliveira/pubs_files/CVD_Simulation/CVD_Simulation.html"}
* {asis}

mata:

void `MAIN'::cvd(| `RS' p, `SS' method)
{
    `Int' i

    RGB = CVD(RGB, "RGB1", p, method)
    stok = J(N(), 1, `FALSE')
    for (i=N(); i; i--) {
        if (info[i,1]!="") info[i,1] = info[i,1] + " (cvd)"
        if (info[i,2]!="") info[i,2] = info[i,2] + " (cvd)"
    }
}

`RM' `MAIN'::CVD(`RM' C, `SS' space, | `RS' p, `SS' method)
{
    `Int' i
    `RM'  M, CVD
    
    M = cvd_M(p, method)'
    CVD = convert(C, space, "lRGB")
    for (i=rows(CVD); i; i--) CVD[i,] = CVD[i,] * M
    return(convert(CVD, "lRGB", space))
}

`RM' `MAIN'::cvd_M(| `RS' p0, `SS' method0)
{
    `Int' a, b, i
    `RS'  f, p
    `SS'  method
    
    p = (p0<. ? p0 : 1)
    if (p<0 | p>1) {
        display("{err}severity must be within 0 and 1")
        exit(3300)
    }
    method = strlower(method0)
    if      (smatch(method, "deuteranomaly"))  i = 1 // includes ""
    else if (smatch(method, "protanomaly"))    i = 2
    else if (smatch(method, "tritanomaly"))    i = 3
    else {
        display("{err}type '" + method0 + "' not allowed")
        exit(3498)
    }
    f = p/.1
    a = floor(f); b = ceil(f)
    if (a==b) {
        if (i==1) return(cvd_M_d(a))
        if (i==2) return(cvd_M_p(a))
        if (i==3) return(cvd_M_t(a))
    }
    f = f-a
    if (i==1) return( (1-f)*cvd_M_d(a) :+ f*cvd_M_d(b) )
    if (i==2) return( (1-f)*cvd_M_p(a) :+ f*cvd_M_p(b) )
    if (i==3) return( (1-f)*cvd_M_t(a) :+ f*cvd_M_t(b) )
}

`RM' `MAIN'::cvd_M_d(`Int' i)
{
    if (i==0)  return(( 1.000000,  0.000000, -0.000000) \
                      ( 0.000000,  1.000000,  0.000000) \
                      (-0.000000, -0.000000,  1.000000) )
    if (i==1)  return(( 0.866435,  0.177704, -0.044139) \
                      ( 0.049567,  0.939063,  0.011370) \
                      (-0.003453,  0.007233,  0.996220) )
    if (i==2)  return(( 0.760729,  0.319078, -0.079807) \
                      ( 0.090568,  0.889315,  0.020117) \
                      (-0.006027,  0.013325,  0.992702) )
    if (i==3)  return(( 0.675425,  0.433850, -0.109275) \
                      ( 0.125303,  0.847755,  0.026942) \
                      (-0.007950,  0.018572,  0.989378) )
    if (i==4)  return(( 0.605511,  0.528560, -0.134071) \
                      ( 0.155318,  0.812366,  0.032316) \
                      (-0.009376,  0.023176,  0.986200) )
    if (i==5)  return(( 0.547494,  0.607765, -0.155259) \
                      ( 0.181692,  0.781742,  0.036566) \
                      (-0.010410,  0.027275,  0.983136) )
    if (i==6)  return(( 0.498864,  0.674741, -0.173604) \
                      ( 0.205199,  0.754872,  0.039929) \
                      (-0.011131,  0.030969,  0.980162) )
    if (i==7)  return(( 0.457771,  0.731899, -0.189670) \
                      ( 0.226409,  0.731012,  0.042579) \
                      (-0.011595,  0.034333,  0.977261) )
    if (i==8)  return(( 0.422823,  0.781057, -0.203881) \
                      ( 0.245752,  0.709602,  0.044646) \
                      (-0.011843,  0.037423,  0.974421) )
    if (i==9)  return(( 0.392952,  0.823610, -0.216562) \
                      ( 0.263559,  0.690210,  0.046232) \
                      (-0.011910,  0.040281,  0.971630) )
    if (i==10) return(( 0.367322,  0.860646, -0.227968) \
                      ( 0.280085,  0.672501,  0.047413) \
                      (-0.011820,  0.042940,  0.968881) )
}

`RM' `MAIN'::cvd_M_p(`Int' i)
{
    if (i==0)  return(( 1.000000,  0.000000, -0.000000) \
                      ( 0.000000,  1.000000,  0.000000) \
                      (-0.000000, -0.000000,  1.000000) )
    if (i==1)  return(( 0.856167,  0.182038, -0.038205) \
                      ( 0.029342,  0.955115,  0.015544) \
                      (-0.002880, -0.001563,  1.004443) )
    if (i==2)  return(( 0.734766,  0.334872, -0.069637) \
                      ( 0.051840,  0.919198,  0.028963) \
                      (-0.004928, -0.004209,  1.009137) )
    if (i==3)  return(( 0.630323,  0.465641, -0.095964) \
                      ( 0.069181,  0.890046,  0.040773) \
                      (-0.006308, -0.007724,  1.014032) )
    if (i==4)  return(( 0.539009,  0.579343, -0.118352) \
                      ( 0.082546,  0.866121,  0.051332) \
                      (-0.007136, -0.011959,  1.019095) )
    if (i==5)  return(( 0.458064,  0.679578, -0.137642) \
                      ( 0.092785,  0.846313,  0.060902) \
                      (-0.007494, -0.016807,  1.024301) )
    if (i==6)  return(( 0.385450,  0.769005, -0.154455) \
                      ( 0.100526,  0.829802,  0.069673) \
                      (-0.007442, -0.022190,  1.029632) )
    if (i==7)  return(( 0.319627,  0.849633, -0.169261) \
                      ( 0.106241,  0.815969,  0.077790) \
                      (-0.007025, -0.028051,  1.035076) )
    if (i==8)  return(( 0.259411,  0.923008, -0.182420) \
                      ( 0.110296,  0.804340,  0.085364) \
                      (-0.006276, -0.034346,  1.040622) )
    if (i==9)  return(( 0.203876,  0.990338, -0.194214) \
                      ( 0.112975,  0.794542,  0.092483) \
                      (-0.005222, -0.041043,  1.046265) )
    if (i==10) return(( 0.152286,  1.052583, -0.204868) \
                      ( 0.114503,  0.786281,  0.099216) \
                      (-0.003882, -0.048116,  1.051998) )
}

`RM' `MAIN'::cvd_M_t(`Int' i)
{
    if (i==0)  return(( 1.000000,  0.000000, -0.000000) \
                      ( 0.000000,  1.000000,  0.000000) \
                      (-0.000000, -0.000000,  1.000000) )
    if (i==1)  return(( 0.926670,  0.092514, -0.019184) \
                      ( 0.021191,  0.964503,  0.014306) \
                      ( 0.008437,  0.054813,  0.936750) )
    if (i==2)  return(( 0.895720,  0.133330, -0.029050) \
                      ( 0.029997,  0.945400,  0.024603) \
                      ( 0.013027,  0.104707,  0.882266) )
    if (i==3)  return(( 0.905871,  0.127791, -0.033662) \
                      ( 0.026856,  0.941251,  0.031893) \
                      ( 0.013410,  0.148296,  0.838294) )
    if (i==4)  return(( 0.948035,  0.089490, -0.037526) \
                      ( 0.014364,  0.946792,  0.038844) \
                      ( 0.010853,  0.193991,  0.795156) )
    if (i==5)  return(( 1.017277,  0.027029, -0.044306) \
                      (-0.006113,  0.958479,  0.047634) \
                      ( 0.006379,  0.248708,  0.744913) )
    if (i==6)  return(( 1.104996, -0.046633, -0.058363) \
                      (-0.032137,  0.971635,  0.060503) \
                      ( 0.001336,  0.317922,  0.680742) )
    if (i==7)  return(( 1.193214, -0.109812, -0.083402) \
                      (-0.058496,  0.979410,  0.079086) \
                      (-0.002346,  0.403492,  0.598854) )
    if (i==8)  return(( 1.257728, -0.139648, -0.118081) \
                      (-0.078003,  0.975409,  0.102594) \
                      (-0.003316,  0.501214,  0.502102) )
    if (i==9)  return(( 1.278864, -0.125333, -0.153531) \
                      (-0.084748,  0.957674,  0.127074) \
                      (-0.000989,  0.601151,  0.399838) )
    if (i==10) return(( 1.255528, -0.076749, -0.178779) \
                      (-0.078411,  0.930809,  0.147602) \
                      ( 0.004733,  0.691367,  0.303900) )
}

end

* {smcl}
* {marker diff}{bf:Color differences and contrast ratios} {hline}
* {asis}

mata:

// Contrast Ratio according to Web Content Accessibility Guidelines (WCAG) 2.0 
// source https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef

`RC' `MAIN'::contrast(| `IntM' P0)
{
    `Int'  i, n, p1, p2
    `RS'   l1, l2
    `IntM' P
    `RC'   L, C
    
    if ((n = N())<1) return(J(0,1,.))
    if (args()<1 | P0==.) {
        if (n<2) return(J(0,1,.))
        P = ((1::(n-1)), (2::n))
    }
    else P = P0
    assert_cols(P, 2)
    L = get("XYZ")[,2] :+ 5
    C = J(i = rows(P), 1, .)
    for (; i; i--) {
        p1 = P[i,1]; p2 = P[i,2]
        if (p1<0) p1 = n + 1 + p1
        if (p2<0) p2 = n + 1 + p2
        if (p1<1 | p1>n) continue
        if (p2<1 | p2>n) continue
        l1 = L[p1]; l2 = L[p2]
        C[i] = (l1>l2 ? l1/l2 : l2/l1)
    }
    return(C)
}

// Color differences
// sources:
// - https://en.wikipedia.org/wiki/Color_difference
// - Luo, M.R., C. Li (2013). CIECAM02 and its recent developments. P 19-58 in: 
//   C. Fernandez-Maloigne (ed). Advanced color image processing and analysis. 
//   New York: Springer. https://doi.org/10.1007/978-1-4419-6190-7_2

`RC' `MAIN'::delta(| `IntM' P0, `SS' method0, `Bool' noclip)
{
    `SS'   method, coefs, space
    `Int'  n
    `IntM' P
    `RM'   C
    pragma unset coefs

    if (args()<3) noclip = `FALSE'
    // parse method 
    method = findkey(gettok(method0, coefs), ("E76", "RGB", "RGB1", "lRGB", 
        "XYZ", "XYZ1", "xyY1", "Lab", "LCh", "Luv", "HCL", "JCh", "JMh",
        "Jab")', ("Jab"))
    if (method=="") {
        display("{err}method '" + method0 + "' not allowed")
        exit(3498)
    }
    if      (method=="Jab") space = "Jab" + (coefs!="" ? " " + coefs : "")
    else if (method=="JMh") space = "JMh" + (coefs!="" ? " " + coefs : "")
    else if (method=="JCh") space = "CAM02 JCh"
    else if (coefs!="") {
        display("{err}method '" + method0 + "' not allowed")
        exit(3498)
    }
    else {
        if (method=="E76") space = "Lab"
        else               space = method
    }
    // determine positions
    if ((n = N())<1) return(J(0,1,.))
    if (args()<1 | P0==.) {
        if (n<2) return(J(0,1,.))
        P = ((1::(n-1)), (2::n))
    }
    else P = P0
    assert_cols(P, 2)
    // get colors
    if (noclip==`TRUE') C = get(space)
    else                C = convert(clip(get("lRGB"), 0, 1), "lRGB", space)
    // compute differences
    if (method=="Jab") return(delta_jab(C, P, coefs))
    return(delta_euclid(C, P))
}

`RC' `MAIN'::delta_jab(`RM' C, `IntM' P, `SS' coefs)
{
    `Int'  i, n, p1, p2
    `RS'   KL
    `RR'   a, b
    `RC'   D
    
    if (coefs=="") KL = ucscoefs()[1]
    else           KL = ucscoefs_get(coefs)[1]
    n = N()
    D = J(i = rows(P), 1, .)
    for (; i; i--) {
        p1 = P[i,1]; p2 = P[i,2]
        if (p1<0) p1 = n + 1 + p1
        if (p2<0) p2 = n + 1 + p2
        if (p1<1 | p1>n) continue
        if (p2<1 | p2>n) continue
        a = C[p1,]; b = C[p2,]
        D[i] = sqrt(((a[1]-b[1])/KL):^2 + (a[2]-b[2]):^2 + (a[3]-b[3]):^2)
    }
    return(D)
}

`RC' `MAIN'::delta_euclid(`RM' C, `IntM' P)
{
    `Int'  i, n, p1, p2
    `RR'   a, b
    `RC'   D
    
    n = N()
    D = J(i = rows(P), 1, .)
    for (; i; i--) {
        p1 = P[i,1]; p2 = P[i,2]
        if (p1<0) p1 = n + 1 + p1
        if (p2<0) p2 = n + 1 + p2
        if (p1<1 | p1>n) continue
        if (p2<1 | p2>n) continue
        a = C[p1,]; b = C[p2,]
        D[i] = sqrt(((a[1]-b[1])):^2 + (a[2]-b[2]):^2 + (a[3]-b[3]):^2)
    }
    return(D)
}

end

* {smcl}
* {marker convert}{bf:Translation between color spaces (without storing colors)} {hline}
* {asis}

mata:

`TM' `MAIN'::convert(`TM' C0, `SS' from, | `SS' to,  `RS' p, `SS' method)
{
    `SR' FROM, TO
    `SM' PATH
    `TM' C
    pragma unset FROM
    pragma unset TO

    if (convert_parse(TO, to, 1)) {
        display("{err}'" + to + "' not allowed")
        exit(3498)
    }
    if (TO[1]=="GRAY") return(GRAY(C0, from, p, method))
    if (TO[1]=="CVD")  return(CVD(C0, from, p, method))
    if (convert_parse(FROM, from, 0)) {
        display("{err}'" + from + "' not allowed")
        exit(3498)
    }
    if (FROM[1]==TO[1]) {
        if (FROM[1]=="CAM02") {
            if (FROM==TO) return(C0)
            CAM02_setup()
            return(CAM02_to_CAM02(C0, FROM[2], TO[2]))
        }
        if (FROM[1]=="JMh") {
            if (FROM==TO) return(C0)
            return(CAM02_to_JMh(JMh_to_CAM02(C0, FROM[2], "JMh"), "JMh", TO[2]))
        }
        if (FROM[1]=="Jab") {
            if (FROM==TO) return(C0)
            return(CAM02_to_Jab(Jab_to_CAM02(C0, FROM[2], "JMh"), "JMh", TO[2]))
        }
        return(C0)
    }
    PATH = convert_getpath(TO, FROM)
    C = C0
    return(convert_run(C, PATH))
}

`Bool' `MAIN'::convert_parse(`SR' S, `SS' s0, `RS' to)
{
    `SS' s, mask
    pragma unset mask
    
    s = findkey(gettok(s0, mask), SPACES \ SPACES2, "RGB")
    if (s=="") {
        if (to) s = findkey(gettok(s0), ("GRAY", "CVD")')
        if (s=="") return(`TRUE')
    }
    if (mask!="") {
        if (anyof(("CAM02", "JMh", "Jab"), s)==0) return(`TRUE')
    }
    S = (s, mask)
    return(`FALSE')
}

`SM' `MAIN'::convert_getpath(`SR' TO, `SM' path0)
{
    `Int' i
    `SR'  path
    `SM'  edgelist

    i = rows(path0)
    edgelist = ::select(EDGELIST, EDGELIST[,1]:==path0[i,1])
    if (i>1) edgelist = ::select(edgelist, edgelist[,2]:!=path0[i-1,1])
    for (i=rows(edgelist); i; i--) {
        if (edgelist[i,2]==TO[1]) return(path0 \ TO)
        path = convert_getpath(TO, path0 \ (edgelist[i,2], ""))
        if (rows(path)) return(path)
    }
    return(J(0,2,""))
}

`TM' `MAIN'::convert_run(`TM' C, `SM' PATH)
{
    `SS' from, to, err
    
    err = "inconsistent conversion path; this should never happen"
    from = PATH[1,1]; to = PATH[2,1]
    if      (from=="HEX") {
        if      (to=="RGB")     C = HEX_to_RGB(C)
        else                    _error(err)
    }
    else if (from=="RGB") {
        if      (to=="HEX")     C = RGB_to_HEX(C)
        else if (to=="RGB1")    C = RGB_to_RGB1(C)
        else                    _error(err)
    }
    else if (from=="CMYK") {
        if      (to=="CMYK1")   C = CMYK_to_CMYK1(C)
        else                    _error(err)
    }      
    else if (from=="CMYK1") {
        if      (to=="CMYK")    C = CMYK1_to_CMYK(C)
        else if (to=="RGB1")    C = CMYK1_to_RGB1(C)
        else                    _error(err)
    }
    else if (from=="HSV") {
        if      (to=="RGB1")    C = HSV_to_RGB1(C)
        else                    _error(err)
    }
    else if (from=="HSL") {
        if      (to=="RGB1")    C = HSL_to_RGB1(C)
        else                    _error(err)
    }
    else if (from=="RGB1") {
        if      (to=="RGB")     C = RGB1_to_RGB(C)
        else if (to=="CMYK1")   C = RGB1_to_CMYK1(C)
        else if (to=="HSV")     C = RGB1_to_HSV(C)
        else if (to=="HSL")     C = RGB1_to_HSL(C)
        else if (to=="lRGB")    C = RGB1_to_lRGB(C)
        else                    _error(err)
    }
    else if (from=="lRGB") {
        if      (to=="RGB1")    C = lRGB_to_RGB1(C)
        else if (to=="XYZ")     C = lRGB_to_XYZ(C)
        else                    _error(err)
    }
    else if (from=="XYZ") {
        if      (to=="lRGB")    C = XYZ_to_lRGB(C)
        else if (to=="XYZ1")    C = XYZ_to_XYZ1(C)
        else if (to=="xyY")     C = XYZ_to_xyY(C)
        else if (to=="Lab")     C = XYZ_to_Lab(C)
        else if (to=="Luv")     C = XYZ_to_Luv(C)
        else if (to=="CAM02")   C = XYZ_to_CAM02(C, PATH[2,2])
        else                    _error(err)
    }
    else if (from=="XYZ1") {
        if      (to=="XYZ")     C = XYZ1_to_XYZ(C)
        else                    _error(err)
    }
    else if (from=="xyY") {
        if      (to=="XYZ")     C = xyY_to_XYZ(C)
        else if (to=="xyY1")    C = xyY_to_xyY1(C)
        else                    _error(err)
    }
    else if (from=="xyY1") {
        if      (to=="xyY")     C = xyY1_to_xyY(C)
        else                    _error(err)
    }
    else if (from=="Lab") {
        if      (to=="XYZ")     C = Lab_to_XYZ(C)
        else if (to=="LCh")     C = Lab_to_LCh(C)
        else                    _error(err)
    }
    else if (from=="LCh") {
        if      (to=="Lab")     C = LCh_to_Lab(C)
        else                    _error(err)
    }
    else if (from=="Luv") {
        if      (to=="XYZ")     C = Luv_to_XYZ(C)
        else if (to=="HCL")     C = Luv_to_HCL(C)
        else                    _error(err)
    }
    else if (from=="HCL") {
        if      (to=="Luv")     C = HCL_to_Luv(C)
        else                    _error(err)
    }
    else if (from=="CAM02") {
        if      (to=="XYZ")     C = CAM02_to_XYZ(C, PATH[1,2])
        else if (to=="JMh")     C = CAM02_to_JMh(C, PATH[1,2], PATH[2,2])
        else if (to=="Jab")     C = CAM02_to_Jab(C, PATH[1,2], PATH[2,2])
        else                    _error(err)
    }
    else if (from=="JMh") {
        if      (to=="CAM02")   C = JMh_to_CAM02(C, PATH[1,2], PATH[2,2])
        else                    _error(err)
    }
    else if (from=="Jab") {
        if      (to=="CAM02")   C = Jab_to_CAM02(C, PATH[1,2], PATH[2,2])
        else                    _error(err)
    }
    else                        _error(err)
    if (rows(PATH)==2) return(C)
    return(convert_run(C, PATH[|2,1 \ .,.|]))
}

end

* {smcl}
* {marker translate}{bf:Elementary translators} {hline}
* {asis}

mata:

// Transformation between HEX string and RGB {0,...,255} 

`RM' `MAIN'::HEX_to_RGB(`SV' HEX)
{
    `Int' i
    `RM'  RGB
    
    i = length(HEX)
    RGB = J(i, 3, .)
    for (; i; i--) RGB[i,] = _HEX_to_RGB(strtrim(HEX[i]))
    return(RGB)
}

`RR' `MAIN'::_HEX_to_RGB(`SS' HEX)
{
    `SS'  c
    `Int' l
    
    c = strtrim(substr(HEX,2,.)) // get rid of #; allows blanks after #
    l = strlen(c)
    if (l==3) c = substr(c,1,1)*2 + substr(c,2,1)*2 + substr(c,3,1)*2
    else if (l!=6) return(J(1,3,.))
    return((frombase(16, substr(c,1,2)), 
            frombase(16, substr(c,3,2)),
            frombase(16, substr(c,5,2))))
}

`SC' `MAIN'::RGB_to_HEX(`RM' RGB)
{
    `Int' i
    `SC'  HEX
    
    assert_cols(RGB, 3)
    i = rows(RGB)
    HEX = J(i, 1, "")
    for (; i; i--) HEX[i] = _RGB_to_HEX(RGB[i,])
    return(HEX)
}

`SS' `MAIN'::_RGB_to_HEX(`RV' RGB)
{
    `Int' i
    `SS'  HEX, s
    pragma unset HEX
    
    if (max(RGB)>255) return("")
    if (min(RGB)<0)   return("")
    for (i=3; i; i--) {
        s = inbase(16, RGB[i])
        if (strlen(s)==1) s = "0" + s
        //if (strlen(s)!=2) return("")
        HEX = s + HEX
    }
    return("#" + HEX)
}

// Transformation between CMYK [0,1] and CMYK {0,...,255}

`RM' `MAIN'::CMYK1_to_CMYK(`RM' CMYK1) return(clip(round(CMYK1*255), 0, 255))

`RM' `MAIN'::CMYK_to_CMYK1(`RM' CMYK) return(CMYK/255)

// Transformation between CMYK [0,1] and RGB [0,1]
// source: .setcmyk from color.class and rgb2cmyk in palette.ado (official Stata)

`RM' `MAIN'::RGB1_to_CMYK1(`RM' RGB1)
{
    `Int' i
    `RM'  CMYK1
    
    assert_cols(RGB1, 3)
    i = rows(RGB1)
    CMYK1 = J(i, 4, .)
    for (; i; i--) CMYK1[i,] = _RGB1_to_CMYK1(RGB1[i,])
    return(CMYK1)
}

`RR' `MAIN'::_RGB1_to_CMYK1(`RV' RGB1)
{
    `RS' c, m, y, k
    
    c = 1 - RGB1[1]; m = 1 - RGB1[2]; y = 1 - RGB1[3]
    k = min((c, m, y))
    return((c-k, m-k, y-k, k))
}

`RM' `MAIN'::CMYK1_to_RGB1(`RM' CMYK1)
{
    `Int' i
    `RM'  RGB1
    
    assert_cols(CMYK1, 4)
    i = rows(CMYK1)
    RGB1 = J(i, 3, .)
    for (; i; i--) RGB1[i,] = _CMYK1_to_RGB1(CMYK1[i,])
    return(RGB1)
}

`RR' `MAIN'::_CMYK1_to_RGB1(`RV' CMYK1)
{
    `RS' c, m, y, k
    
    c = CMYK1[1]; m = CMYK1[2]; y = CMYK1[3]; k = CMYK1[4]
    return((((c+k)<1 ? 1 - (c+k) : 0),
            ((m+k)<1 ? 1 - (m+k) : 0),
            ((y+k)<1 ? 1 - (y+k) : 0)))
}

// Transformation between RGB [0,1] and RGB {0,...,255}

`RM' `MAIN'::RGB_to_RGB1(`RM' RGB) return(RGB/255)

`RM' `MAIN'::RGB1_to_RGB(`RM' RGB1) return(clip(round(RGB1*255), 0, 255))

// Transformation between RGB [0,1] and linear RGB [0,1]
// sources:
// https://en.wikipedia.org/wiki/SRGB
// http://www.brucelindbloom.com/index.html?WorkingSpaceInfo.html
// http://www.babelcolor.com/index_htm_files/A%20review%20of%20RGB%20color%20spaces.pdf
// https://en.wikipedia.org/wiki/Gamma_correction

`RM' `MAIN'::RGB1_to_lRGB(`RM' RGB1)
{
    `Int' i, j, c
    `RS'  C, g, offset, transition, slope
    `RM'  lRGB
    
    if (length(rgb_gamma)==1) {
        if (rgb_gamma!=1) return(sign(RGB1) :* abs(RGB1):^rgb_gamma)
        return(RGB1)
    }
    i = rows(RGB1); c = cols(RGB1)
    lRGB = J(i, c, .)
    g          = rgb_gamma[1]
    offset     = rgb_gamma[2]
    transition = rgb_gamma[3]
    slope      = rgb_gamma[4]
    transition = transition * slope
    for (; i; i--) {
        for (j=c; j; j--) {
            C = RGB1[i,j]
            lRGB[i,j] = (abs(C)<=transition ? C/slope :
                sign(C) * ((abs(C) + offset)/(1 + offset))^g)
        }
    }
    return(lRGB)
}

`RM' `MAIN'::lRGB_to_RGB1(`RM' lRGB)
{
    `Int' i, j, c
    `RS'  C, g, offset, transition, slope
    `RM'  RGB1
    
    if (length(rgb_gamma)==1) {
        if (rgb_gamma!=1) return(sign(lRGB) :* abs(lRGB):^(1/rgb_gamma))
        return(lRGB)
    }
    i = rows(lRGB); c = cols(lRGB)
    RGB1 = J(i, c, .)
    g          = 1/rgb_gamma[1]
    offset     = rgb_gamma[2]
    transition = rgb_gamma[3]
    slope      = rgb_gamma[4] 
    for (; i; i--) {
        for (j=c; j; j--) {
            C = lRGB[i,j]
            RGB1[i,j] = (abs(C)<=transition ? slope*C :
                sign(C) * ((1 + offset)*abs(C)^g - offset))
        }
    }
    return(RGB1)
}

// Transformation between CIE XYZ 100 and linear RGB [0,1]
// source: https://en.wikipedia.org/wiki/CIE_1931_color_space

`RM' `MAIN'::lRGB_to_XYZ(`RM' lRGB)
{
    `Int' i
    `RM'  XYZ, M
    
    assert_cols(lRGB, 3)
    M = rgb_M'
    i = rows(lRGB)
    XYZ = J(i, 3, .)
    for (; i; i--) XYZ[i,] = lRGB[i,] * M
    if (rgb_white!=white) XYZ = XYZ_to_XYZ(XYZ, rgb_white, white)
    return(XYZ)
}

`RM' `MAIN'::XYZ_to_lRGB(`RM' XYZ)
{
    `Int' i
    `RM'  lRGB, M
    
    assert_cols(XYZ, 3)
    lRGB = XYZ
    if (white!=rgb_white) lRGB = XYZ_to_XYZ(lRGB, white, rgb_white)
    M = rgb_invM'
    for (i=rows(lRGB); i; i--) lRGB[i,] = lRGB[i,] * M
    return(lRGB)
}

`RM' `MAIN'::XYZ_to_XYZ1(`RM' XYZ) return(XYZ/100)
`RM' `MAIN'::XYZ1_to_XYZ(`RM' XYZ1) return(XYZ1*100)

// Transformation between CIE XYZ and CIE xyY
// source: https://en.wikipedia.org/wiki/CIE_1931_color_space

`RM' `MAIN'::XYZ_to_xyY(`RM' XYZ)
{
    `Int' i
    `RS'  sum
    `RM'  xyY
    
    assert_cols(XYZ, 3)
    i = rows(XYZ)
    xyY = J(i, 3, .)
    for (; i; i--) {
        sum = XYZ[i,1] + XYZ[i,2] + XYZ[i,3]
        xyY[i,1] = (sum==0 ? 0 : XYZ[i,1]/sum)
        xyY[i,2] = (sum==0 ? 0 : XYZ[i,2]/sum)
        xyY[i,3] =               XYZ[i,2]
    }
    return(xyY)
}

`RM' `MAIN'::xyY_to_XYZ(`RM' xyY)
{
    `Int' i
    `RS'  f
    `RM'  XYZ
    
    assert_cols(xyY, 3)
    i = rows(xyY)
    XYZ = J(i, 3, .)
    for (; i; i--) {
        f = (xyY[i,2] ? xyY[i,3]/xyY[i,2] : sign(xyY[i,3]) * maxdouble())
        XYZ[i,1] = xyY[i,1] * f
        XYZ[i,2] = xyY[i,3]
        XYZ[i,3] = (1 - xyY[i,1] - xyY[i,2]) * f
    }
    return(XYZ)
}

`RM' `MAIN'::xyY_to_xyY1(`RM' xyY)
{
    assert_cols(xyY, 3)
    xyY[,3] = xyY[,3]/100
    return(xyY)
}
`RM' `MAIN'::xyY1_to_xyY(`RM' xyY1)
{
    assert_cols(xyY1, 3)
    xyY1[,3] = xyY1[,3]*100
    return(xyY1)
}

// Transformation between CIE L*a*b* and CIE XYZ
// source: https://en.wikipedia.org/wiki/CIELAB_color_space

`RM' `MAIN'::XYZ_to_Lab(`RM' XYZ)
{
    `Int' i
    `RM' Lab
    
    assert_cols(XYZ, 3)
    Lab = XYZ :/ white
    for (i=rows(Lab); i; i--) Lab[i,] = _XYZ_to_Lab(Lab[i,])
    return(Lab)
}

`RR' `MAIN'::_XYZ_to_Lab(`RR' XYZ)
{
    return((
        /* L* */ 116 *  _XYZ_to_Lab_f(XYZ[2]) - 16,
        /* a* */ 500 * (_XYZ_to_Lab_f(XYZ[1]) - _XYZ_to_Lab_f(XYZ[2])),
        /* b* */ 200 * (_XYZ_to_Lab_f(XYZ[2]) - _XYZ_to_Lab_f(XYZ[3]))
        ))
}

`RS' `MAIN'::_XYZ_to_Lab_f(`RS' t)
{
    `RS' delta
    
    delta = 6/29
    return( t > delta^3 ? t^(1/3) : t / (3*delta^2) + 4/29 )
}

`RM' `MAIN'::Lab_to_XYZ(`RM' Lab)
{
    `Int' i
    `RM' XYZ

    assert_cols(Lab, 3)
    i = rows(Lab)
    XYZ = J(i, 3, .)
    for (; i; i--) XYZ[i,] = _Lab_to_XYZ(Lab[i,])
    XYZ = XYZ :* white
    return(XYZ)
}

`RR' `MAIN'::_Lab_to_XYZ(`RR' Lab)
{
    return((
        /* X */ _Lab_to_XYZ_f((Lab[1] + 16)/116 + Lab[2]/500),
        /* Y */ _Lab_to_XYZ_f((Lab[1] + 16)/116),
        /* Z */ _Lab_to_XYZ_f((Lab[1] + 16)/116 - Lab[3]/200)
        ))
}

`RS' `MAIN'::_Lab_to_XYZ_f(`RS' t)
{
    `RS' delta
    
    delta = 6/29
    return( t > delta ? t^3 : 3*delta^2 * (t - 4/29) )
}

// Transformation between CIE L*a*b* and CIE LCh
// source: https://en.wikipedia.org/wiki/CIELAB_color_space

`RM' `MAIN'::Lab_to_LCh(`RM' Lab)
{
    assert_cols(Lab, 3)
    if (rows(Lab)==0) return(Lab)
    return((
        /* L */ Lab[,1],
        /* C */ sqrt(Lab[,2]:^2 :+ Lab[,3]:^2),
        /* h */ mod(atan2(Lab[,2], Lab[,3]) * 180 / pi() :+ .5, 360) :- .5
        ))  // note: Mata's atan2() is reverse
}

`RM' `MAIN'::LCh_to_Lab(`RM' LCh)
{
    `RC' h

    assert_cols(LCh, 3)
    h = LCh[,3] * pi() / 180
    return((LCh[,1], LCh[,2] :* cos(h), LCh[,2] :* sin(h)))
}

// Transformation between CIE L*u*v* and RGB [0,1]
// source: https://en.wikipedia.org/wiki/CIELUV
// source: https://en.wikipedia.org/wiki/HCL_color_space

`RM' `MAIN'::XYZ_to_Luv(`RM' XYZ)
{
    `Int' i
    `RM'  Luv
    
    assert_cols(XYZ, 3)
    i = rows(XYZ)
    Luv = J(i, 3, .)
    for (; i; i--) Luv[i,] = _XYZ_to_Luv(XYZ[i,], white)
    return(Luv)
}

`RR' `MAIN'::_XYZ_to_Luv(`RR' XYZ, `RR' xyz)
{
    `RS' L
    
    L = 116 * _XYZ_to_Lab_f(XYZ[2]/xyz[2]) - 16
    return((
        /* L* */ L,
        /* u* */ 13*L * (_XYZ_to_Luv_u(XYZ) - _XYZ_to_Luv_u(xyz)),
        /* v* */ 13*L * (_XYZ_to_Luv_v(XYZ) - _XYZ_to_Luv_v(xyz))
        ))
}

`RS' `MAIN'::_XYZ_to_Luv_u(`RR' XYZ)
{
    `RS' sum
    
    sum = XYZ[1] + 15*XYZ[2] + 3*XYZ[3]
    return( sum==0 ? 0 : 4*XYZ[1]/sum )
}

`RS' `MAIN'::_XYZ_to_Luv_v(`RR' XYZ)
{
    `RS' sum
    
    sum = XYZ[1] + 15*XYZ[2] + 3*XYZ[3]
    return( sum==0 ? 0 : 9*XYZ[2]/sum )
}

`RM' `MAIN'::Luv_to_XYZ(`RM' Luv)
{
    `Int' i
    `RM'  XYZ
    
    assert_cols(Luv, 3)
    i = rows(Luv)
    XYZ = J(i, 3, .)
    for (; i; i--) XYZ[i,] = _Luv_to_XYZ(Luv[i,], white)
    return(XYZ)
}

`RR' `MAIN'::_Luv_to_XYZ(`RR' Luv, `RR' xyz)
{
    `RS' u, v, Y
    
    Y = xyz[2] * _Lab_to_XYZ_f((Luv[1]+16)/116)
    u = (Luv[1]==0 ? 0 : Luv[2] / (13*Luv[1])) + _XYZ_to_Luv_u(xyz)
    v = (Luv[1]==0 ? 0 : Luv[3] / (13*Luv[1])) + _XYZ_to_Luv_v(xyz)
    return((
        /* X */ Y * (9*u) / (4*v),
        /* Y */ Y,
        /* Z */ Y * (12-3*u-20*v) / (4*v)
        ))
}

// Transformation between CIE L*u*v* and HCL
// source: https://en.wikipedia.org/wiki/HCL_color_space

`RM' `MAIN'::Luv_to_HCL(`RM' Luv)
{
    assert_cols(Luv, 3)
    if (rows(Luv)==0) return(Luv)
    return((
        /* H */ mod(atan2(Luv[,2], Luv[,3]) * 180 / pi() :+ .5, 360) :- .5,
        /* C */ sqrt(Luv[,2]:^2 :+ Luv[,3]:^2),
        /* L */ Luv[,1]
        ))  // note: Mata's atan2() is reverse
}

`RM' `MAIN'::HCL_to_Luv(`RM' HCL)
{
    `RC' h
    
    assert_cols(HCL, 3)
    h = HCL[,1] * pi() / 180
    return((HCL[,3], HCL[,2] :* cos(h), HCL[,2] :* sin(h)))
}

// Transformation between CIE XYZ and CIE CAM02
// Source: 
//   Luo, M.R., C. Li (2013). CIECAM02 and its recent developments. P 19-58 in: 
//   C. Fernandez-Maloigne (ed). Advanced color image processing and analysis. 
//   New York: Springer. https://doi.org/10.1007/978-1-4419-6190-7_2

`RM' `MAIN'::XYZ_to_CAM02(`RM' XYZ, `SS' mask)
{
    `Int'  i, r
    `RM'   JCh
    
    assert_cols(XYZ, 3)
    r = rows(XYZ)
    JCh = J(r, 3, .)
    CAM02_setup()
    for (i=r; i; i--) JCh[i,] = _XYZ_to_CAM02(XYZ[i,]')
    return(CAM02_to_CAM02(JCh, "JCh", mask))
}

`RR' `MAIN'::_XYZ_to_CAM02(`RC' XYZ)
{
    `RS'  a, b, h2, A, et, t
    `RS'  J, C, h
    `RC'  LMS, sign, tmp

    LMS  = C02.HPE * C02.iCAT02 * (C02.D :* (C02.CAT02 * XYZ))
    sign = sign(LMS)
    tmp  = ((sign :* C02.FL :* LMS)/100):^0.42
    LMS  = sign :* 400 :* (tmp:/(tmp :+ 27.13)) :+ 0.1
    a    = LMS[1] - 12*LMS[2]/11 + LMS[3]/11
    b    = (LMS[1] + LMS[2] - 2*LMS[3]) / 9
    h    = mod(atan2(a, b) * 180 / pi() + .5, 360) - .5
    h2   = (h < C02.HUE[1,1] ? h + 360 : h)
    A    = (2*LMS[1] + LMS[2] + LMS[3]/20 - 0.305) * C02.Nbb
    if (A<0) J = 0
    else     J = 100 * (A / C02.Aw)^(C02.c * C02.z)
    et   = 0.25 * (cos((h2 * pi())/180 + 2) + 3.8)
    t    = ((50000/13 * C02.Nc * C02.Ncb) * et * sqrt(a^2 + b^2)) / 
           (LMS[1] + LMS[2] + (21/20) * LMS[3])
    if (t<0) C = 0
    else     C = t^0.9 * sqrt(J/100) * (1.64 - 0.29^C02.n)^0.73
    return((J, C, h))
}

`RM' `MAIN'::CAM02_to_XYZ(`RM' CAM02, `SS' mask)
{
    `Int'  i
    `RM'   XYZ
    
    CAM02_setup()
    XYZ = CAM02_to_CAM02(CAM02, mask, "JCh")
    for (i=rows(XYZ); i; i--) XYZ[i,] = _CAM02_to_XYZ(XYZ[i,])
    return(XYZ)
}

`RR' `MAIN'::_CAM02_to_XYZ(`RR' JCh)
{
    `RS'  a, b, A, et, t, p1, p2, p3
    `RS'  J, C, h
    `RC'  XYZ

    // Compute a and b
    J = JCh[1]; C = JCh[2]; h = JCh[3] * pi() / 180
    if (J<0) J = 0 // J is not allowed to be smaller than 0
    if (C<0) C = 0 // C is not allowed to be smaller than 0
    t  = (C / (sqrt(J/100) * (1.64 - 0.29^C02.n)^0.73))^(1/0.9)
    A  = C02.Aw * (J/100)^(1 / (C02.c * C02.z))
    p2 = A / C02.Nbb + 0.305
    if (t==0) a = b = 0
    else {
        p3 = 21/20
        et = 0.25 * (cos(h + 2) + 3.8)
        p1 = (50000/13 * C02.Nc * C02.Ncb) * et * (1/t)
        if (J==0) p1 = 0  // in this case: 1/t = 1/infinity = 0
        if (abs(sin(h))>=abs(cos(h))) {
            b = (p2 * (2 + p3) * (460/1403)) / ((p1 / sin(h)) 
                + (2 + p3) * (220/1403) * (cos(h) / sin(h)) 
                - (27/1403) + p3 * (6300/1403))
            a = b * (cos(h)/sin(h))
        }
        else {
            a = (p2 * (2 + p3) * (460/1403)) / ((p1 / cos(h))
                + (2 + p3) * (220/1403) 
                - ((27/1403) - p3 * (6300/1403)) * (sin(h)/cos(h)))
            b = a * (sin(h)/cos(h))
        }
    }
    
    // Compute XYZ from J, a, and b
    if (missing((J,a,b))) return(J(1,3,.))  // not enough information
    XYZ = ((460*p2 + 451*a + 288*b) \ 
           (460*p2 - 891*a - 261*b) \ 
           (460*p2 - 220*a - 6300*b)) / 1403 :- 0.1
    XYZ = (100/C02.FL) * sign(XYZ) :* 
          ((27.13 * abs(XYZ)) :/ (400 :- abs(XYZ))):^(1/0.42)
          // missing if XYZ>=400
    XYZ = C02.iCAT02 * ((C02.CAT02 * C02.iHPE * XYZ) :/ C02.D)
    return(XYZ')
}

`RM' `MAIN'::CAM02_to_CAM02(`RM' IN, `SS' fmask, `SS' tmask)
{
    `RS' i, j
    `SS' c
    `RC' J, Q, C, M, s, H, h
    `RM' OUT
    
    // setup
    if (fmask=="") fmask = "JCh"
    if (tmask=="") tmask = "JCh"
    j = strlen(fmask)
    assert_cols(IN, j)
    if (fmask==tmask) return(IN) // nothing to do

    // parse input
    for (; j; j--) {
        c = substr(fmask, j, 1)
        if      (c=="J") J = IN[,j]
        else if (c=="Q") Q = IN[,j]
        else if (c=="C") C = IN[,j]
        else if (c=="M") M = IN[,j]
        else if (c=="s") s = IN[,j]
        else if (c=="H") H = IN[,j]
        else if (c=="h") h = IN[,j]
        else {
            display("{err}character '" + c + "' not allowed in mask")
            exit(3498)
        }
    }
    
    // generate output
    j = strlen(tmask)
    i = rows(IN)
    OUT = J(i, j, .)
    if (i==0) return(OUT)
    for (; j; j--) {
        c = substr(tmask, j, 1)
        if (c=="J") {
            if (rows(J)==0) {
                if (rows(Q)) {
                    J = 6.25 * ((C02.c*Q) / ((C02.Aw+4)*C02.FL^0.25)):^2
                }
                else {
                    display("{err}input must contain one of J and Q")
                    exit(3498)
                }
            }
            OUT[,j] = J
        }
        else if (c=="Q") {
            if (rows(Q)==0) CAM02_to_CAM02_Q(J, Q)
            OUT[,j] = Q
        }
        else if (c=="C") {
            if (rows(C)==0) {
                if (rows(M)==0) {
                    if (rows(s)) {
                        if (rows(Q)==0) CAM02_to_CAM02_Q(J, Q)
                        M = (s/100):^2 :* Q
                    }
                    else {
                        display("{err}input must contain one of C, M, and s")
                        exit(3498)
                    }
                }
                C = M / C02.FL^0.25
            }
            OUT[,j] = C
        }
        else if (c=="M") {
            if (rows(M)==0) {
                if (rows(C)) {
                    M = C * C02.FL^0.25
                }
                else if (rows(s)) {
                    if (rows(Q)==0) CAM02_to_CAM02_Q(J, Q)
                    M = (s/100):^2 :* Q
                }
                else {
                    display("{err}input must contain one of C, M, and s")
                    exit(3498)
                }
            }
            OUT[,j] = M
        }
        else if (c=="s") {
            if (rows(s)==0) {
                if (rows(Q)==0) CAM02_to_CAM02_Q(J, Q)
                if (rows(M)==0) {
                    if (rows(C)) M = C * C02.FL^0.25
                    else {
                        display("{err}input must contain one of C, M, and s")
                        exit(3498)
                    }
                }
                s = 100 * sqrt(M:/Q)
            }
            OUT[,j] = s
        }
        else if (c=="H") {
            if (rows(H)==0) {
                if (rows(h)) {
                    i = rows(h)
                    H = J(i, 1, .)
                    for (; i; i--) {
                        H[i]  = CAM02_H(h[i]<C02.HUE[1,1] ? h[i] + 360 : h[i], C02.HUE)
                    }
                }
                else {
                    display("{err}input must contain one of h and H")
                    exit(3498)
                }
            }
            OUT[,j] = H
        }
        else if (c=="h") {
            if (rows(h)==0) {
                if (rows(H)) {
                    i = rows(H)
                    h = J(i, 1, .)
                    for (; i; i--) {
                        h[i] = CAM02_invH(H[i], C02.HUE)
                        if (h[i]>360) h[i] = h[i] - 360
                    }
                }
                else {
                    display("{err}input must contain one of h and H")
                    exit(3498)
                }
            }
            OUT[,j] = h
        }
        else {
            display("{err}character '" + c + "' not allowed in mask")
            exit(3498)
        }
    }
    return(OUT)
}

void `MAIN'::CAM02_to_CAM02_Q(`RM' J, `RM' Q)
{
    if (rows(J)) {
        Q = ((4/C02.c) * (C02.Aw + 4) * C02.FL^0.25) * sqrt(J/100)
    }
    else {
        display("{err}input must contain one of J and Q")
        exit(3498)
    }
}

void `MAIN'::CAM02_setup()
{
    `RS' d, k
    `RC' LMS, sign, tmp
    
    // already set?
    if (C02.set==1) return
    
    // matrixes
    C02.CAT02  = tmatrix("CAT02")
    C02.iCAT02 = luinv(C02.CAT02)
    C02.HPE    = tmatrix("HPE")
    C02.iHPE   = luinv(C02.HPE)
    C02.HUE    = (20.14 , 0.8, 0  ) \  // i=1 Red    (h_i, e_i, H_i)
                 (90    , 0.7, 100) \  // i=2 Yellow
                 (164.25, 1.0, 200) \  // i=3 Green
                 (237.53, 1.2, 300) \  // i=4 Blue
                 (380.14, 0.8, 400)    // i=5 Red
    
    // some constants
    k       = 1 / (5*C02.LA + 1)
    C02.FL  = 0.2 * k^4 * (5*C02.LA) + 0.1 * (1 - k^4)^2 * (5*C02.LA)^(1/3)
    C02.n   = C02.Yb/white[2] //__clip(C.Yb/white[2], 0, 1)  ??
    C02.z   = 1.48 + sqrt(C02.n)
    C02.Ncb = C02.Nbb = 0.725 * (1/C02.n)^0.2

    // Compute D and Aw from white point
    LMS    = C02.CAT02 * white'
    d      = __clip(C02.F * (1 - (1/3.6) * exp((-C02.LA - 42)/92)), 0, 1)
    C02.D  = d * (white[2]:/LMS) :+ (1 - d)
    LMS    = C02.HPE * C02.iCAT02 * (C02.D :* LMS)
    sign   = sign(LMS)
    tmp    = ((sign :* C02.FL :* LMS)/100):^0.42
    LMS    = sign :* 400 :* (tmp:/(tmp :+ 27.13)) :+ 0.1
    C02.Aw = (2*LMS[1] + LMS[2] + LMS[3]/20 - 0.305) * C02.Nbb
    
    // update flag
    C02.set = 1
}

`RS' `MAIN'::CAM02_H(`RS' h, `RM' H)
{
    `Int' i
    
    i = 1
    if (H[2,1]<=h) i++
    if (H[3,1]<=h) i++
    if (H[4,1]<=h) i++
    return(H[i,3] + (100 * (h-H[i,1])/H[i,2]) / 
        ((h-H[i,1])/H[i,2] + (H[i+1,1] - h)/H[i+1,2]))
}

`RS' `MAIN'::CAM02_invH(`RS' h, `RM' H)
{
    `Int' i
    
    i = 1
    if (H[2,3]<=h) i++
    if (H[3,3]<=h) i++
    if (H[4,3]<=h) i++
    return(((h - H[i,3]) * (H[i+1,2]*H[i,1] - H[i,2]*H[i+1,1]) - 100*H[i,1]*H[i+1,2]) /
           ((h - H[i,3]) * (H[i+1,2]-H[i,2]) - 100*H[i+1,2]))
}

// Transformation between CIE CAM02 and J'a'b'
// Source:
//   Luo, M.R., C. Li (2013). CIECAM02 and its recent developments. P 19-58 in: 
//   C. Fernandez-Maloigne (ed). Advanced color image processing and analysis. 
//   New York: Springer. https://doi.org/10.1007/978-1-4419-6190-7_2

// Step 1: CIE CAM02 JMh <-> J'M'h
`RM' `MAIN'::CAM02_to_JMh(`RM' CAM02, `SS' mask, `SS' ucscoefs)
{
    `RS' c1, c2
    `RR' KLc1c2
    `RM' JMh
    
    if (ucscoefs=="") KLc1c2 = ucscoefs()
    else              KLc1c2 = ucscoefs_get(ucscoefs)
    c1 = KLc1c2[2]; c2 = KLc1c2[3]
    CAM02_setup()
    JMh = CAM02_to_CAM02(CAM02, mask, "JMh")
    JMh[,1] = (1 + 100 * c1) * JMh[,1] :/ (1 :+ c1 * JMh[,1])
    JMh[,2] = (1 / c2) * ln(1 :+ c2 * JMh[,2])
    return(JMh)
}

`RM' `MAIN'::JMh_to_CAM02(`RM' JMh0, `SS' ucscoefs, `SS' mask)
{
    `RS' c1, c2
    `RR' KLc1c2
    `RM' JMh
    
    assert_cols(JMh0, 3)
    if (ucscoefs=="") KLc1c2 = ucscoefs()
    else              KLc1c2 = ucscoefs_get(ucscoefs)
    c1 = KLc1c2[2]; c2 = KLc1c2[3]
    JMh = JMh0
    JMh[,1] = JMh[,1] :/ ((1 + 100 * c1) :- c1 * JMh[,1])
        // invalid if J > (1+100*c1)/c1
    JMh[,2] = (exp(c2 * JMh[,2]) :- 1) / c2
    CAM02_setup()
    return(CAM02_to_CAM02(JMh, "JMh", mask))
}

// Step 2: J'M'h <-> J'a'b'
`RM' `MAIN'::CAM02_to_Jab(`RM' CAM02, `SS' mask, `SS' ucscoefs)
{
    `RM' JMh
    `RC' h
    
    JMh = CAM02_to_JMh(CAM02, mask, ucscoefs)
    h = JMh[,3] * pi() / 180
    return((JMh[,1], JMh[,2] :* cos(h), JMh[,2] :* sin(h)))
}

`RM' `MAIN'::Jab_to_CAM02(`RM' Jab, `SS' ucscoefs, `SS' mask)
{
    assert_cols(Jab, 3)
    if (rows(Jab)==0) return(JMh_to_CAM02(Jab, ucscoefs, mask))
    return(JMh_to_CAM02((
        /* J */ Jab[,1],
        /* C */ sqrt(Jab[,2]:^2 :+ Jab[,3]:^2),
        /* h */ mod(atan2(Jab[,2], Jab[,3]) * 180 / pi() :+ .5, 360) :- .5
        ), ucscoefs, mask))  // note: Mata's atan2() is reverse
}

// Transformation between HSV and RGB [0,1]
// source: https://en.wikipedia.org/wiki/HSL_and_HSV

`RM' `MAIN'::RGB1_to_HSV(`RM' RGB1)
{
    `Int' i
    `RM'  HSV

    assert_cols(RGB1, 3)
    i = rows(RGB1)
    HSV = J(i, 3, .)
    for (; i; i--) HSV[i,] = _RGB1_to_HSV(RGB1[i,])
    return(HSV)
}

`RR' `MAIN'::_RGB1_to_HSV(`RV' RGB1)
{
    `RS' r, g, b, M, m, C, H, S, V
    
    r = RGB1[1]; g = RGB1[2]; b = RGB1[3]
    M = max(RGB1); m = min(RGB1)
    C = M - m
    if (C==0)      H = 0 // H undefined, set to 0 by convention
    else if (M==r) H = mod((g-b)/C,  6) * 60
    else if (M==g) H =    ((b-r)/C + 2) * 60
    else if (M==b) H =    ((r-g)/C + 4) * 60
    V = M
    S = (V==0 ? 0 : C/V)
    return((H, S, V))
}

`RM' `MAIN'::HSV_to_RGB1(`RM' HSV)
{
    `Int' i
    `RM'  RGB1
    
    assert_cols(HSV, 3)
    i = rows(HSV)
    RGB1 = J(i, 3, .)
    for (; i; i--) RGB1[i,] = _HSV_to_RGB1(HSV[i,])
    return(RGB1)
}

`RR' `MAIN'::_HSV_to_RGB1(`RV' HSV)
{
    `RS'   h
    `Int'  i
    `IntR' p
    
    h = HSV[1] / 60
    i = mod(floor(h), 6) // wrap around if H outside [0,360)
         if (i==0) p = 1, 2, 3
    else if (i==1) p = 2, 1, 3
    else if (i==2) p = 3, 1, 2
    else if (i==3) p = 3, 2, 1
    else if (i==4) p = 2, 3, 1
    else if (i==5) p = 1, 3, 2
    return((
        HSV[3], 
        HSV[3] * (1 - HSV[2] * abs(mod(h,2) - 1)), 
        HSV[3] * (1 - HSV[2])
        )[p])
}

// Transformation between HSL and RGB [0,1]
// source: https://en.wikipedia.org/wiki/HSL_and_HSV

`RM' `MAIN'::RGB1_to_HSL(`RM' RGB1)
{
    `Int' i
    `RM'  HSL

    assert_cols(RGB1, 3)
    i = rows(RGB1)
    HSL = J(i, 3, .)
    for (; i; i--) HSL[i,] = _RGB1_to_HSL(RGB1[i,])
    return(HSL)
}

`RR' `MAIN'::_RGB1_to_HSL(`RV' RGB1)
{
    `RS' r, g, b, M, m, C, H, S, L
    
    r = RGB1[1]; g = RGB1[2]; b = RGB1[3]
    M = max(RGB1); m = min(RGB1)
    C = M - m
    if (C==0)      H = 0 // H undefined, set to 0 by convention
    else if (M==r) H = mod((g-b)/C,  6) * 60
    else if (M==g) H =    ((b-r)/C + 2) * 60
    else if (M==b) H =    ((r-g)/C + 4) * 60
    L = (M + m)/2
    S = (L==1 ? 0 : C / (1 - abs(M + m - 1)))
    return((H, S, L))
}

`RM' `MAIN'::HSL_to_RGB1(`RM' HSL)
{
    `Int' i
    `RM'  RGB1
    
    assert_cols(HSL, 3)
    i = rows(HSL)
    RGB1 = J(i, 3, .)
    for (; i; i--) RGB1[i,] = _HSL_to_RGB1(HSL[i,])
    return(RGB1)
}

`RR' `MAIN'::_HSL_to_RGB1(`RV' HSL)
{
    `RS'   h, C, X, m
    `Int'  i
    `IntR' p
    
    h = HSL[1] / 60
    i = mod(floor(h), 6) // wrap around if H outside [0,360)
         if (i==0) p = 1, 2, 3
    else if (i==1) p = 2, 1, 3
    else if (i==2) p = 3, 1, 2
    else if (i==3) p = 3, 2, 1
    else if (i==4) p = 2, 3, 1
    else if (i==5) p = 1, 3, 2
    C = (1 - abs(2*HSL[3] - 1)) * HSL[2]
    X = C * (1 - abs(mod(h,2) - 1))
    m = HSL[3] - C/2
    return((C+m, X+m, m)[p])
}

end

* {smcl}
* {marker gen}{bf:Color generators} {hline}
* {asis}

mata:

void `MAIN'::generate(| `SS' space, `T' o2, `T' o3, `T' o4, `T' o5, `T' o6)
{
    if (args()<5) o5 = .       // l
    if (args()<4) o4 = .       // c
    if (args()<3) o3 = .       // h
    if (args()<2) o2 = .       // n
    if (smatch(strlower(space), "HUE")) {
        if (args()<6) o6 = `FALSE' // reverse
        generate_HUE(o2, o3, o4, o5, o6)
        return
    }
    if (args()<6) o6 = .       // p
    generate_OTH(space, o2, o3, o4, o5, o6)
}

void `MAIN'::generate_HUE(`Int' n, `RV' h, `RS' c, `RS' l, `Bool' reverse)
{
    // adopted from pal_hue() from the -scales- package by Hadley Wickham in R
    // see https://github.com/hadley/scales
    `Int' i
    `RS'  h1, h2, dir
    `RM'  C

    if (n>=.)               n = 15
    if (length(h)>0)        h1 = h[1]
    if (length(h)>1)        h2 = h[2]
    if (h1>=.)              h1 = 0 + 15
    if (h2>=.)              h2 = 360 + 15
    if (mod(h2-h1,360) < 1) h2 = h2 - 360/n
    dir = (reverse ? -1 : 1)
    C = J(n, 1, (., (c>=. ? 100 : c), (l>=. ? 65 : l)))
    for (i=1; i<=n; i++) {
         C[i,1] = mod((h1 + (n<=1 ? 0 : (i-1) * (h2-h1) / (n-1))) * dir, 360) 
    }
    pclass = "qualitative"
    set(C, "HCL")
}

void `MAIN'::generate_OTH(`SS' space0, `Int' n0, `RV' h0, `RV' c0, 
    `RV' l0, `RV' p0)
{
    `SS'  space, pclass
    `RS'  n, h, c, l, p
    `RM'  C
    
    space = findkey(gettok(space0, pclass), ("HCL", "LCh", "JMh", "HSV", "HSL")')
    if (space=="") {
        display("{err}space '" + space0 + "' not allowed")
        exit(3498)
    }
    n = n0; h = h0; c = c0; l = l0; p = p0
    if (space=="LCh" | space=="JMh") swap(h, l)
    generate_setup(space, n, pclass, h, c, l, p)
    this.pclass = pclass
    if      (pclass=="qualitative") C = generate_qual(n, h, c, l)
    else if (pclass=="sequential")  C = generate_seq(n, h, c, l, p)
    else if (pclass=="diverging")   C = generate_div(n, h, c, l, p)
    else if (pclass=="heat0")       C = generate_heat0(n, h, c, l)
    else if (pclass=="terrain0")    C = generate_terrain0(n, h, c, l)
    if (space=="LCh" | space=="JMh") C = C[,(3,2,1)]
    set(C, space)
}

void `MAIN'::generate_setup(`SS' space, `Int' n, `SS' pclass0, `RV' h, `RV' c, 
    `RV' l, `RV' p)
{
    `RV'  d
    
    if (n>=.)        n = 15
    if (length(h)<2) h = h, J(1, 2-length(h), .)
    if (length(c)<2) c = c, J(1, 2-length(c), .)
    if (length(l)<2) l = l, J(1, 2-length(l), .)
    if (length(p)<2) p = p, J(1, 2-length(p), .)
    pclass = strlower(pclass0)
    if (smatch(pclass, "qualitative")) {
        if      (space=="HCL") d = (15, .,100, ., 65 , ., ., .)
        else if (space=="LCh") d = (30, ., 70, ., 65 , ., ., .)
        else if (space=="JMh") d = (25, ., 35, ., 67 , ., ., .)
        else if (space=="HSV") d = ( 0, ., .6, ., .9, ., ., .)
        else if (space=="HSL") d = ( 0, ., .7, ., .6, ., ., .)
    }
    else if (smatch(pclass, "sequential")) {
        if      (space=="HCL") d = (260, ., 80, 10 , 25, 95 ,  1  , .)
        else if (space=="LCh") d = (290, ., 72,  6 , 25, 95 ,  1  , .)
        else if (space=="JMh") d = (260, ., 32,  7 , 25, 96 ,  1  , .)
        else if (space=="HSV") d = (240, ., .8, .05, .6,  1 ,  1.2, .)
        else if (space=="HSL") d = (240, .,.65, .65,.35,.975,  1.2, .)
    }
    else if (smatch(pclass, "diverging")) {
        if      (space=="HCL") d = (260,  0, 80, ., 30, 95 , 1  , .)
        else if (space=="LCh") d = (290, 10, 60, ., 30, 95 , 1  , .)
        else if (space=="JMh") d = (260,  8, 30, ., 30, 96 , 1  , .)
        else if (space=="HSV") d = (220,350, .8, ., .6, .95, 1.2, .)
        else if (space=="HSL") d = (220,350,.65, .,.35, .95, 1.2, .)
    }
    else if (space=="HSV" & smatch(pclass, "heat0")) {      // undocumented
        d = (0, 60, 1, 0, 1, ., ., .)
    }
    else if (space=="HSV" & smatch(pclass, "terrain0")) {   // undocumented
        d = (120, 0, 1, 0, .65, .9, ., .)
    }
    else {
        display("{err}class '" + pclass0 + "' not allowed")
        exit(3498)
    }
    if (h[1]>=.) h[1] = d[1]
    if (h[2]>=.) h[2] = (d[2]<. ? d[2] : 
                        (pclass=="qualitative" ? h[1] + 360*(n-1)/n : h[1]))
    if (c[1]>=.) c[1] = d[3]
    if (c[2]>=.) c[2] = (d[4]<. ? d[4] : c[1])
    if (l[1]>=.) l[1] = d[5]
    if (l[2]>=.) l[2] = (d[6]<. ? d[6] : l[1])
    if (p[1]>=.) p[1] = d[7]
    if (p[2]>=.) p[2] = (d[8]<. ? d[8] : p[1])
    pclass0 = pclass
}

`RM' `MAIN'::generate_qual(`Int' n, `RV' h, `RV' c, `RV' l)
{
    `Int' i
    `RM'  C
        
    C = J(n, 3, .)
    for (i=1; i<=n; i++) {
        C[i,] = (mod(n==1 ? h[1] : h[1] + (i-1)*(h[2]-h[1])/(n-1), 360), 
                 c[1], l[1])
    }
    return(C)
}

`RM' `MAIN'::generate_seq(`Int' n, `RV' h, `RV' c, `RV' l, `RV' p)
{
    `Int' i, j
    `RM'  C
        
    C = J(n, 3, .)
    for (i=1; i<=n; i++) {
        j = (n==1 ? 1 : (n-i)/(n-1))
        C[i,] = (mod(h[2] - j*(h[2]-h[1]), 360), c[2] - j^p[1]*(c[2]-c[1]), 
                 l[2] - j^p[2]*(l[2]-l[1]))
    }
    return(C)
}

`RM' `MAIN'::generate_div(`Int' n, `RV' h, `RV' c, `RV' l, `RV' p)
{
    `Int' i, j
    `RM'  C
        
    C = J(n, 3, .)
    for (i=1; i<=n; i++) {
        j = (n==1 ? 1 : (n - 2*i + 1)/(n-1))
        C[i,] = (mod(j>0 ? h[1] : h[2], 360), c[1] * abs(j)^p[1], 
                 l[2] - abs(j)^p[2]*(l[2]-l[1]))
    }
    return(C)
}

`RM' `MAIN'::generate_heat0(`Int' n, `RV' h, `RV' s, `RV' v)
{
    `Int' i, n1, n2
    `RM'  C

    n2 = trunc(n/4)
    n1 = n - n2
    C = J(n, 3, .)
    for (i=1; i<=n1; i++) {
        C[i,] = (mod(h[1] + (n1==1 ? 0 : (i-1)*(h[2]-h[1])/(n1-1)), 360), 
                 s[1], v[1])
    }
    for (; i<=n; i++) {
        C[i,] = (mod(h[2], 360), s[1] - (s[1]-s[2])/(2*n2) + 
        (n2==1 ? 0 : (i-n1-1) * (s[2] - s[1] + (s[1]-s[2])/n2) / (n2-1)), v[1])
    }
    this.pclass = "sequential"
    return(C)
}

`RM' `MAIN'::generate_terrain0(`Int' n, `RV' h, `RV' s, `RV' v)
{
    `Int' i, n1, n2, h3, v3
    `RM'  C
    
    h3   = h[2]
    h[2] = (h[1] + h3) / 2        // 60
    v3   = v[2] + (1 - v[2]) / 2  // .95
    n1   = trunc(n / 2)
    n2   = n - n1 + 1
    C = J(n, 3, .)
    for (i=1; i<=n1; i++) {
        C[i,] = (mod(h[1] + (n1==1 ? 0 : (i-1)*(h[2]-h[1])/(n1-1)), 360), 
                 s[1], v[1] + (n1==1 ? 0 : (i-1)*(v[2]-v[1])/(n1-1)))
    }
    for (; i<=n; i++) {
        C[i,] = (mod(h[2] + (i-n1)*(h3-h[2])/(n2-1), 360),
                 s[1] + (i-n1)*(s[2]-s[1])/(n2-1), 
                 v[2] + (i-n1)*(v3-v[2])/(n2-1))
    }
    this.pclass = "sequential"
    return(C)
}

end

* {smcl}
* {marker web}{bf:Named web colors} {hline}
* Source: {browse "https://www.w3schools.com/colors/colors_names.asp"}
* {asis}

mata:

void `MAIN'::webcolors()
{
    webcolors.notfound("")
    webcolors.put("AliceBlue"           , "#F0F8FF")
    webcolors.put("AntiqueWhite"        , "#FAEBD7")
    webcolors.put("Aqua"                , "#00FFFF")
    webcolors.put("Aquamarine"          , "#7FFFD4")
    webcolors.put("Azure"               , "#F0FFFF")
    webcolors.put("Beige"               , "#F5F5DC")
    webcolors.put("Bisque"              , "#FFE4C4")
    webcolors.put("Black"               , "#000000")
    webcolors.put("BlanchedAlmond"      , "#FFEBCD")
    webcolors.put("Blue"                , "#0000FF")
    webcolors.put("BlueViolet"          , "#8A2BE2")
    webcolors.put("Brown"               , "#A52A2A")
    webcolors.put("BurlyWood"           , "#DEB887")
    webcolors.put("CadetBlue"           , "#5F9EA0")
    webcolors.put("Chartreuse"          , "#7FFF00")
    webcolors.put("Chocolate"           , "#D2691E")
    webcolors.put("Coral"               , "#FF7F50")
    webcolors.put("CornflowerBlue"      , "#6495ED")
    webcolors.put("Cornsilk"            , "#FFF8DC")
    webcolors.put("Crimson"             , "#DC143C")
    webcolors.put("Cyan"                , "#00FFFF")
    webcolors.put("DarkBlue"            , "#00008B")
    webcolors.put("DarkCyan"            , "#008B8B")
    webcolors.put("DarkGoldenRod"       , "#B8860B")
    webcolors.put("DarkGray"            , "#A9A9A9")
    webcolors.put("DarkGrey"            , "#A9A9A9")
    webcolors.put("DarkGreen"           , "#006400")
    webcolors.put("DarkKhaki"           , "#BDB76B")
    webcolors.put("DarkMagenta"         , "#8B008B")
    webcolors.put("DarkOliveGreen"      , "#556B2F")
    webcolors.put("DarkOrange"          , "#FF8C00")
    webcolors.put("DarkOrchid"          , "#9932CC")
    webcolors.put("DarkRed"             , "#8B0000")
    webcolors.put("DarkSalmon"          , "#E9967A")
    webcolors.put("DarkSeaGreen"        , "#8FBC8F")
    webcolors.put("DarkSlateBlue"       , "#483D8B")
    webcolors.put("DarkSlateGray"       , "#2F4F4F")
    webcolors.put("DarkSlateGrey"       , "#2F4F4F")
    webcolors.put("DarkTurquoise"       , "#00CED1")
    webcolors.put("DarkViolet"          , "#9400D3")
    webcolors.put("DeepPink"            , "#FF1493")
    webcolors.put("DeepSkyBlue"         , "#00BFFF")
    webcolors.put("DimGray"             , "#696969")
    webcolors.put("DimGrey"             , "#696969")
    webcolors.put("DodgerBlue"          , "#1E90FF")
    webcolors.put("FireBrick"           , "#B22222")
    webcolors.put("FloralWhite"         , "#FFFAF0")
    webcolors.put("ForestGreen"         , "#228B22")
    webcolors.put("Fuchsia"             , "#FF00FF")
    webcolors.put("Gainsboro"           , "#DCDCDC")
    webcolors.put("GhostWhite"          , "#F8F8FF")
    webcolors.put("Gold"                , "#FFD700")
    webcolors.put("GoldenRod"           , "#DAA520")
    webcolors.put("Gray"                , "#808080")
    webcolors.put("Grey"                , "#808080")
    webcolors.put("Green"               , "#008000")
    webcolors.put("GreenYellow"         , "#ADFF2F")
    webcolors.put("HoneyDew"            , "#F0FFF0")
    webcolors.put("HotPink"             , "#FF69B4")
    webcolors.put("IndianRed"           , "#CD5C5C")
    webcolors.put("Indigo"              , "#4B0082")
    webcolors.put("Ivory"               , "#FFFFF0")
    webcolors.put("Khaki"               , "#F0E68C")
    webcolors.put("Lavender"            , "#E6E6FA")
    webcolors.put("LavenderBlush"       , "#FFF0F5")
    webcolors.put("LawnGreen"           , "#7CFC00")
    webcolors.put("LemonChiffon"        , "#FFFACD")
    webcolors.put("LightBlue"           , "#ADD8E6")
    webcolors.put("LightCoral"          , "#F08080")
    webcolors.put("LightCyan"           , "#E0FFFF")
    webcolors.put("LightGoldenRodYellow", "#FAFAD2")
    webcolors.put("LightGray"           , "#D3D3D3")
    webcolors.put("LightGrey"           , "#D3D3D3")
    webcolors.put("LightGreen"          , "#90EE90")
    webcolors.put("LightPink"           , "#FFB6C1")
    webcolors.put("LightSalmon"         , "#FFA07A")
    webcolors.put("LightSeaGreen"       , "#20B2AA")
    webcolors.put("LightSkyBlue"        , "#87CEFA")
    webcolors.put("LightSlateGray"      , "#778899")
    webcolors.put("LightSlateGrey"      , "#778899")
    webcolors.put("LightSteelBlue"      , "#B0C4DE")
    webcolors.put("LightYellow"         , "#FFFFE0")
    webcolors.put("Lime"                , "#00FF00")
    webcolors.put("LimeGreen"           , "#32CD32")
    webcolors.put("Linen"               , "#FAF0E6")
    webcolors.put("Magenta"             , "#FF00FF")
    webcolors.put("Maroon"              , "#800000")
    webcolors.put("MediumAquaMarine"    , "#66CDAA")
    webcolors.put("MediumBlue"          , "#0000CD")
    webcolors.put("MediumOrchid"        , "#BA55D3")
    webcolors.put("MediumPurple"        , "#9370DB")
    webcolors.put("MediumSeaGreen"      , "#3CB371")
    webcolors.put("MediumSlateBlue"     , "#7B68EE")
    webcolors.put("MediumSpringGreen"   , "#00FA9A")
    webcolors.put("MediumTurquoise"     , "#48D1CC")
    webcolors.put("MediumVioletRed"     , "#C71585")
    webcolors.put("MidnightBlue"        , "#191970")
    webcolors.put("MintCream"           , "#F5FFFA")
    webcolors.put("MistyRose"           , "#FFE4E1")
    webcolors.put("Moccasin"            , "#FFE4B5")
    webcolors.put("NavajoWhite"         , "#FFDEAD")
    webcolors.put("Navy"                , "#000080")
    webcolors.put("OldLace"             , "#FDF5E6")
    webcolors.put("Olive"               , "#808000")
    webcolors.put("OliveDrab"           , "#6B8E23")
    webcolors.put("Orange"              , "#FFA500")
    webcolors.put("OrangeRed"           , "#FF4500")
    webcolors.put("Orchid"              , "#DA70D6")
    webcolors.put("PaleGoldenRod"       , "#EEE8AA")
    webcolors.put("PaleGreen"           , "#98FB98")
    webcolors.put("PaleTurquoise"       , "#AFEEEE")
    webcolors.put("PaleVioletRed"       , "#DB7093")
    webcolors.put("PapayaWhip"          , "#FFEFD5")
    webcolors.put("PeachPuff"           , "#FFDAB9")
    webcolors.put("Peru"                , "#CD853F")
    webcolors.put("Pink"                , "#FFC0CB")
    webcolors.put("Plum"                , "#DDA0DD")
    webcolors.put("PowderBlue"          , "#B0E0E6")
    webcolors.put("Purple"              , "#800080")
    webcolors.put("RebeccaPurple"       , "#663399")
    webcolors.put("Red"                 , "#FF0000")
    webcolors.put("RosyBrown"           , "#BC8F8F")
    webcolors.put("RoyalBlue"           , "#4169E1")
    webcolors.put("SaddleBrown"         , "#8B4513")
    webcolors.put("Salmon"              , "#FA8072")
    webcolors.put("SandyBrown"          , "#F4A460")
    webcolors.put("SeaGreen"            , "#2E8B57")
    webcolors.put("SeaShell"            , "#FFF5EE")
    webcolors.put("Sienna"              , "#A0522D")
    webcolors.put("Silver"              , "#C0C0C0")
    webcolors.put("SkyBlue"             , "#87CEEB")
    webcolors.put("SlateBlue"           , "#6A5ACD")
    webcolors.put("SlateGray"           , "#708090")
    webcolors.put("SlateGrey"           , "#708090")
    webcolors.put("Snow"                , "#FFFAFA")
    webcolors.put("SpringGreen"         , "#00FF7F")
    webcolors.put("SteelBlue"           , "#4682B4")
    webcolors.put("Tan"                 , "#D2B48C")
    webcolors.put("Teal"                , "#008080")
    webcolors.put("Thistle"             , "#D8BFD8")
    webcolors.put("Tomato"              , "#FF6347")
    webcolors.put("Turquoise"           , "#40E0D0")
    webcolors.put("Violet"              , "#EE82EE")
    webcolors.put("Wheat"               , "#F5DEB3")
    webcolors.put("White"               , "#FFFFFF")
    webcolors.put("WhiteSmoke"          , "#F5F5F5")
    webcolors.put("Yellow"              , "#FFFF00")
    webcolors.put("YellowGreen"         , "#9ACD32")
}

end

* {smcl}
* {marker palettes}{bf:Palettes} {hline}
* Sources: see documentation
* {asis}

mata:

void `MAIN'::palette(| `SS' pal0, `RS' n0, `RS' noipolate)
{
    `SS'  p
    `SV'  cdef
    `Int' n
    
    if (args()<3) noipolate = `FALSE'
    n = (n0<. ? n0 : 15)
    p = strlower(pal0)
    if      (smatch(p ,"s2"))                cdef = P_(1, P_s2())
    else if (smatch(p, "s1"))                cdef = P_(1, P_s1())
    else if (smatch(p, "s1r"))               cdef = P_(1, P_s1r())
    else if (smatch(p ,"economist"))         cdef = P_(1, P_economist())
    else if (smatch(p ,"mono"))              cdef = P_(1, P_mono())
    else if (smatch(p ,"cblind"))            cdef = P_(1, P_cblind())
    else if (smatch(p ,"plottig"))           cdef = P_(1, P_plottig())
    else if (smatch(p ,"538"))               cdef = P_(1, P_538())
    else if (smatch(p ,"tfl"))               cdef = P_(1, P_tfl())
    else if (smatch(p ,"mrc"))               cdef = P_(1, P_mrc())
    else if (smatch(p ,"burd"))              cdef = P_(1, P_burd())
    else if (smatch(p ,"lean"))              cdef = P_(1, P_lean())
    else if (smatch(p ,"webcolors"))           cdef = P_(1, P_webc())
    else if (smatch(p ,"webcolors pink"))      cdef = P_(1, P_webc_pi())
    else if (smatch(p ,"webcolors purple"))    cdef = P_(1, P_webc_pu())
    else if (smatch(p ,"webcolors redorange")) cdef = P_(1, P_webc_rd())
    else if (smatch(p ,"webcolors yellow"))    cdef = P_(1, P_webc_ye())
    else if (smatch(p ,"webcolors green"))     cdef = P_(1, P_webc_gn())
    else if (smatch(p ,"webcolors cyan"))      cdef = P_(1, P_webc_cy())
    else if (smatch(p ,"webcolors blue"))      cdef = P_(1, P_webc_bl())
    else if (smatch(p ,"webcolors brown"))     cdef = P_(1, P_webc_br())
    else if (smatch(p ,"webcolors white"))     cdef = P_(1, P_webc_wh())
    else if (smatch(p ,"webcolors gray"))      cdef = P_(1, P_webc_gray())
    else if (smatch(p ,"webcolors grey"))      cdef = P_(1, P_webc_grey())
    else if (smatch(p ,"d3 10"))             cdef = P_(1, P_d3_10())
    else if (smatch(p ,"d3 20"))             cdef = P_(1, P_d3_20())
    else if (smatch(p ,"d3 20b"))            cdef = P_(1, P_d3_20b())
    else if (smatch(p ,"d3 20c"))            cdef = P_(1, P_d3_20c())
    else if (smatch(p ,"Accent"))            cdef = P_(1, P_Accent())
    else if (smatch(p ,"Dark2"))             cdef = P_(1, P_Dark2())
    else if (smatch(p ,"Paired"))            cdef = P_(1, P_Paired())
    else if (smatch(p ,"Pastel1"))           cdef = P_(1, P_Pastel1())
    else if (smatch(p ,"Pastel2"))           cdef = P_(1, P_Pastel2())
    else if (smatch(p ,"Set1"))              cdef = P_(1, P_Set1())
    else if (smatch(p ,"Set2"))              cdef = P_(1, P_Set2())
    else if (smatch(p ,"Set3"))              cdef = P_(1, P_Set3())
    else if (smatch(p ,"Blues"))             cdef = P_(2, P_Blues(n))
    else if (smatch(p ,"BuGn"))              cdef = P_(2, P_BuGn(n))
    else if (smatch(p ,"BuPu"))              cdef = P_(2, P_BuPu(n))
    else if (smatch(p ,"GnBu"))              cdef = P_(2, P_GnBu(n))
    else if (smatch(p ,"Greens"))            cdef = P_(2, P_Greens(n))
    else if (smatch(p ,"Greys"))             cdef = P_(2, P_Greys(n))
    else if (smatch(p ,"OrRd"))              cdef = P_(2, P_OrRd(n))
    else if (smatch(p ,"Oranges"))           cdef = P_(2, P_Oranges(n))
    else if (smatch(p ,"PuBu"))              cdef = P_(2, P_PuBu(n))
    else if (smatch(p ,"PuBuGn"))            cdef = P_(2, P_PuBuGn(n))
    else if (smatch(p ,"PuRd"))              cdef = P_(2, P_PuRd(n))
    else if (smatch(p ,"Purples"))           cdef = P_(2, P_Purples(n))
    else if (smatch(p ,"RdPu"))              cdef = P_(2, P_RdPu(n))
    else if (smatch(p ,"Reds"))              cdef = P_(2, P_Reds(n))
    else if (smatch(p ,"YlGn"))              cdef = P_(2, P_YlGn(n))
    else if (smatch(p ,"YlGnBu"))            cdef = P_(2, P_YlGnBu(n))
    else if (smatch(p ,"YlOrBr"))            cdef = P_(2, P_YlOrBr(n))
    else if (smatch(p ,"YlOrRd"))            cdef = P_(2, P_YlOrRd(n))
    else if (smatch(p ,"BrBG"))              cdef = P_(3, P_BrBG(n))
    else if (smatch(p ,"PRGn"))              cdef = P_(3, P_PRGn(n))
    else if (smatch(p ,"PiYG"))              cdef = P_(3, P_PiYG(n))
    else if (smatch(p ,"PuOr"))              cdef = P_(3, P_PuOr(n))
    else if (smatch(p ,"RdBu"))              cdef = P_(3, P_RdBu(n))
    else if (smatch(p ,"RdGy"))              cdef = P_(3, P_RdGy(n))
    else if (smatch(p ,"RdYlBu"))            cdef = P_(3, P_RdYlBu(n))
    else if (smatch(p ,"RdYlGn"))            cdef = P_(3, P_RdYlGn(n))
    else if (smatch(p ,"Spectral"))          cdef = P_(3, P_Spectral(n))
    else if (smatch(p ,"ptol qualitative"))  cdef = P_(1, P_ptol_qualitative(n))
    else if (smatch(p ,"ptol diverging"))    cdef = P_(3, P_ptol_diverging(n))
    else if (smatch(p ,"ptol rainbow"))      cdef = P_(2, P_ptol_rainbow(n))
    else if (smatch(p ,"tableau"))           cdef = P_(1, P_tableau())
    else if (smatch(p ,"lin carcolor"))             cdef = P_(1, P_lin_carcolor())
    else if (smatch(p ,"lin carcolor algorithm"))   cdef = P_(1, P_lin_carcolor_a())
    else if (smatch(p ,"lin food"))                 cdef = P_(1, P_lin_food())
    else if (smatch(p ,"lin food algorithm"))       cdef = P_(1, P_lin_food_a())
    else if (smatch(p ,"lin features"))             cdef = P_(1, P_lin_features())
    else if (smatch(p ,"lin features algorithm"))   cdef = P_(1, P_lin_features_a())
    else if (smatch(p ,"lin activities"))           cdef = P_(1, P_lin_activities())
    else if (smatch(p ,"lin activities algorithm")) cdef = P_(1, P_lin_activities_a())
    else if (smatch(p ,"lin fruits"))               cdef = P_(1, P_lin_fruits())
    else if (smatch(p ,"lin fruits algorithm"))     cdef = P_(1, P_lin_fruits_a())
    else if (smatch(p ,"lin vegetables"))           cdef = P_(1, P_lin_vegetables())
    else if (smatch(p ,"lin vegetables algorithm")) cdef = P_(1, P_lin_vegetables_a())
    else if (smatch(p ,"lin drinks"))               cdef = P_(1, P_lin_drinks())
    else if (smatch(p ,"lin drinks algorithm"))     cdef = P_(1, P_lin_drinks_a())
    else if (smatch(p ,"lin brands"))               cdef = P_(1, P_lin_brands())
    else if (smatch(p ,"lin brands algorithm"))     cdef = P_(1, P_lin_brands_a())
    else if (smatch(p ,"spmap blues"))       cdef = P_(2, P_spmap_blues(n))
    else if (smatch(p ,"spmap greens"))      cdef = P_(2, P_spmap_greens(n))
    else if (smatch(p ,"spmap greys"))       cdef = P_(2, P_spmap_greys(n))
    else if (smatch(p ,"spmap reds"))        cdef = P_(2, P_spmap_reds(n))
    else if (smatch(p ,"spmap rainbow"))     cdef = P_(2, P_spmap_rainbow(n))
    else if (smatch(p ,"spmap heat"))        cdef = P_(2, P_spmap_heat(n))
    else if (smatch(p ,"spmap terrain"))     cdef = P_(2, P_spmap_terrain(n))
    else if (smatch(p ,"spmap topological")) cdef = P_(2, P_spmap_topological(n))
    else if (smatch(p ,"sfso blue"))         cdef = P_(2, P_sfso_blue())
    else if (smatch(p ,"sfso brown"))        cdef = P_(2, P_sfso_brown())
    else if (smatch(p ,"sfso orange"))       cdef = P_(2, P_sfso_orange())
    else if (smatch(p ,"sfso red"))          cdef = P_(2, P_sfso_red())
    else if (smatch(p ,"sfso pink"))         cdef = P_(2, P_sfso_pink())
    else if (smatch(p ,"sfso purple"))       cdef = P_(2, P_sfso_purple())
    else if (smatch(p ,"sfso violet"))       cdef = P_(2, P_sfso_violet())
    else if (smatch(p ,"sfso ltblue"))       cdef = P_(2, P_sfso_ltblue())
    else if (smatch(p ,"sfso turquoise"))    cdef = P_(2, P_sfso_turquoise())
    else if (smatch(p ,"sfso green"))        cdef = P_(2, P_sfso_green())
    else if (smatch(p ,"sfso olive"))        cdef = P_(2, P_sfso_olive())
    else if (smatch(p ,"sfso black"))        cdef = P_(2, P_sfso_black())
    else if (smatch(p ,"sfso parties"))      cdef = P_(1, P_sfso_parties())
    else if (smatch(p ,"sfso languages"))    cdef = P_(1, P_sfso_languages())
    else if (smatch(p ,"sfso votes"))        cdef = P_(3, P_sfso_votes())
    else {
        display("{err}palette '" + pal0 + "' not found")
        exit(3499)
    }
    pname = p
    colors(cdef[1], ",")
    if (length(cdef)>1) info(cdef[2], ",")
    if (n0<. & n0!=N()) {
        if (n<N() & pclass=="qualitative") recycle(n0) // select first n colors
        else if (noipolate==0) { // ok to recycle or interpolate
            if (pclass=="qualitative") recycle(n0)
            else                       ipolate(n0)
        }
    }
}

`PAL'::P_(`RC' i, `SC' cdef)
{
    if      (i==1) pclass = "qualitative"
    else if (i==2) pclass = "sequential"
    else if (i==3) pclass = "diverging"
    return(cdef)
}
`PAL'::P_s1()        return("dkgreen,orange_red,navy,maroon,teal,sienna,orange,magenta,cyan,red,lime,brown,purple,olive_teal,ltblue")
`PAL'::P_s1r()       return("yellow,lime,midblue,magenta,orange,red,ltblue,sandb,mint,olive_teal,orange_red,blue,pink,teal,sienna")
`PAL'::P_s2()        return("navy,maroon,forest_green,dkorange,teal,cranberry,lavender,khaki,sienna,emidblue,emerald,brown,erose,gold,bluishgray")
`PAL'::P_economist() return("edkblue,emidblue,eltblue,emerald,erose,ebblue,eltgreen,stone,navy,maroon,brown,lavender,teal,cranberry,khaki")
`PAL'::P_mono()      return("gs6,gs10,gs8,gs4,black,gs12,gs2,gs7,gs9,gs11,gs13,gs5,gs3,gs14,gs15")
`PAL'::P_cblind()    return("#000000,#999999,#E69F00,#56B4E9,#009E73,#F0E442,#0072B2,#D55E00,#CC79A7"
                          \ "black,grey,orange,skyblue,bluishgreen,yellow,blue,vermillion,reddishpurple")
`PAL'::P_plottig()   return("black,97 156 255,0 192 175,201 152 0,185 56 255,248 118 109,0 176 246,0 186 56,163 165 0,231 107 243,255 103 164,0 188 216,107 177 0,229 135 0,253 97 209"
                         \  ",plb1_blue,plg1_lightgreenish,ply1_yellowbrownish,pll1_purple,plr1_red,plb2_bluish,plg2_greenish,ply2_yellowbrownish,pll2_purple,plr2_red,plb3_blue,plg3_green,ply3_orange,pll3_purple")
`PAL'::P_538()       return("3 144 214,254 48 11,120 172 68,247 187 5,229 138 233,254 133 3,242 242 242,205 205 206,155 155 155,162 204 246,254 181 167,42 161 237,255 244 241"
                          \ "c538b,c538r,c538g,c538y,c538m,c538o,c538bg,c538axis,c538label,c538bs6_ci,c538rs6_ci2,c538bs1_contr_begin,c538rs11_contr_end")
`PAL'::P_tfl()       return("220 36 31, 0 25 168, 0 114 41, 232 106 16, 137 78 36, 117 16 86, 255 206 0, 65 75 86"
                          \ "tflred,tflblue,tflgreen,tflorange,tflbrown,tflpurple,tflyellow,tflgrey")
`PAL'::P_mrc()       return("33 103 126,106 59 119,130 47 90,208 114 50,255 219 0,181 211 52,138 121 103"
                          \ "mrcblue,mrcpurple,mrcred,mrcorange,mrcyellow,mrcgreen,mrcgrey")
`PAL'::P_burd()      return("33 102 172,178 24 43,27 120 55,230 97 1,1 102 94,197 27 125,118 42 131,140 81 10,77 77 77,103 169 207,209 229 240,239 138 98,253 219 199"
                          \ "Bu_from_RdBu7,Rd_from_RdBu7,Gn_from_PRGn7,Or_from_PuOr7,BG_from_BrBG7,Pi_from_PiYG7,Pu_from_PuOr7,Br_from_BrBG7,Gy_from_RdGy7,burd_ci_arealine,burd_ci_area,burd_ci2_arealine,burd_ci2_area")
`PAL'::P_lean()      return("gs14,gs10,gs12,gs8,gs16,gs13,gs10,gs7,gs4,gs0,gs14,gs10,gs12,gs0,gs16")
`PAL'::P_webc()
{
    if (webcolors.N()==0) webcolors()
    return(invtokens(sort(webcolors.keys(),1)',","))
}
`PAL'::P_webc_pi()   return("Pink,LightPink,HotPink,DeepPink,PaleVioletRed,MediumVioletRed")
`PAL'::P_webc_pu()   return("Lavender,Thistle,Plum,Orchid,Violet,Fuchsia,Magenta,MediumOrchid,DarkOrchid,DarkViolet,BlueViolet,DarkMagenta,Purple,MediumPurple,MediumSlateBlue,SlateBlue,DarkSlateBlue,RebeccaPurple,Indigo")
`PAL'::P_webc_rd()   return("LightSalmon,Salmon,DarkSalmon,LightCoral,IndianRed,Crimson,Red,FireBrick,DarkRed,Orange,DarkOrange,Coral,Tomato,OrangeRed")
`PAL'::P_webc_ye()   return("Gold,Yellow,LightYellow,LemonChiffon,LightGoldenRodYellow,PapayaWhip,Moccasin,PeachPuff,PaleGoldenRod,Khaki,DarkKhaki")
`PAL'::P_webc_gn()   return("GreenYellow,Chartreuse,LawnGreen,Lime,LimeGreen,PaleGreen,LightGreen,MediumSpringGreen,SpringGreen,MediumSeaGreen,SeaGreen,ForestGreen,Green,DarkGreen,YellowGreen,OliveDrab,DarkOliveGreen,MediumAquaMarine,DarkSeaGreen,LightSeaGreen,DarkCyan,Teal")
`PAL'::P_webc_cy()   return("Aqua,Cyan,LightCyan,PaleTurquoise,Aquamarine,Turquoise,MediumTurquoise,DarkTurquoise")
`PAL'::P_webc_bl()   return("CadetBlue,SteelBlue,LightSteelBlue,LightBlue,PowderBlue,LightSkyBlue,SkyBlue,CornflowerBlue,DeepSkyBlue,DodgerBlue,RoyalBlue,Blue,MediumBlue,DarkBlue,Navy,MidnightBlue")
`PAL'::P_webc_br()   return("Cornsilk,BlanchedAlmond,Bisque,NavajoWhite,Wheat,BurlyWood,Tan,RosyBrown,SandyBrown,GoldenRod,DarkGoldenRod,Peru,Chocolate,Olive,SaddleBrown,Sienna,Brown,Maroon")
`PAL'::P_webc_wh()   return("White,Snow,HoneyDew,MintCream,Azure,AliceBlue,GhostWhite,WhiteSmoke,SeaShell,Beige,OldLace,FloralWhite,Ivory,AntiqueWhite,Linen,LavenderBlush,MistyRose")
`PAL'::P_webc_gray() return("Gainsboro,LightGray,Silver,DarkGray,DimGray,Gray,LightSlateGray,SlateGray,DarkSlateGray,Black")
`PAL'::P_webc_grey() return("Gainsboro,LightGrey,Silver,DarkGrey,DimGrey,Grey,LightSlateGrey,SlateGrey,DarkSlateGrey,Black")
`PAL'::P_d3_10()     return("#1f77b4,#ff7f0e,#2ca02c,#d62728,#9467bd,#8c564b,#e377c2,#7f7f7f,#bcbd22,#17becf")
`PAL'::P_d3_20()     return("#1f77b4,#aec7e8,#ff7f0e,#ffbb78,#2ca02c,#98df8a,#d62728,#ff9896,#9467bd,#c5b0d5,#8c564b,#c49c94,#e377c2,#f7b6d2,#7f7f7f,#c7c7c7,#bcbd22,#dbdb8d,#17becf,#9edae5")
`PAL'::P_d3_20b()    return("#393b79,#5254a3,#6b6ecf,#9c9ede,#637939,#8ca252,#b5cf6b,#cedb9c,#8c6d31,#bd9e39,#e7ba52,#e7cb94,#843c39,#ad494a,#d6616b,#e7969c,#7b4173,#a55194,#ce6dbd,#de9ed6")
`PAL'::P_d3_20c()    return("#3182bd,#6baed6,#9ecae1,#c6dbef,#e6550d,#fd8d3c,#fdae6b,#fdd0a2,#31a354,#74c476,#a1d99b,#c7e9c0,#756bb1,#9e9ac8,#bcbddc,#dadaeb,#636363,#969696,#bdbdbd,#d9d9d9")
`PAL'::P_Accent()    return("127 201 127,190 174 212,253 192 134,255 255 153,56 108 176,240 2 127,191 91 23,102 102 102")
`PAL'::P_Dark2()     return("27 158 119,217 95 2,117 112 179,231 41 138,102 166 30,230 171 2,166 118 29,102 102 102")
`PAL'::P_Paired()    return("166 206 227,31 120 180,178 223 138,51 160 44,251 154 153,227 26 28,253 191 111,255 127 0,202 178 214,106 61 154,255 255 153,177 89 40")
`PAL'::P_Pastel1()   return("251 180 174,179 205 227,204 235 197,222 203 228,254 217 166,255 255 204,229 216 189,253 218 236,242 242 242")
`PAL'::P_Pastel2()   return("179 226 205,253 205 172,203 213 232,244 202 228,230 245 201,255 242 174,241 226 204,204 204 204")
`PAL'::P_Set1()      return("228 26 28,55 126 184,77 175 74,152 78 163,255 127 0,255 255 51,166 86 40,247 129 191,153 153 153")
`PAL'::P_Set2()      return("102 194 165,252 141 98,141 160 203,231 138 195,166 216 84,255 217 47,229 196 148,179 179 179")
`PAL'::P_Set3()      return("141 211 199,255 255 179,190 186 218,251 128 114,128 177 211,253 180 98,179 222 105,252 205 229,217 217 217,188 128 189,204 235 197,255 237 111")
`PAL'::P_Blues(`RS' n)
{
    if (n<=3)  return("222 235 247,158 202 225,49 130 189")
    if (n==4)  return("239 243 255,189 215 231,107 174 214,33 113 181")
    if (n==5)  return("239 243 255,189 215 231,107 174 214,49 130 189,8 81 156")
    if (n==6)  return("239 243 255,198 219 239,158 202 225,107 174 214,49 130 189,8 81 156")
    if (n==7)  return("239 243 255,198 219 239,158 202 225,107 174 214,66 146 198,33 113 181,8 69 148")
    if (n==8)  return("247 251 255,222 235 247,198 219 239,158 202 225,107 174 214,66 146 198,33 113 181,8 69 148")
    if (n>=9)  return("247 251 255,222 235 247,198 219 239,158 202 225,107 174 214,66 146 198,33 113 181,8 81 156,8 48 107")
}
`PAL'::P_BuGn(`RS' n)
{
    if (n<=3)  return("229 245 249,153 216 201,44 162 95")
    if (n==4)  return("237 248 251,178 226 226,102 194 164,35 139 69")
    if (n==5)  return("237 248 251,178 226 226,102 194 164,44 162 95,0 109 44")
    if (n==6)  return("237 248 251,204 236 230,153 216 201,102 194 164,44 162 95,0 109 44")
    if (n==7)  return("237 248 251,204 236 230,153 216 201,102 194 164,65 174 118,35 139 69,0 88 36")
    if (n==8)  return("247 252 253,229 245 249,204 236 230,153 216 201,102 194 164,65 174 118,35 139 69,0 88 36")
    if (n>=9)  return("247 252 253,229 245 249,204 236 230,153 216 201,102 194 164,65 174 118,35 139 69,0 109 44,0 68 27")
}
`PAL'::P_BuPu(`RS' n)
{
    if (n<=3)  return("224 236 244,158 188 218,136 86 167")
    if (n==4)  return("237 248 251,179 205 227,140 150 198,136 65 157")
    if (n==5)  return("237 248 251,179 205 227,140 150 198,136 86 167,129 15 124")
    if (n==6)  return("237 248 251,191 211 230,158 188 218,140 150 198,136 86 167,129 15 124")
    if (n==7)  return("237 248 251,191 211 230,158 188 218,140 150 198,140 107 177,136 65 157,110 1 107")
    if (n==8)  return("247 252 253,224 236 244,191 211 230,158 188 218,140 150 198,140 107 177,136 65 157,110 1 107")
    if (n>=9)  return("247 252 253,224 236 244,191 211 230,158 188 218,140 150 198,140 107 177,136 65 157,129 15 124,77 0 75")
}
`PAL'::P_GnBu(`RS' n)
{
    if (n<=3)  return("224 243 219,168 221 181,67 162 202")
    if (n==4)  return("240 249 232,186 228 188,123 204 196,43 140 190")
    if (n==5)  return("240 249 232,186 228 188,123 204 196,67 162 202,8 104 172")
    if (n==6)  return("240 249 232,204 235 197,168 221 181,123 204 196,67 162 202,8 104 172")
    if (n==7)  return("240 249 232,204 235 197,168 221 181,123 204 196,78 179 211,43 140 190,8 88 158")
    if (n==8)  return("247 252 240,224 243 219,204 235 197,168 221 181,123 204 196,78 179 211,43 140 190,8 88 158")
    if (n>=9)  return("247 252 240,224 243 219,204 235 197,168 221 181,123 204 196,78 179 211,43 140 190,8 104 172,8 64 129")
}
`PAL'::P_Greens(`RS' n)
{
    if (n<=3)  return("229 245 224,161 217 155,49 163 84")
    if (n==4)  return("237 248 233,186 228 179,116 196 118,35 139 69")
    if (n==5)  return("237 248 233,186 228 179,116 196 118,49 163 84,0 109 44")
    if (n==6)  return("237 248 233,199 233 192,161 217 155,116 196 118,49 163 84,0 109 44")
    if (n==7)  return("237 248 233,199 233 192,161 217 155,116 196 118,65 171 93,35 139 69,0 90 50")
    if (n==8)  return("247 252 245,229 245 224,199 233 192,161 217 155,116 196 118,65 171 93,35 139 69,0 90 50")
    if (n>=9)  return("247 252 245,229 245 224,199 233 192,161 217 155,116 196 118,65 171 93,35 139 69,0 109 44,0 68 27")
}
`PAL'::P_Greys(`RS' n)
{
    if (n<=3)  return("240 240 240,189 189 189,99 99 99")
    if (n==4)  return("247 247 247,204 204 204,150 150 150,82 82 82")
    if (n==5)  return("247 247 247,204 204 204,150 150 150,99 99 99,37 37 37")
    if (n==6)  return("247 247 247,217 217 217,189 189 189,150 150 150,99 99 99,37 37 37")
    if (n==7)  return("247 247 247,217 217 217,189 189 189,150 150 150,115 115 115,82 82 82,37 37 37")
    if (n==8)  return("255 255 255,240 240 240,217 217 217,189 189 189,150 150 150,115 115 115,82 82 82,37 37 37")
    if (n>=9)  return("255 255 255,240 240 240,217 217 217,189 189 189,150 150 150,115 115 115,82 82 82,37 37 37,0 0 0")
}
`PAL'::P_OrRd(`RS' n)
{
    if (n<=3)  return("254 232 200,253 187 132,227 74 51")
    if (n==4)  return("254 240 217,253 204 138,252 141 89,215 48 31")
    if (n==5)  return("254 240 217,253 204 138,252 141 89,227 74 51,179 0 0")
    if (n==6)  return("254 240 217,253 212 158,253 187 132,252 141 89,227 74 51,179 0 0")
    if (n==7)  return("254 240 217,253 212 158,253 187 132,252 141 89,239 101 72,215 48 31,153 0 0")
    if (n==8)  return("255 247 236,254 232 200,253 212 158,253 187 132,252 141 89,239 101 72,215 48 31,153 0 0")
    if (n>=9)  return("255 247 236,254 232 200,253 212 158,253 187 132,252 141 89,239 101 72,215 48 31,179 0 0,127 0 0")
}
`PAL'::P_Oranges(`RS' n)
{
    if (n<=3)  return("254 230 206,253 174 107,230 85 13")
    if (n==4)  return("254 237 222,253 190 133,253 141 60,217 71 1")
    if (n==5)  return("254 237 222,253 190 133,253 141 60,230 85 13,166 54 3")
    if (n==6)  return("254 237 222,253 208 162,253 174 107,253 141 60,230 85 13,166 54 3")
    if (n==7)  return("254 237 222,253 208 162,253 174 107,253 141 60,241 105 19,217 72 1,140 45 4")
    if (n==8)  return("255 245 235,254 230 206,253 208 162,253 174 107,253 141 60,241 105 19,217 72 1,140 45 4")
    if (n>=9)  return("255 245 235,254 230 206,253 208 162,253 174 107,253 141 60,241 105 19,217 72 1,166 54 3,127 39 4")
}
`PAL'::P_PuBu(`RS' n)
{
    if (n<=3)  return("236 231 242,166 189 219,43 140 190")
    if (n==4)  return("241 238 246,189 201 225,116 169 207,5 112 176")
    if (n==5)  return("241 238 246,189 201 225,116 169 207,43 140 190,4 90 141")
    if (n==6)  return("241 238 246,208 209 230,166 189 219,116 169 207,43 140 190,4 90 141")
    if (n==7)  return("241 238 246,208 209 230,166 189 219,116 169 207,54 144 192,5 112 176,3 78 123")
    if (n==8)  return("255 247 251,236 231 242,208 209 230,166 189 219,116 169 207,54 144 192,5 112 176,3 78 123")
    if (n>=9)  return("255 247 251,236 231 242,208 209 230,166 189 219,116 169 207,54 144 192,5 112 176,4 90 141,2 56 88")
}
`PAL'::P_PuBuGn(`RS' n)
{
    if (n<=3)  return("236 226 240,166 189 219,28 144 153")
    if (n==4)  return("246 239 247,189 201 225,103 169 207,2 129 138")
    if (n==5)  return("246 239 247,189 201 225,103 169 207,28 144 153,1 108 89")
    if (n==6)  return("246 239 247,208 209 230,166 189 219,103 169 207,28 144 153,1 108 89")
    if (n==7)  return("246 239 247,208 209 230,166 189 219,103 169 207,54 144 192,2 129 138,1 100 80")
    if (n==8)  return("255 247 251,236 226 240,208 209 230,166 189 219,103 169 207,54 144 192,2 129 138,1 100 80")
    if (n>=9)  return("255 247 251,236 226 240,208 209 230,166 189 219,103 169 207,54 144 192,2 129 138,1 108 89,1 70 54")
}
`PAL'::P_PuRd(`RS' n)
{
    if (n<=3)  return("231 225 239,201 148 199,221 28 119")
    if (n==4)  return("241 238 246,215 181 216,223 101 176,206 18 86")
    if (n==5)  return("241 238 246,215 181 216,223 101 176,221 28 119,152 0 67")
    if (n==6)  return("241 238 246,212 185 218,201 148 199,223 101 176,221 28 119,152 0 67")
    if (n==7)  return("241 238 246,212 185 218,201 148 199,223 101 176,231 41 138,206 18 86,145 0 63")
    if (n==8)  return("247 244 249,231 225 239,212 185 218,201 148 199,223 101 176,231 41 138,206 18 86,145 0 63")
    if (n>=9)  return("247 244 249,231 225 239,212 185 218,201 148 199,223 101 176,231 41 138,206 18 86,152 0 67,103 0 31")
}
`PAL'::P_Purples(`RS' n)
{
    if (n<=3)  return("239 237 245,188 189 220,117 107 177")
    if (n==4)  return("242 240 247,203 201 226,158 154 200,106 81 163")
    if (n==5)  return("242 240 247,203 201 226,158 154 200,117 107 177,84 39 143")
    if (n==6)  return("242 240 247,218 218 235,188 189 220,158 154 200,117 107 177,84 39 143")
    if (n==7)  return("242 240 247,218 218 235,188 189 220,158 154 200,128 125 186,106 81 163,74 20 134")
    if (n==8)  return("252 251 253,239 237 245,218 218 235,188 189 220,158 154 200,128 125 186,106 81 163,74 20 134")
    if (n>=9)  return("252 251 253,239 237 245,218 218 235,188 189 220,158 154 200,128 125 186,106 81 163,84 39 143,63 0 125")
}
`PAL'::P_RdPu(`RS' n)
{
    if (n<=3)  return("253 224 221,250 159 181,197 27 138")
    if (n==4)  return("254 235 226,251 180 185,247 104 161,174 1 126")
    if (n==5)  return("254 235 226,251 180 185,247 104 161,197 27 138,122 1 119")
    if (n==6)  return("254 235 226,252 197 192,250 159 181,247 104 161,197 27 138,122 1 119")
    if (n==7)  return("254 235 226,252 197 192,250 159 181,247 104 161,221 52 151,174 1 126,122 1 119")
    if (n==8)  return("255 247 243,253 224 221,252 197 192,250 159 181,247 104 161,221 52 151,174 1 126,122 1 119")
    if (n>=9)  return("255 247 243,253 224 221,252 197 192,250 159 181,247 104 161,221 52 151,174 1 126,122 1 119,73 0 106")
}
`PAL'::P_Reds(`RS' n)
{
    if (n<=3)  return("254 224 210,252 146 114,222 45 38")
    if (n==4)  return("254 229 217,252 174 145,251 106 74,203 24 29")
    if (n==5)  return("254 229 217,252 174 145,251 106 74,222 45 38,165 15 21")
    if (n==6)  return("254 229 217,252 187 161,252 146 114,251 106 74,222 45 38,165 15 21")
    if (n==7)  return("254 229 217,252 187 161,252 146 114,251 106 74,239 59 44,203 24 29,153 0 13")
    if (n==8)  return("255 245 240,254 224 210,252 187 161,252 146 114,251 106 74,239 59 44,203 24 29,153 0 13")
    if (n>=9)  return("255 245 240,254 224 210,252 187 161,252 146 114,251 106 74,239 59 44,203 24 29,165 15 21,103 0 13")
}
`PAL'::P_YlGn(`RS' n)
{
    if (n<=3)  return("247 252 185,173 221 142,49 163 84")
    if (n==4)  return("255 255 204,194 230 153,120 198 121,35 132 67")
    if (n==5)  return("255 255 204,194 230 153,120 198 121,49 163 84,0 104 55")
    if (n==6)  return("255 255 204,217 240 163,173 221 142,120 198 121,49 163 84,0 104 55")
    if (n==7)  return("255 255 204,217 240 163,173 221 142,120 198 121,65 171 93,35 132 67,0 90 50")
    if (n==8)  return("255 255 229,247 252 185,217 240 163,173 221 142,120 198 121,65 171 93,35 132 67,0 90 50")
    if (n>=9)  return("255 255 229,247 252 185,217 240 163,173 221 142,120 198 121,65 171 93,35 132 67,0 104 55,0 69 41")
}
`PAL'::P_YlGnBu(`RS' n)
{
    if (n<=3)  return("237 248 177,127 205 187,44 127 184")
    if (n==4)  return("255 255 204,161 218 180,65 182 196,34 94 168")
    if (n==5)  return("255 255 204,161 218 180,65 182 196,44 127 184,37 52 148")
    if (n==6)  return("255 255 204,199 233 180,127 205 187,65 182 196,44 127 184,37 52 148")
    if (n==7)  return("255 255 204,199 233 180,127 205 187,65 182 196,29 145 192,34 94 168,12 44 132")
    if (n==8)  return("255 255 217,237 248 177,199 233 180,127 205 187,65 182 196,29 145 192,34 94 168,12 44 132")
    if (n>=9)  return("255 255 217,237 248 177,199 233 180,127 205 187,65 182 196,29 145 192,34 94 168,37 52 148,8 29 88")
}
`PAL'::P_YlOrBr(`RS' n)
{
    if (n<=3)  return("255 247 188,254 196 79,217 95 14")
    if (n==4)  return("255 255 212,254 217 142,254 153 41,204 76 2")
    if (n==5)  return("255 255 212,254 217 142,254 153 41,217 95 14,153 52 4")
    if (n==6)  return("255 255 212,254 227 145,254 196 79,254 153 41,217 95 14,153 52 4")
    if (n==7)  return("255 255 212,254 227 145,254 196 79,254 153 41,236 112 20,204 76 2,140 45 4")
    if (n==8)  return("255 255 229,255 247 188,254 227 145,254 196 79,254 153 41,236 112 20,204 76 2,140 45 4")
    if (n>=9)  return("255 255 229,255 247 188,254 227 145,254 196 79,254 153 41,236 112 20,204 76 2,153 52 4,102 37 6")
}
`PAL'::P_YlOrRd(`RS' n)
{
    if (n<=3)  return("255 237 160,254 178 76,240 59 32")
    if (n==4)  return("255 255 178,254 204 92,253 141 60,227 26 28")
    if (n==5)  return("255 255 178,254 204 92,253 141 60,240 59 32,189 0 38")
    if (n==6)  return("255 255 178,254 217 118,254 178 76,253 141 60,240 59 32,189 0 38")
    if (n==7)  return("255 255 178,254 217 118,254 178 76,253 141 60,252 78 42,227 26 28,177 0 38")
    if (n==8)  return("255 255 204,255 237 160,254 217 118,254 178 76,253 141 60,252 78 42,227 26 28,177 0 38")
    if (n>=9)  return("255 255 204,255 237 160,254 217 118,254 178 76,253 141 60,252 78 42,227 26 28,189 0 38,128 0 38")
}
`PAL'::P_BrBG(`RS' n)
{
    if (n<=3)  return("216 179 101,245 245 245,90 180 172")
    if (n==4)  return("166 97 26,223 194 125,128 205 193,1 133 113")
    if (n==5)  return("166 97 26,223 194 125,245 245 245,128 205 193,1 133 113")
    if (n==6)  return("140 81 10,216 179 101,246 232 195,199 234 229,90 180 172,1 102 94")
    if (n==7)  return("140 81 10,216 179 101,246 232 195,245 245 245,199 234 229,90 180 172,1 102 94")
    if (n==8)  return("140 81 10,191 129 45,223 194 125,246 232 195,199 234 229,128 205 193,53 151 143,1 102 94")
    if (n==9)  return("140 81 10,191 129 45,223 194 125,246 232 195,245 245 245,199 234 229,128 205 193,53 151 143,1 102 94")
    if (n==10) return("84 48 5,140 81 10,191 129 45,223 194 125,246 232 195,199 234 229,128 205 193,53 151 143,1 102 94,0 60 48")
    if (n>=11) return("84 48 5,140 81 10,191 129 45,223 194 125,246 232 195,245 245 245,199 234 229,128 205 193,53 151 143,1 102 94,0 60 48")
}
`PAL'::P_PRGn(`RS' n)
{
    if (n<=3)  return("175 141 195,247 247 247,127 191 123")
    if (n==4)  return("123 50 148,194 165 207,166 219 160,0 136 55")
    if (n==5)  return("123 50 148,194 165 207,247 247 247,166 219 160,0 136 55")
    if (n==6)  return("118 42 131,175 141 195,231 212 232,217 240 211,127 191 123,27 120 55")
    if (n==7)  return("118 42 131,175 141 195,231 212 232,247 247 247,217 240 211,127 191 123,27 120 55")
    if (n==8)  return("118 42 131,153 112 171,194 165 207,231 212 232,217 240 211,166 219 160,90 174 97,27 120 55")
    if (n==9)  return("118 42 131,153 112 171,194 165 207,231 212 232,247 247 247,217 240 211,166 219 160,90 174 97,27 120 55")
    if (n==10) return("64 0 75,118 42 131,153 112 171,194 165 207,231 212 232,217 240 211,166 219 160,90 174 97,27 120 55,0 68 27")
    if (n>=11) return("64 0 75,118 42 131,153 112 171,194 165 207,231 212 232,247 247 247,217 240 211,166 219 160,90 174 97,27 120 55,0 68 27")
}
`PAL'::P_PiYG(`RS' n)
{
    if (n<=3)  return("233 163 201,247 247 247,161 215 106")
    if (n==4)  return("208 28 139,241 182 218,184 225 134,77 172 38")
    if (n==5)  return("208 28 139,241 182 218,247 247 247,184 225 134,77 172 38")
    if (n==6)  return("197 27 125,233 163 201,253 224 239,230 245 208,161 215 106,77 146 33")
    if (n==7)  return("197 27 125,233 163 201,253 224 239,247 247 247,230 245 208,161 215 106,77 146 33")
    if (n==8)  return("197 27 125,222 119 174,241 182 218,253 224 239,230 245 208,184 225 134,127 188 65,77 146 33")
    if (n==9)  return("197 27 125,222 119 174,241 182 218,253 224 239,247 247 247,230 245 208,184 225 134,127 188 65,77 146 33")
    if (n==10) return("142 1 82,197 27 125,222 119 174,241 182 218,253 224 239,230 245 208,184 225 134,127 188 65,77 146 33,39 100 25")
    if (n>=11) return("142 1 82,197 27 125,222 119 174,241 182 218,253 224 239,247 247 247,230 245 208,184 225 134,127 188 65,77 146 33,39 100 25")
}
`PAL'::P_PuOr(`RS' n)
{
    if (n<=3)  return("241 163 64,247 247 247,153 142 195")
    if (n==4)  return("230 97 1,253 184 99,178 171 210,94 60 153")
    if (n==5)  return("230 97 1,253 184 99,247 247 247,178 171 210,94 60 153")
    if (n==6)  return("179 88 6,241 163 64,254 224 182,216 218 235,153 142 195,84 39 136")
    if (n==7)  return("179 88 6,241 163 64,254 224 182,247 247 247,216 218 235,153 142 195,84 39 136")
    if (n==8)  return("179 88 6,224 130 20,253 184 99,254 224 182,216 218 235,178 171 210,128 115 172,84 39 136")
    if (n==9)  return("179 88 6,224 130 20,253 184 99,254 224 182,247 247 247,216 218 235,178 171 210,128 115 172,84 39 136")
    if (n==10) return("127 59 8,179 88 6,224 130 20,253 184 99,254 224 182,216 218 235,178 171 210,128 115 172,84 39 136,45 0 75")
    if (n>=11) return("127 59 8,179 88 6,224 130 20,253 184 99,254 224 182,247 247 247,216 218 235,178 171 210,128 115 172,84 39 136,45 0 75")
}
`PAL'::P_RdBu(`RS' n)
{
    if (n<=3)  return("239 138 98,247 247 247,103 169 207")
    if (n==4)  return("202 0 32,244 165 130,146 197 222,5 113 176")
    if (n==5)  return("202 0 32,244 165 130,247 247 247,146 197 222,5 113 176")
    if (n==6)  return("178 24 43,239 138 98,253 219 199,209 229 240,103 169 207,33 102 172")
    if (n==7)  return("178 24 43,239 138 98,253 219 199,247 247 247,209 229 240,103 169 207,33 102 172")
    if (n==8)  return("178 24 43,214 96 77,244 165 130,253 219 199,209 229 240,146 197 222,67 147 195,33 102 172")
    if (n==9)  return("178 24 43,214 96 77,244 165 130,253 219 199,247 247 247,209 229 240,146 197 222,67 147 195,33 102 172")
    if (n==10) return("103 0 31,178 24 43,214 96 77,244 165 130,253 219 199,209 229 240,146 197 222,67 147 195,33 102 172,5 48 97")
    if (n>=11) return("103 0 31,178 24 43,214 96 77,244 165 130,253 219 199,247 247 247,209 229 240,146 197 222,67 147 195,33 102 172,5 48 97")
}
`PAL'::P_RdGy(`RS' n)
{
    if (n<=3)  return("239 138 98,255 255 255,153 153 153")
    if (n==4)  return("202 0 32,244 165 130,186 186 186,64 64 64")
    if (n==5)  return("202 0 32,244 165 130,255 255 255,186 186 186,64 64 64")
    if (n==6)  return("178 24 43,239 138 98,253 219 199,224 224 224,153 153 153,77 77 77")
    if (n==7)  return("178 24 43,239 138 98,253 219 199,255 255 255,224 224 224,153 153 153,77 77 77")
    if (n==8)  return("178 24 43,214 96 77,244 165 130,253 219 199,224 224 224,186 186 186,135 135 135,77 77 77")
    if (n==9)  return("178 24 43,214 96 77,244 165 130,253 219 199,255 255 255,224 224 224,186 186 186,135 135 135,77 77 77")
    if (n==10) return("103 0 31,178 24 43,214 96 77,244 165 130,253 219 199,224 224 224,186 186 186,135 135 135,77 77 77,26 26 26")
    if (n>=11) return("103 0 31,178 24 43,214 96 77,244 165 130,253 219 199,255 255 255,224 224 224,186 186 186,135 135 135,77 77 77,26 26 26")
}
`PAL'::P_RdYlBu(`RS' n)
{
    if (n<=3)  return("252 141 89,255 255 191,145 191 219")
    if (n==4)  return("215 25 28,253 174 97,171 217 233,44 123 182")
    if (n==5)  return("215 25 28,253 174 97,255 255 191,171 217 233,44 123 182")
    if (n==6)  return("215 48 39,252 141 89,254 224 144,224 243 248,145 191 219,69 117 180")
    if (n==7)  return("215 48 39,252 141 89,254 224 144,255 255 191,224 243 248,145 191 219,69 117 180")
    if (n==8)  return("215 48 39,244 109 67,253 174 97,254 224 144,224 243 248,171 217 233,116 173 209,69 117 180")
    if (n==9)  return("215 48 39,244 109 67,253 174 97,254 224 144,255 255 191,224 243 248,171 217 233,116 173 209,69 117 180")
    if (n==10) return("165 0 38,215 48 39,244 109 67,253 174 97,254 224 144,224 243 248,171 217 233,116 173 209,69 117 180,49 54 149")
    if (n>=11) return("165 0 38,215 48 39,244 109 67,253 174 97,254 224 144,255 255 191,224 243 248,171 217 233,116 173 209,69 117 180,49 54 149")
}
`PAL'::P_RdYlGn(`RS' n)
{
    if (n<=3)  return("252 141 89,255 255 191,145 207 96")
    if (n==4)  return("215 25 28,253 174 97,166 217 106,26 150 65")
    if (n==5)  return("215 25 28,253 174 97,255 255 191,166 217 106,26 150 65")
    if (n==6)  return("215 48 39,252 141 89,254 224 139,217 239 139,145 207 96,26 152 80")
    if (n==7)  return("215 48 39,252 141 89,254 224 139,255 255 191,217 239 139,145 207 96,26 152 80")
    if (n==8)  return("215 48 39,244 109 67,253 174 97,254 224 139,217 239 139,166 217 106,102 189 99,26 152 80")
    if (n==9)  return("215 48 39,244 109 67,253 174 97,254 224 139,255 255 191,217 239 139,166 217 106,102 189 99,26 152 80")
    if (n==10) return("165 0 38,215 48 39,244 109 67,253 174 97,254 224 139,217 239 139,166 217 106,102 189 99,26 152 80,0 104 55")
    if (n>=11) return("165 0 38,215 48 39,244 109 67,253 174 97,254 224 139,255 255 191,217 239 139,166 217 106,102 189 99,26 152 80,0 104 55")
}
`PAL'::P_Spectral(`RS' n)
{
    if (n<=3)  return("252 141 89,255 255 191,153 213 148")
    if (n==4)  return("215 25 28,253 174 97,171 221 164,43 131 186")
    if (n==5)  return("215 25 28,253 174 97,255 255 191,171 221 164,43 131 186")
    if (n==6)  return("213 62 79,252 141 89,254 224 139,230 245 152,153 213 148,50 136 189")
    if (n==7)  return("213 62 79,252 141 89,254 224 139,255 255 191,230 245 152,153 213 148,50 136 189")
    if (n==8)  return("213 62 79,244 109 67,253 174 97,254 224 139,230 245 152,171 221 164,102 194 165,50 136 189")
    if (n==9)  return("213 62 79,244 109 67,253 174 97,254 224 139,255 255 191,230 245 152,171 221 164,102 194 165,50 136 189")
    if (n==10) return("158 1 66,213 62 79,244 109 67,253 174 97,254 224 139,230 245 152,171 221 164,102 194 165,50 136 189,94 79 162")
    if (n>=11) return("158 1 66,213 62 79,244 109 67,253 174 97,254 224 139,255 255 191,230 245 152,171 221 164,102 194 165,50 136 189,94 79 162")
}
`PAL'::P_ptol_qualitative(`RS' n)
{
    if (n<=1)  return("68 119 170")
    if (n==2)  return("68 119 170,204 102 119")
    if (n==3)  return("68 119 170,221 204 119,204 102 119")
    if (n==4)  return("68 119 170,17 119 51,221 204 119,204 102 119")
    if (n==5)  return("51 34 136,136 204 238,17 119 51,221 204 119,204 102 119")
    if (n==6)  return("51 34 136,136 204 238,17 119 51,221 204 119,204 102 119,170 68 153")
    if (n==7)  return("51 34 136,136 204 238,68 170 153,17 119 51,221 204 119,204 102 119,170 68 153")
    if (n==8)  return("51 34 136,136 204 238,68 170 153,17 119 51,153 153 51,221 204 119,204 102 119,170 68 153")
    if (n==9)  return("51 34 136,136 204 238,68 170 153,17 119 51,153 153 51,221 204 119,204 102 119,136 34 85,170 68 153")
    if (n==10) return("51 34 136,136 204 238,68 170 153,17 119 51,153 153 51,221 204 119,102 17 0,204 102 119,136 34 85,170 68 153")
    if (n==11) return("51 34 136,102 153 204,136 204 238,68 170 153,17 119 51,153 153 51,221 204 119,102 17 0,204 102 119,136 34 85,170 68 153")
    if (n>=12) return("51 34 136,102 153 204,136 204 238,68 170 153,17 119 51,153 153 51,221 204 119,102 17 0,204 102 119,170 68 102,136 34 85,170 68 153")
}
`PAL'::P_ptol_diverging(`RS' n)
{
    if (n<=3)  return("153 199 236,255 250 210,245 162 117")
    if (n==4)  return("0 139 206,180 221 247,249 189 126,208 50 50")
    if (n==5)  return("0 139 206,180 221 247,255 250 210,249 189 126,208 50 50")
    if (n==6)  return("58 137 201,153 199 236,230 245 254,255 227 170,245 162 117,210 77 62")
    if (n==7)  return("58 137 201,153 199 236,230 245 254,255 250 210,255 227 170,245 162 117,210 77 62")
    if (n==8)  return("58 137 201,119 183 229,180 221 247,230 245 254,255 227 170,249 189 126,237 135 94,210 77 62")
    if (n==9)  return("58 137 201,119 183 229,180 221 247,230 245 254,255 250 210,255 227 170,249 189 126,237 135 94,210 77 62")
    if (n==10) return("61 82 161,58 137 201,119 183 229,180 221 247,230 245 254,255 227 170,249 189 126,237 135 94,210 77 62,174 28 62")
    if (n>=11) return("61 82 161,58 137 201,119 183 229,180 221 247,230 245 254,255 250 210,255 227 170,249 189 126,237 135 94,210 77 62,174 28 62")
}
`PAL'::P_ptol_rainbow(`RS' n)
{
    if (n<=4)  return("64 64 150,87 163 173,222 167 58,217 33 32")
    if (n==5)  return("64 64 150,82 157 183,125 184 116,227 156 55,217 33 32")
    if (n==6)  return("64 64 150,73 140 194,99 173 153,190 188 72,230 139 51,217 33 32")
    if (n==7)  return("120 28 129,63 96 174,83 158 182,109 179 136,202 184 67,231 133 50,217 33 32")
    if (n==8)  return("120 28 129,63 86 167,75 145 192,95 170 159,145 189 97,216 175 61,231 124 48,217 33 32")
    if (n==9)  return("120 28 129,63 78 161,70 131 193,87 163 173,109 179 136,177 190 78,223 165 58,231 116 47,217 33 32")
    if (n==10) return("120 28 129,63 71 155,66 119 189,82 157 183,98 172 155,134 187 106,199 185 68,227 156 55,231 109 46,217 33 32")
    if (n==11) return("120 28 129,64 64 150,65 108 183,77 149 190,91 167 167,110 179 135,161 190 86,211 179 63,229 148 53,230 104 45,217 33 32")
    if (n>=12) return("120 28 129,65 59 147,64 101 177,72 139 194,85 161 177,99 173 153,127 185 114,181 189 76,217 173 60,230 142 52,230 100 44,217 33 32")
}
`PAL'::P_tableau()          return("#1f77b4,#ff7f0e,#2ca02c,#d62728,#9467bd,#8c564b,#e377c2,#7f7f7f,#bcbd22,#17becf,#aec7e8,#ffbb78,#98df8a,#ff9896,#c5b0d5,#c49c94,#f7b6d2,#c7c7c7,#dbdb8d,#9edae5")
`PAL'::P_lin_carcolor()     return("214 39 40,199 199 199,127 127 127,44 160 44,140 86 75,31 119 180"
                                 \ "Red,Silver,Black,Green,Brown,Blue")
`PAL'::P_lin_carcolor_a()   return("214 39 40,199 199 199,127 127 127,44 160 44,140 86 75,31 119 180"
                                 \ "Red,Silver,Black,Green,Brown,Blue")
`PAL'::P_lin_food()         return("199 199 199,31 119 180,140 86 75,152 223 138,219 219 141,196 156 148,214 39 40"
                                 \ "Sour_cream,Blue_cheese_dressing,Porterhouse_steak,Iceberg_lettuce,Onions_raw,Potato_baked,Tomato")
`PAL'::P_lin_food_a()       return("31 119 180,255 127 14,140 86 75,44 160 44,255 187 120,219 219 141,214 39 40"
                                 \ "Sour_cream,Blue_cheese_dressing,Porterhouse_steak,Iceberg_lettuce,Onions_raw,Potato_baked,Tomato")
`PAL'::P_lin_features()     return("214 39 40,31 119 180,174 119 232,44 160 44,152 223 138"
                                 \ "Speed,Reliability,Comfort,Safety,Efficiency")
`PAL'::P_lin_features_a()   return("214 39 40,31 119 180,140 86 75,255 127 14,44 160 44"
                                 \ "Speed,Reliability,Comfort,Safety,Efficiency")
`PAL'::P_lin_activities()   return("31 119 180,214 39 40,152 223 138,44 160 44,127 127 127"
                                 \ "Sleeping,Working,Leisure,Eating,Driving")
`PAL'::P_lin_activities_a() return("140 86 75,255 127 14,31 119 180,227 119 194,214 39 40"
                                 \ "Sleeping,Working,Leisure,Eating,Driving")
`PAL'::P_lin_fruits()       return("146 195 51,251 222 6,64 105 166,200 0 0,127 34 147,251 162 127,255 86 29"
                                 \ "Apple,Banana,Blueberry,Cherry,Grape,Peach,Tangerine")
`PAL'::P_lin_fruits_a()     return("44 160 44,188 189 34,31 119 180,214 39 40,148 103 189,255 187 120,255 127 14"
                                 \ "Apple,Banana,Blueberry,Cherry,Grape,Peach,Tangerine")
`PAL'::P_lin_vegetables()   return("255 141 61,157 212 105,245 208 64,104 59 101,239 197 143,139 129 57,255 26 34"
                                 \ "Carrot,Celery,Corn,Eggplant,Mushroom,Olive,Tomato")
`PAL'::P_lin_vegetables_a() return("255 127 14,44 160 44,188 189 34,148 103 189,140 86 75,152 223 138,214 39 40"
                                 \ "Carrot,Celery,Corn,Eggplant,Mushroom,Olive,Tomato")
`PAL'::P_lin_drinks()       return("119 67 6,254 0 0,151 37 63,1 106 171,1 159 76,254 115 20,104 105 169"
                                 \ "RootBeer,CocaCola,DrPepper,Pepsi,Sprite,Sunkist,WelchsGrape")
`PAL'::P_lin_drinks_a()     return("140 86 75,214 39 40,227 119 194,31 119 180,44 160 44,255 127 14,148 103 189"
                                 \ "RootBeer,CocaCola,DrPepper,Pepsi,Sprite,Sunkist,WelchsGrape")
`PAL'::P_lin_brands()       return("161 165 169,44 163 218,242 99 33,255 183 0,0 112 66,204 0 0,123 0 153"
                                 \ "Apple,ATT,HomeDepot,Kodak,Starbucks,Target,Yahoo")
`PAL'::P_lin_brands_a()     return("152 223 138,31 119 180,255 127 14,140 86 75,44 160 44,214 39 40,148 103 189"
                                 \ "Apple,ATT,HomeDepot,Kodak,Starbucks,Target,Yahoo")
`PAL'::P_spmap_blues(`RS' n0)
{
    `Int' n, i
    `SS'  c
    `RM'  C
    `RC'  p
    
    n = __clip(n0, 2, 99)
    p = ((1::n):-1) / (n-1)
    C = J(n,1,208), (.2 :+ .8*p), (1 :- .6*p)
    C = RGB1_to_RGB(HSV_to_RGB1(C))
    c = ""
    for (i=1; i<=n; i++) c = c + (i==1 ? "" : ",") + invtokens(strofreal(C[i,]))
    return(c)
}
`PAL'::P_spmap_greens(`RS' n0)
{
    `Int' n, i
    `SS'  c
    `RM'  C
    `RC'  p
    
    n = __clip(n0, 2, 99)
    p = ((1::n):-1) / (n-1)
    C = (122 :+ 20*p), (.2 :+ .8*p), (1 :- .7*p)
    C = RGB1_to_RGB(HSV_to_RGB1(C))
    c = ""
    for (i=1; i<=n; i++) c = c + (i==1 ? "" : ",") + invtokens(strofreal(C[i,]))
    return(c)
}
`PAL'::P_spmap_greys(`RS' n0)
{
    `Int' n, i
    `SS'  c
    `RM'  C
    
    n = __clip(n0, 2, 99)
    C = J(n,2,0), (.88 :- .88*((1::n):-1)/(n-1))
    C = RGB1_to_RGB(HSV_to_RGB1(C))
    c = ""
    for (i=1; i<=n; i++) c = c + (i==1 ? "" : ",") + invtokens(strofreal(C[i,]))
    return(c)
}
`PAL'::P_spmap_reds(`RS' n0)
{
    `Int' n, i
    `SS'  c
    `RM'  C
    `RC'  p
    
    n = __clip(n0, 2, 99)
    p = ((1::n):-1) / (n-1)
    C = (20 :- 20*p), (.2 :+ .8*p), (1 :- rowmax((J(n, 1, 0), 1.2*(p:-.5))))
    C = RGB1_to_RGB(HSV_to_RGB1(C))
    c = ""
    for (i=1; i<=n; i++) c = c + (i==1 ? "" : ",") + invtokens(strofreal(C[i,]))
    return(c)
}
`PAL'::P_spmap_rainbow(`RS' n0)
{
    `Int' n, i
    `SS'  c
    `RM'  C
    
    n = __clip(n0, 2, 99)
    C = (240 :- 240*((1::n):-1)/(n-1)), J(n,2,1)
    C = RGB1_to_RGB(HSV_to_RGB1(C))
    c = ""
    for (i=1; i<=n; i++) c = c + (i==1 ? "" : ",") + invtokens(strofreal(C[i,]))
    return(c)
}
`PAL'::P_spmap_heat(`RS' n)
{
    if (n<=2)  return("255 255 0,255 0 0")
    if (n==3)  return("255 255 0,255 128 0,255 0 0")
    if (n==4)  return("255 255 128,255 255 0,255 128 0,255 0 0")
    if (n==5)  return("255 255 128,255 255 0,255 170 0,255 85 0,255 0 0")
    if (n==6)  return("255 255 128,255 255 0,255 191 0,255 128 0,255 64 0,255 0 0")
    if (n==7)  return("255 255 128,255 255 0,255 204 0,255 153 0,255 102 0,255 51 0,255 0 0")
    if (n==8)  return("255 255 191,255 255 64,255 255 0,255 204 0,255 153 0,255 102 0,255 51 0,255 0 0")
    if (n==9)  return("255 255 191,255 255 64,255 255 0,255 213 0,255 170 0,255 128 0,255 85 0,255 42 0,255 0 0")
    if (n==10) return("255 255 191,255 255 64,255 255 0,255 219 0,255 182 0,255 146 0,255 109 0,255 73 0,255 36 0,255 0 0")
    if (n==11) return("255 255 191,255 255 64,255 255 0,255 223 0,255 191 0,255 159 0,255 128 0,255 96 0,255 64 0,255 32 0,255 0 0")
    if (n==12) return("255 255 213,255 255 128,255 255 42,255 255 0,255 223 0,255 191 0,255 159 0,255 128 0,255 96 0,255 64 0,255 32 0,255 0 0")
    if (n==13) return("255 255 213,255 255 128,255 255 42,255 255 0,255 227 0,255 198 0,255 170 0,255 142 0,255 113 0,255 85 0,255 57 0,255 28 0,255 0 0")
    if (n==14) return("255 255 213,255 255 128,255 255 42,255 255 0,255 229 0,255 204 0,255 178 0,255 153 0,255 128 0,255 102 0,255 77 0,255 51 0,255 26 0,255 0 0")
    if (n==15) return("255 255 213,255 255 128,255 255 42,255 255 0,255 232 0,255 209 0,255 185 0,255 162 0,255 139 0,255 116 0,255 93 0,255 70 0,255 46 0,255 23 0,255 0 0")
    if (n>=16) return("255 255 223,255 255 159,255 255 96,255 255 32,255 255 0,255 232 0,255 209 0,255 185 0,255 162 0,255 139 0,255 116 0,255 93 0,255 70 0,255 46 0,255 23 0,255 0 0")
}
`PAL'::P_spmap_terrain(`RS' n)
{
    if (n<=2)  return("0 166 0,242 242 242")
    if (n==3)  return("0 166 0,236 177 118,242 242 242")
    if (n==4)  return("0 166 0,230 230 0,236 177 118,242 242 242")
    if (n==5)  return("0 166 0,230 230 0,234 182 78,238 185 159,242 242 242")
    if (n==6)  return("0 166 0,99 198 0,230 230 0,234 182 78,238 185 159,242 242 242")
    if (n==7)  return("0 166 0,99 198 0,230 230 0,233 189 58,236 177 118,239 194 179,242 242 242")
    if (n==8)  return("0 166 0,62 187 0,139 208 0,230 230 0,233 189 58,236 177 118,239 194 179,242 242 242")
    if (n==9)  return("0 166 0,62 187 0,139 208 0,230 230 0,232 195 46,235 178 94,237 180 142,240 201 192,242 242 242")
    if (n==10) return("0 166 0,45 182 0,99 198 0,160 214 0,230 230 0,232 195 46,235 178 94,237 180 142,240 201 192,242 242 242")
    if (n==11) return("0 166 0,45 182 0,99 198 0,160 214 0,230 230 0,232 199 39,234 182 78,236 177 118,238 185 159,240 207 200,242 242 242")
    if (n==12) return("0 166 0,36 179 0,76 191 0,122 204 0,173 217 0,230 230 0,232 199 39,234 182 78,236 177 118,238 185 159,240 207 200,242 242 242")
    if (n==13) return("0 166 0,36 179 0,76 191 0,122 204 0,173 217 0,230 230 0,231 203 33,233 186 67,235 177 101,237 179 135,239 190 170,240 211 206,242 242 242")
    if (n==14) return("0 166 0,29 176 0,62 187 0,99 198 0,139 208 0,182 219 0,230 230 0,231 203 33,233 186 67,235 177 101,237 179 135,239 190 170,240 211 206,242 242 242")
    if (n==15) return("0 166 0,29 176 0,62 187 0,99 198 0,139 208 0,182 219 0,230 230 0,231 206 29,233 189 58,234 179 88,236 177 118,237 182 148,239 194 179,241 214 211,242 242 242")
    if (n>=16) return("0 166 0,25 175 0,53 184 0,83 193 0,116 202 0,151 211 0,189 220 0,230 230 0,231 206 29,233 189 58,234 179 88,236 177 118,237 182 148,239 194 179,241 214 211,242 242 242")
}
`PAL'::P_spmap_topological(`RS' n)
{
    if (n<=2)  return("76 0 255,0 229 255")
    if (n==3)  return("76 0 255,0 255 77,255 255 0")
    if (n==4)  return("76 0 255,0 229 255,0 255 77,255 255 0")
    if (n==5)  return("76 0 255,0 76 255,0 229 255,0 255 77,255 255 0")
    if (n==6)  return("76 0 255,0 229 255,0 255 77,230 255 0,255 255 0,255 224 178")
    if (n==7)  return("76 0 255,0 76 255,0 229 255,0 255 77,230 255 0,255 255 0,255 224 178")
    if (n==8)  return("76 0 255,0 25 255,0 128 255,0 229 255,0 255 77,230 255 0,255 255 0,255 224 178")
    if (n==9)  return("76 0 255,0 76 255,0 229 255,0 255 77,77 255 0,230 255 0,255 255 0,255 222 89,255 224 178")
    if (n==10) return("76 0 255,0 25 255,0 128 255,0 229 255,0 255 77,77 255 0,230 255 0,255 255 0,255 222 89,255 224 178")
    if (n==11) return("76 0 255,0 0 255,0 76 255,0 153 255,0 229 255,0 255 77,77 255 0,230 255 0,255 255 0,255 222 89,255 224 178")
    if (n==12) return("76 0 255,0 25 255,0 128 255,0 229 255,0 255 77,26 255 0,128 255 0,230 255 0,255 255 0,255 229 59,255 219 119,255 224 178")
    if (n==13) return("76 0 255,0 0 255,0 76 255,0 153 255,0 229 255,0 255 77,26 255 0,128 255 0,230 255 0,255 255 0,255 229 59,255 219 119,255 224 178")
    if (n==14) return("76 0 255,15 0 255,0 46 255,0 107 255,0 168 255,0 229 255,0 255 77,26 255 0,128 255 0,230 255 0,255 255 0,255 229 59,255 219 119,255 224 178")
    if (n==15) return("76 0 255,0 0 255,0 76 255,0 153 255,0 229 255,0 255 77,0 255 0,77 255 0,153 255 0,230 255 0,255 255 0,255 234 45,255 222 89,255 219 134,255 224 178")
    if (n>=16) return("76 0 255,15 0 255,0 46 255,0 107 255,0 168 255,0 229 255,0 255 77,0 255 0,77 255 0,153 255 0,230 255 0,255 255 0,255 234 45,255 222 89,255 219 134,255 224 178")
}
`PAL'::P_sfso_blue()        return("#1c3259,#374a83,#6473aa,#8497cf,#afbce2,#d8def2,#e8eaf7"
                                 \ ",,,BFS-Blau,,,BFS-Blau 20%")
`PAL'::P_sfso_brown()       return("#6b0616,#a1534e,#b67d6c,#cca58f,#ddc3a8,#eee3cd")
`PAL'::P_sfso_orange()      return("#92490d,#ce6725,#d68c25,#e2b224,#eccf76,#f6e7be")
`PAL'::P_sfso_red()         return("#6d0724,#a61346,#c62a4f,#d17477,#dea49f,#efd6d1")
`PAL'::P_sfso_pink()        return("#7c0051,#a4006f,#c0007c,#cc669d,#da9dbf,#efd7e5")
`PAL'::P_sfso_purple()      return("#5e0059,#890883,#a23392,#bf64a6,#d79dc5,#efd7e8")
`PAL'::P_sfso_violet()      return("#3a0054,#682b86,#8c58a3,#a886bc,#c5b0d5,#e1d7eb")
`PAL'::P_sfso_ltblue()      return("#076e8d,#1b9dc9,#76b8da,#abd0e7,#c8e0f2,#edf5fd")
`PAL'::P_sfso_turquoise()   return("#005046,#107a6d,#3aa59a,#95c6c3,#cbe1df,#e9f2f5")
`PAL'::P_sfso_green()       return("#3b6519,#68a239,#95c15b,#b3d17f,#d3e3af,#ecf2d1")
`PAL'::P_sfso_olive()       return("#6f6f02,#a3a20a,#c5c00c,#e3df86,#eeecbc,#fefde6")
`PAL'::P_sfso_black()       return("#3f3f3e,#838382,#b2b3b3,#d4d5d5,#e6e6e7,#f7f7f7")
`PAL'::P_sfso_parties()     return("#6268AF,#f39f5e,#ea546f,#547d34,#cbd401,#ffff00,#26b300,#792a8f,#9fabd9,#f0da9d,#bebebe"
                                 \ `"FDP,CVP,SP,SVP,GLP,BDP,Grüne,"small leftwing parties (PdA, Sol.)","small middle parties (EVP, CSP)","small rightwing parties (EDu, Lega)",other parties"')
`PAL'::P_sfso_languages()   return("#c73e31,#4570ba,#4ca767,#ecce42,#7f5fa9"
                                 \ "German,French,Italian,RhaetoRomanic,English")
`PAL'::P_sfso_votes()       return("#6d2a83,#6d2a83*.8,#6d2a83*.6,#6d2a83*.4,#6d2a83*.2,#45974d*.2,#45974d*.4,#45974d*.6,#45974d*.8,#45974d"
                                 \ "No,,,,,,,,,Yes")

end

* {smcl}
* {marker matplotlib}{bf:Matplotlib color maps} {hline}
* Colors from Matplotlib (matplotlib.org), a Python 2D plotting library 
* Sources (retrieved on 14sep2018):
*   {browse "https://github.com/matplotlib/matplotlib/blob/master/lib/matplotlib/_cm.py"}
*   {browse "https://github.com/matplotlib/matplotlib/blob/master/lib/matplotlib/_cm_listed.py"}
* Copyright (c) 2012- Matplotlib Development Team; All Rights Reserved
* {asis}

mata:

void `MAIN'::matplotlib(| `SS' pal0, `RS' n0, `RV' range)
{
    `SS'   pal
    `Bool' ispu
    `Int'  n
    `RM'   R, G, B, RGB1
    
    pclass = "sequential"
    ispu = `FALSE'
    n = (n0<. ? (n0<0 ? 0 : n0) : 15)
    pal = strlower(pal0)
    RGB1 = J(0, 3, .)
    if      (smatch(pal, "viridis"))  {; viridis(RGB1); ispu = `TRUE'; }
    else if (smatch(pal, "magma"))    {; magma(RGB1)  ; ispu = `TRUE'; }
    else if (smatch(pal, "inferno"))  {; inferno(RGB1); ispu = `TRUE'; }
    else if (smatch(pal, "plasma"))   {; plasma(RGB1) ; ispu = `TRUE'; }
    else if (smatch(pal, "cividis"))  {; cividis(RGB1); ispu = `TRUE'; }
    else if (smatch(pal, "twilight")) { 
        twilight(RGB1) 
        ispu = `TRUE'
        pclass = "diverging"
    }
    else if (smatch(pal, "twilight shifted")) { 
        twilight(RGB1)
        RGB1 = RGB1[|rows(RGB1)/2+1,1 \ .,.|] \ RGB1[|1,1 \ rows(RGB1)/2,.|]
        RGB1 = RGB1[rows(RGB1)::1,]
        ispu = `TRUE'
        pclass = "diverging"
    }
    else if (smatch(pal, "autumn")) {
        R = (0, 1, 1) \ (1, 1, 1)
        G = (0, 0, 0) \ (1, 1, 1)
        B = (0, 0, 0) \ (1, 0, 0)
    }
    else if (smatch(pal, "spring")) {
        R = (0, 1, 1) \ (1, 1, 1)
        G = (0, 0, 0) \ (1, 1, 1)
        B = (0, 1, 1) \ (1, 0, 0)
    }
    else if (smatch(pal, "summer")) {
        R = (0,  0,  0) \ (1,  1,  1)
        G = (0, .5, .5) \ (1,  1,  1)
        B = (0, .4, .4) \ (1, .4, .4)
    }
    else if (smatch(pal, "winter")) {
        R = (0, 0, 0) \ (1,  0,  0)
        G = (0, 0, 0) \ (1,  1,  1)
        B = (0, 1, 1) \ (1, .5, .5)
    }
    else if (smatch(pal, "bone")) {
        R = (0, 0, 0) \ (.746032, .652778, .652778) \ (1, 1, 1)
        G = (0, 0, 0) \ (.365079, .319444, .319444) \ (.746032, .777778, .777778) \ (1, 1, 1)
        B = (0, 0, 0) \ (.365079, .444444, .444444) \ (1, 1, 1)
    }
    else if (smatch(pal, "cool")) {
        R = (0, 0, 0) \ (1, 1, 1)
        G = (0, 1, 1) \ (1, 0, 0)
        B = (0, 1, 1) \ (1, 1, 1)
    }
    else if (smatch(pal, "copper")) {
        R = (0, 0, 0) \ (.809524, 1, 1) \ (1, 1, 1)
        G = (0, 0, 0) \ (1, .7812, .7812)
        B = (0, 0, 0) \ (1, .4975, .4975)
    }
    else if (smatch(pal, "coolwarm")) {
        pclass = "diverging"
        // Matplotlib source note:
        // # This bipolar color map was generated from CoolWarmFloat33.csv of
        // # "Diverging Color Maps for Scientific Visualization" by Kenneth Moreland.
        // # <http://www.kennethmoreland.com/color-maps/>
        R = (0,      .2298057,   .2298057) \
            (.03125, .26623388,  .26623388) \
            (.0625,  .30386891,  .30386891) \
            (.09375, .342804478, .342804478) \
            (.125,   .38301334,  .38301334) \
            (.15625, .424369608, .424369608) \
            (.1875,  .46666708,  .46666708) \
            (.21875, .509635204, .509635204) \
            (.25,    .552953156, .552953156) \
            (.28125, .596262162, .596262162) \
            (.3125,  .639176211, .639176211) \
            (.34375, .681291281, .681291281) \
            (.375,   .722193294, .722193294) \
            (.40625, .761464949, .761464949) \
            (.4375,  .798691636, .798691636) \
            (.46875, .833466556, .833466556) \
            (.5,     .865395197, .865395197) \
            (.53125, .897787179, .897787179) \
            (.5625,  .924127593, .924127593) \
            (.59375, .944468518, .944468518) \
            (.625,   .958852946, .958852946) \
            (.65625, .96732803,  .96732803) \
            (.6875,  .969954137, .969954137) \
            (.71875, .966811177, .966811177) \
            (.75,    .958003065, .958003065) \
            (.78125, .943660866, .943660866) \
            (.8125,  .923944917, .923944917) \
            (.84375, .89904617,  .89904617) \
            (.875,   .869186849, .869186849) \
            (.90625, .834620542, .834620542) \
            (.9375,  .795631745, .795631745) \
            (.96875, .752534934, .752534934) \
            (1,      .705673158, .705673158)
        G = (0,      .298717966, .298717966) \
            (.03125, .353094838, .353094838) \
            (.0625,  .406535296, .406535296) \
            (.09375, .458757618, .458757618) \
            (.125,   .50941904,  .50941904) \
            (.15625, .558148092, .558148092) \
            (.1875,  .604562568, .604562568) \
            (.21875, .648280772, .648280772) \
            (.25,    .688929332, .688929332) \
            (.28125, .726149107, .726149107) \
            (.3125,  .759599947, .759599947) \
            (.34375, .788964712, .788964712) \
            (.375,   .813952739, .813952739) \
            (.40625, .834302879, .834302879) \
            (.4375,  .849786142, .849786142) \
            (.46875, .860207984, .860207984) \
            (.5,     .86541021,  .86541021) \
            (.53125, .848937047, .848937047) \
            (.5625,  .827384882, .827384882) \
            (.59375, .800927443, .800927443) \
            (.625,   .769767752, .769767752) \
            (.65625, .734132809, .734132809) \
            (.6875,  .694266682, .694266682) \
            (.71875, .650421156, .650421156) \
            (.75,    .602842431, .602842431) \
            (.78125, .551750968, .551750968) \
            (.8125,  .49730856,  .49730856) \
            (.84375, .439559467, .439559467) \
            (.875,   .378313092, .378313092) \
            (.90625, .312874446, .312874446) \
            (.9375,  .24128379,  .24128379) \
            (.96875, .157246067, .157246067) \
            (1,      .01555616,  .01555616)
        B = (0,      .753683153, .753683153) \
            (.03125, .801466763, .801466763) \
            (.0625,  .84495867,  .84495867) \
            (.09375, .883725899, .883725899) \
            (.125,   .917387822, .917387822) \
            (.15625, .945619588, .945619588) \
            (.1875,  .968154911, .968154911) \
            (.21875, .98478814,  .98478814) \
            (.25,    .995375608, .995375608) \
            (.28125, .999836203, .999836203) \
            (.3125,  .998151185, .998151185) \
            (.34375, .990363227, .990363227) \
            (.375,   .976574709, .976574709) \
            (.40625, .956945269, .956945269) \
            (.4375,  .931688648, .931688648) \
            (.46875, .901068838, .901068838) \
            (.5,     .865395561, .865395561) \
            (.53125, .820880546, .820880546) \
            (.5625,  .774508472, .774508472) \
            (.59375, .726736146, .726736146) \
            (.625,   .678007945, .678007945) \
            (.65625, .628751763, .628751763) \
            (.6875,  .579375448, .579375448) \
            (.71875, .530263762, .530263762) \
            (.75,    .481775914, .481775914) \
            (.78125, .434243684, .434243684) \
            (.8125,  .387970225, .387970225) \
            (.84375, .343229596, .343229596) \
            (.875,   .300267182, .300267182) \
            (.90625, .259301199, .259301199) \
            (.9375,  .220525627, .220525627) \
            (.96875, .184115123, .184115123) \
            (1,      .150232812, .150232812)
    }
    else if (smatch(pal, "jet")) {
        R = (0,  0,  0) \ (.35, 0, 0) \ (.66, 1, 1) \ (.89, 1, 1) \ (1, .5, .5)
        G = (0,  0,  0) \ (.125, 0, 0) \ (.375, 1, 1) \ (.64, 1, 1) \ (.91, 0, 0) \ (1, 0, 0)
        B = (0, .5, .5) \ (.11, 1, 1) \ (.34, 1, 1) \ (.65, 0, 0) \ (1, 0, 0)
    }
    else if (smatch(pal, "hot")) {
        R = (0, .0416, .0416) \ (.365079, 1, 1) \ (1, 1, 1)
        G = (0, 0, 0) \ (.365079, 0, 0) \ (.746032, 1, 1) \ (1, 1, 1)
        B = (0, 0, 0) \ (.746032, 0, 0) \ (1, 1, 1)
    }
    else {
        display("{err}colormap '" + pal0 + "' not found")
        exit(3499)
    }
    pname = pal
    if (ispu) set(colipolate(RGB1, n, range), "RGB1")       // viridis and friends
    else      set(matplotlib_ip(R, G, B, n, range), "RGB1") // other palettes
}

`RM' `MAIN'::matplotlib_ip(`RM' R, `RM' G, `RM' B, `RS' n, | `RV' range0)
{                         // (consistency of input is not checked)
    `RV' range
    
    assert_cols(R, 3); assert_cols(G, 3); assert_cols(B, 3)
    range = clip(_ipolate_setrange(range0), 0, 1) // restrict range to [0,1]
    return((_matplotlib_ip(R, n, range[1], range[2]),
            _matplotlib_ip(G, n, range[1], range[2]),
            _matplotlib_ip(B, n, range[1], range[2])))
}

`RC' `MAIN'::_matplotlib_ip(`RM' xy, `RS' n, `RS' from, `RS' to)
{
    `Int' i, j, reverse
    `RC'  x, y

    if (n==0) return(J(0, 1, .))
    reverse = 0
    if (from>to) {
        reverse = 1
        x = rangen(to, from, n)
    }
    else x = rangen(from, to, n)
    y = J(n, 1, .)
    j = 1
    for (i=1; i<=n; i++) {
        while (xy[j+1,1]<x[i]) j++
        if (x[i]==xy[j,1]) y[i] = xy[j,3]
        else y[i] = xy[j,3] + (xy[j+1,2] - xy[j,3]) * (x[i] - xy[j,1]) / 
                                                      (xy[j+1,1] - xy[j,1])
    }
    if (reverse) return(y[n::1])
    return(y)
}

void `MAIN'::magma(`RM' RGB1)
{
    `Int' i
    
    i = 0
    RGB1 = J(256, 3 ,.)
    RGB1[++i,] = (.001462, .000466, .013866)
    RGB1[++i,] = (.002258, .001295, .018331)
    RGB1[++i,] = (.003279, .002305, .023708)
    RGB1[++i,] = (.004512, .003490, .029965)
    RGB1[++i,] = (.005950, .004843, .037130)
    RGB1[++i,] = (.007588, .006356, .044973)
    RGB1[++i,] = (.009426, .008022, .052844)
    RGB1[++i,] = (.011465, .009828, .060750)
    RGB1[++i,] = (.013708, .011771, .068667)
    RGB1[++i,] = (.016156, .013840, .076603)
    RGB1[++i,] = (.018815, .016026, .084584)
    RGB1[++i,] = (.021692, .018320, .092610)
    RGB1[++i,] = (.024792, .020715, .100676)
    RGB1[++i,] = (.028123, .023201, .108787)
    RGB1[++i,] = (.031696, .025765, .116965)
    RGB1[++i,] = (.035520, .028397, .125209)
    RGB1[++i,] = (.039608, .031090, .133515)
    RGB1[++i,] = (.043830, .033830, .141886)
    RGB1[++i,] = (.048062, .036607, .150327)
    RGB1[++i,] = (.052320, .039407, .158841)
    RGB1[++i,] = (.056615, .042160, .167446)
    RGB1[++i,] = (.060949, .044794, .176129)
    RGB1[++i,] = (.065330, .047318, .184892)
    RGB1[++i,] = (.069764, .049726, .193735)
    RGB1[++i,] = (.074257, .052017, .202660)
    RGB1[++i,] = (.078815, .054184, .211667)
    RGB1[++i,] = (.083446, .056225, .220755)
    RGB1[++i,] = (.088155, .058133, .229922)
    RGB1[++i,] = (.092949, .059904, .239164)
    RGB1[++i,] = (.097833, .061531, .248477)
    RGB1[++i,] = (.102815, .063010, .257854)
    RGB1[++i,] = (.107899, .064335, .267289)
    RGB1[++i,] = (.113094, .065492, .276784)
    RGB1[++i,] = (.118405, .066479, .286321)
    RGB1[++i,] = (.123833, .067295, .295879)
    RGB1[++i,] = (.129380, .067935, .305443)
    RGB1[++i,] = (.135053, .068391, .315000)
    RGB1[++i,] = (.140858, .068654, .324538)
    RGB1[++i,] = (.146785, .068738, .334011)
    RGB1[++i,] = (.152839, .068637, .343404)
    RGB1[++i,] = (.159018, .068354, .352688)
    RGB1[++i,] = (.165308, .067911, .361816)
    RGB1[++i,] = (.171713, .067305, .370771)
    RGB1[++i,] = (.178212, .066576, .379497)
    RGB1[++i,] = (.184801, .065732, .387973)
    RGB1[++i,] = (.191460, .064818, .396152)
    RGB1[++i,] = (.198177, .063862, .404009)
    RGB1[++i,] = (.204935, .062907, .411514)
    RGB1[++i,] = (.211718, .061992, .418647)
    RGB1[++i,] = (.218512, .061158, .425392)
    RGB1[++i,] = (.225302, .060445, .431742)
    RGB1[++i,] = (.232077, .059889, .437695)
    RGB1[++i,] = (.238826, .059517, .443256)
    RGB1[++i,] = (.245543, .059352, .448436)
    RGB1[++i,] = (.252220, .059415, .453248)
    RGB1[++i,] = (.258857, .059706, .457710)
    RGB1[++i,] = (.265447, .060237, .461840)
    RGB1[++i,] = (.271994, .060994, .465660)
    RGB1[++i,] = (.278493, .061978, .469190)
    RGB1[++i,] = (.284951, .063168, .472451)
    RGB1[++i,] = (.291366, .064553, .475462)
    RGB1[++i,] = (.297740, .066117, .478243)
    RGB1[++i,] = (.304081, .067835, .480812)
    RGB1[++i,] = (.310382, .069702, .483186)
    RGB1[++i,] = (.316654, .071690, .485380)
    RGB1[++i,] = (.322899, .073782, .487408)
    RGB1[++i,] = (.329114, .075972, .489287)
    RGB1[++i,] = (.335308, .078236, .491024)
    RGB1[++i,] = (.341482, .080564, .492631)
    RGB1[++i,] = (.347636, .082946, .494121)
    RGB1[++i,] = (.353773, .085373, .495501)
    RGB1[++i,] = (.359898, .087831, .496778)
    RGB1[++i,] = (.366012, .090314, .497960)
    RGB1[++i,] = (.372116, .092816, .499053)
    RGB1[++i,] = (.378211, .095332, .500067)
    RGB1[++i,] = (.384299, .097855, .501002)
    RGB1[++i,] = (.390384, .100379, .501864)
    RGB1[++i,] = (.396467, .102902, .502658)
    RGB1[++i,] = (.402548, .105420, .503386)
    RGB1[++i,] = (.408629, .107930, .504052)
    RGB1[++i,] = (.414709, .110431, .504662)
    RGB1[++i,] = (.420791, .112920, .505215)
    RGB1[++i,] = (.426877, .115395, .505714)
    RGB1[++i,] = (.432967, .117855, .506160)
    RGB1[++i,] = (.439062, .120298, .506555)
    RGB1[++i,] = (.445163, .122724, .506901)
    RGB1[++i,] = (.451271, .125132, .507198)
    RGB1[++i,] = (.457386, .127522, .507448)
    RGB1[++i,] = (.463508, .129893, .507652)
    RGB1[++i,] = (.469640, .132245, .507809)
    RGB1[++i,] = (.475780, .134577, .507921)
    RGB1[++i,] = (.481929, .136891, .507989)
    RGB1[++i,] = (.488088, .139186, .508011)
    RGB1[++i,] = (.494258, .141462, .507988)
    RGB1[++i,] = (.500438, .143719, .507920)
    RGB1[++i,] = (.506629, .145958, .507806)
    RGB1[++i,] = (.512831, .148179, .507648)
    RGB1[++i,] = (.519045, .150383, .507443)
    RGB1[++i,] = (.525270, .152569, .507192)
    RGB1[++i,] = (.531507, .154739, .506895)
    RGB1[++i,] = (.537755, .156894, .506551)
    RGB1[++i,] = (.544015, .159033, .506159)
    RGB1[++i,] = (.550287, .161158, .505719)
    RGB1[++i,] = (.556571, .163269, .505230)
    RGB1[++i,] = (.562866, .165368, .504692)
    RGB1[++i,] = (.569172, .167454, .504105)
    RGB1[++i,] = (.575490, .169530, .503466)
    RGB1[++i,] = (.581819, .171596, .502777)
    RGB1[++i,] = (.588158, .173652, .502035)
    RGB1[++i,] = (.594508, .175701, .501241)
    RGB1[++i,] = (.600868, .177743, .500394)
    RGB1[++i,] = (.607238, .179779, .499492)
    RGB1[++i,] = (.613617, .181811, .498536)
    RGB1[++i,] = (.620005, .183840, .497524)
    RGB1[++i,] = (.626401, .185867, .496456)
    RGB1[++i,] = (.632805, .187893, .495332)
    RGB1[++i,] = (.639216, .189921, .494150)
    RGB1[++i,] = (.645633, .191952, .492910)
    RGB1[++i,] = (.652056, .193986, .491611)
    RGB1[++i,] = (.658483, .196027, .490253)
    RGB1[++i,] = (.664915, .198075, .488836)
    RGB1[++i,] = (.671349, .200133, .487358)
    RGB1[++i,] = (.677786, .202203, .485819)
    RGB1[++i,] = (.684224, .204286, .484219)
    RGB1[++i,] = (.690661, .206384, .482558)
    RGB1[++i,] = (.697098, .208501, .480835)
    RGB1[++i,] = (.703532, .210638, .479049)
    RGB1[++i,] = (.709962, .212797, .477201)
    RGB1[++i,] = (.716387, .214982, .475290)
    RGB1[++i,] = (.722805, .217194, .473316)
    RGB1[++i,] = (.729216, .219437, .471279)
    RGB1[++i,] = (.735616, .221713, .469180)
    RGB1[++i,] = (.742004, .224025, .467018)
    RGB1[++i,] = (.748378, .226377, .464794)
    RGB1[++i,] = (.754737, .228772, .462509)
    RGB1[++i,] = (.761077, .231214, .460162)
    RGB1[++i,] = (.767398, .233705, .457755)
    RGB1[++i,] = (.773695, .236249, .455289)
    RGB1[++i,] = (.779968, .238851, .452765)
    RGB1[++i,] = (.786212, .241514, .450184)
    RGB1[++i,] = (.792427, .244242, .447543)
    RGB1[++i,] = (.798608, .247040, .444848)
    RGB1[++i,] = (.804752, .249911, .442102)
    RGB1[++i,] = (.810855, .252861, .439305)
    RGB1[++i,] = (.816914, .255895, .436461)
    RGB1[++i,] = (.822926, .259016, .433573)
    RGB1[++i,] = (.828886, .262229, .430644)
    RGB1[++i,] = (.834791, .265540, .427671)
    RGB1[++i,] = (.840636, .268953, .424666)
    RGB1[++i,] = (.846416, .272473, .421631)
    RGB1[++i,] = (.852126, .276106, .418573)
    RGB1[++i,] = (.857763, .279857, .415496)
    RGB1[++i,] = (.863320, .283729, .412403)
    RGB1[++i,] = (.868793, .287728, .409303)
    RGB1[++i,] = (.874176, .291859, .406205)
    RGB1[++i,] = (.879464, .296125, .403118)
    RGB1[++i,] = (.884651, .300530, .400047)
    RGB1[++i,] = (.889731, .305079, .397002)
    RGB1[++i,] = (.894700, .309773, .393995)
    RGB1[++i,] = (.899552, .314616, .391037)
    RGB1[++i,] = (.904281, .319610, .388137)
    RGB1[++i,] = (.908884, .324755, .385308)
    RGB1[++i,] = (.913354, .330052, .382563)
    RGB1[++i,] = (.917689, .335500, .379915)
    RGB1[++i,] = (.921884, .341098, .377376)
    RGB1[++i,] = (.925937, .346844, .374959)
    RGB1[++i,] = (.929845, .352734, .372677)
    RGB1[++i,] = (.933606, .358764, .370541)
    RGB1[++i,] = (.937221, .364929, .368567)
    RGB1[++i,] = (.940687, .371224, .366762)
    RGB1[++i,] = (.944006, .377643, .365136)
    RGB1[++i,] = (.947180, .384178, .363701)
    RGB1[++i,] = (.950210, .390820, .362468)
    RGB1[++i,] = (.953099, .397563, .361438)
    RGB1[++i,] = (.955849, .404400, .360619)
    RGB1[++i,] = (.958464, .411324, .360014)
    RGB1[++i,] = (.960949, .418323, .359630)
    RGB1[++i,] = (.963310, .425390, .359469)
    RGB1[++i,] = (.965549, .432519, .359529)
    RGB1[++i,] = (.967671, .439703, .359810)
    RGB1[++i,] = (.969680, .446936, .360311)
    RGB1[++i,] = (.971582, .454210, .361030)
    RGB1[++i,] = (.973381, .461520, .361965)
    RGB1[++i,] = (.975082, .468861, .363111)
    RGB1[++i,] = (.976690, .476226, .364466)
    RGB1[++i,] = (.978210, .483612, .366025)
    RGB1[++i,] = (.979645, .491014, .367783)
    RGB1[++i,] = (.981000, .498428, .369734)
    RGB1[++i,] = (.982279, .505851, .371874)
    RGB1[++i,] = (.983485, .513280, .374198)
    RGB1[++i,] = (.984622, .520713, .376698)
    RGB1[++i,] = (.985693, .528148, .379371)
    RGB1[++i,] = (.986700, .535582, .382210)
    RGB1[++i,] = (.987646, .543015, .385210)
    RGB1[++i,] = (.988533, .550446, .388365)
    RGB1[++i,] = (.989363, .557873, .391671)
    RGB1[++i,] = (.990138, .565296, .395122)
    RGB1[++i,] = (.990871, .572706, .398714)
    RGB1[++i,] = (.991558, .580107, .402441)
    RGB1[++i,] = (.992196, .587502, .406299)
    RGB1[++i,] = (.992785, .594891, .410283)
    RGB1[++i,] = (.993326, .602275, .414390)
    RGB1[++i,] = (.993834, .609644, .418613)
    RGB1[++i,] = (.994309, .616999, .422950)
    RGB1[++i,] = (.994738, .624350, .427397)
    RGB1[++i,] = (.995122, .631696, .431951)
    RGB1[++i,] = (.995480, .639027, .436607)
    RGB1[++i,] = (.995810, .646344, .441361)
    RGB1[++i,] = (.996096, .653659, .446213)
    RGB1[++i,] = (.996341, .660969, .451160)
    RGB1[++i,] = (.996580, .668256, .456192)
    RGB1[++i,] = (.996775, .675541, .461314)
    RGB1[++i,] = (.996925, .682828, .466526)
    RGB1[++i,] = (.997077, .690088, .471811)
    RGB1[++i,] = (.997186, .697349, .477182)
    RGB1[++i,] = (.997254, .704611, .482635)
    RGB1[++i,] = (.997325, .711848, .488154)
    RGB1[++i,] = (.997351, .719089, .493755)
    RGB1[++i,] = (.997351, .726324, .499428)
    RGB1[++i,] = (.997341, .733545, .505167)
    RGB1[++i,] = (.997285, .740772, .510983)
    RGB1[++i,] = (.997228, .747981, .516859)
    RGB1[++i,] = (.997138, .755190, .522806)
    RGB1[++i,] = (.997019, .762398, .528821)
    RGB1[++i,] = (.996898, .769591, .534892)
    RGB1[++i,] = (.996727, .776795, .541039)
    RGB1[++i,] = (.996571, .783977, .547233)
    RGB1[++i,] = (.996369, .791167, .553499)
    RGB1[++i,] = (.996162, .798348, .559820)
    RGB1[++i,] = (.995932, .805527, .566202)
    RGB1[++i,] = (.995680, .812706, .572645)
    RGB1[++i,] = (.995424, .819875, .579140)
    RGB1[++i,] = (.995131, .827052, .585701)
    RGB1[++i,] = (.994851, .834213, .592307)
    RGB1[++i,] = (.994524, .841387, .598983)
    RGB1[++i,] = (.994222, .848540, .605696)
    RGB1[++i,] = (.993866, .855711, .612482)
    RGB1[++i,] = (.993545, .862859, .619299)
    RGB1[++i,] = (.993170, .870024, .626189)
    RGB1[++i,] = (.992831, .877168, .633109)
    RGB1[++i,] = (.992440, .884330, .640099)
    RGB1[++i,] = (.992089, .891470, .647116)
    RGB1[++i,] = (.991688, .898627, .654202)
    RGB1[++i,] = (.991332, .905763, .661309)
    RGB1[++i,] = (.990930, .912915, .668481)
    RGB1[++i,] = (.990570, .920049, .675675)
    RGB1[++i,] = (.990175, .927196, .682926)
    RGB1[++i,] = (.989815, .934329, .690198)
    RGB1[++i,] = (.989434, .941470, .697519)
    RGB1[++i,] = (.989077, .948604, .704863)
    RGB1[++i,] = (.988717, .955742, .712242)
    RGB1[++i,] = (.988367, .962878, .719649)
    RGB1[++i,] = (.988033, .970012, .727077)
    RGB1[++i,] = (.987691, .977154, .734536)
    RGB1[++i,] = (.987387, .984288, .742002)
    RGB1[++i,] = (.987053, .991438, .749504)
}

void `MAIN'::inferno(`RM' RGB1)
{
    `Int' i
    
    i = 0
    RGB1 = J(256, 3 ,.)
    RGB1[++i,] = (.001462, .000466, .013866)
    RGB1[++i,] = (.002267, .001270, .018570)
    RGB1[++i,] = (.003299, .002249, .024239)
    RGB1[++i,] = (.004547, .003392, .030909)
    RGB1[++i,] = (.006006, .004692, .038558)
    RGB1[++i,] = (.007676, .006136, .046836)
    RGB1[++i,] = (.009561, .007713, .055143)
    RGB1[++i,] = (.011663, .009417, .063460)
    RGB1[++i,] = (.013995, .011225, .071862)
    RGB1[++i,] = (.016561, .013136, .080282)
    RGB1[++i,] = (.019373, .015133, .088767)
    RGB1[++i,] = (.022447, .017199, .097327)
    RGB1[++i,] = (.025793, .019331, .105930)
    RGB1[++i,] = (.029432, .021503, .114621)
    RGB1[++i,] = (.033385, .023702, .123397)
    RGB1[++i,] = (.037668, .025921, .132232)
    RGB1[++i,] = (.042253, .028139, .141141)
    RGB1[++i,] = (.046915, .030324, .150164)
    RGB1[++i,] = (.051644, .032474, .159254)
    RGB1[++i,] = (.056449, .034569, .168414)
    RGB1[++i,] = (.061340, .036590, .177642)
    RGB1[++i,] = (.066331, .038504, .186962)
    RGB1[++i,] = (.071429, .040294, .196354)
    RGB1[++i,] = (.076637, .041905, .205799)
    RGB1[++i,] = (.081962, .043328, .215289)
    RGB1[++i,] = (.087411, .044556, .224813)
    RGB1[++i,] = (.092990, .045583, .234358)
    RGB1[++i,] = (.098702, .046402, .243904)
    RGB1[++i,] = (.104551, .047008, .253430)
    RGB1[++i,] = (.110536, .047399, .262912)
    RGB1[++i,] = (.116656, .047574, .272321)
    RGB1[++i,] = (.122908, .047536, .281624)
    RGB1[++i,] = (.129285, .047293, .290788)
    RGB1[++i,] = (.135778, .046856, .299776)
    RGB1[++i,] = (.142378, .046242, .308553)
    RGB1[++i,] = (.149073, .045468, .317085)
    RGB1[++i,] = (.155850, .044559, .325338)
    RGB1[++i,] = (.162689, .043554, .333277)
    RGB1[++i,] = (.169575, .042489, .340874)
    RGB1[++i,] = (.176493, .041402, .348111)
    RGB1[++i,] = (.183429, .040329, .354971)
    RGB1[++i,] = (.190367, .039309, .361447)
    RGB1[++i,] = (.197297, .038400, .367535)
    RGB1[++i,] = (.204209, .037632, .373238)
    RGB1[++i,] = (.211095, .037030, .378563)
    RGB1[++i,] = (.217949, .036615, .383522)
    RGB1[++i,] = (.224763, .036405, .388129)
    RGB1[++i,] = (.231538, .036405, .392400)
    RGB1[++i,] = (.238273, .036621, .396353)
    RGB1[++i,] = (.244967, .037055, .400007)
    RGB1[++i,] = (.251620, .037705, .403378)
    RGB1[++i,] = (.258234, .038571, .406485)
    RGB1[++i,] = (.264810, .039647, .409345)
    RGB1[++i,] = (.271347, .040922, .411976)
    RGB1[++i,] = (.277850, .042353, .414392)
    RGB1[++i,] = (.284321, .043933, .416608)
    RGB1[++i,] = (.290763, .045644, .418637)
    RGB1[++i,] = (.297178, .047470, .420491)
    RGB1[++i,] = (.303568, .049396, .422182)
    RGB1[++i,] = (.309935, .051407, .423721)
    RGB1[++i,] = (.316282, .053490, .425116)
    RGB1[++i,] = (.322610, .055634, .426377)
    RGB1[++i,] = (.328921, .057827, .427511)
    RGB1[++i,] = (.335217, .060060, .428524)
    RGB1[++i,] = (.341500, .062325, .429425)
    RGB1[++i,] = (.347771, .064616, .430217)
    RGB1[++i,] = (.354032, .066925, .430906)
    RGB1[++i,] = (.360284, .069247, .431497)
    RGB1[++i,] = (.366529, .071579, .431994)
    RGB1[++i,] = (.372768, .073915, .432400)
    RGB1[++i,] = (.379001, .076253, .432719)
    RGB1[++i,] = (.385228, .078591, .432955)
    RGB1[++i,] = (.391453, .080927, .433109)
    RGB1[++i,] = (.397674, .083257, .433183)
    RGB1[++i,] = (.403894, .085580, .433179)
    RGB1[++i,] = (.410113, .087896, .433098)
    RGB1[++i,] = (.416331, .090203, .432943)
    RGB1[++i,] = (.422549, .092501, .432714)
    RGB1[++i,] = (.428768, .094790, .432412)
    RGB1[++i,] = (.434987, .097069, .432039)
    RGB1[++i,] = (.441207, .099338, .431594)
    RGB1[++i,] = (.447428, .101597, .431080)
    RGB1[++i,] = (.453651, .103848, .430498)
    RGB1[++i,] = (.459875, .106089, .429846)
    RGB1[++i,] = (.466100, .108322, .429125)
    RGB1[++i,] = (.472328, .110547, .428334)
    RGB1[++i,] = (.478558, .112764, .427475)
    RGB1[++i,] = (.484789, .114974, .426548)
    RGB1[++i,] = (.491022, .117179, .425552)
    RGB1[++i,] = (.497257, .119379, .424488)
    RGB1[++i,] = (.503493, .121575, .423356)
    RGB1[++i,] = (.509730, .123769, .422156)
    RGB1[++i,] = (.515967, .125960, .420887)
    RGB1[++i,] = (.522206, .128150, .419549)
    RGB1[++i,] = (.528444, .130341, .418142)
    RGB1[++i,] = (.534683, .132534, .416667)
    RGB1[++i,] = (.540920, .134729, .415123)
    RGB1[++i,] = (.547157, .136929, .413511)
    RGB1[++i,] = (.553392, .139134, .411829)
    RGB1[++i,] = (.559624, .141346, .410078)
    RGB1[++i,] = (.565854, .143567, .408258)
    RGB1[++i,] = (.572081, .145797, .406369)
    RGB1[++i,] = (.578304, .148039, .404411)
    RGB1[++i,] = (.584521, .150294, .402385)
    RGB1[++i,] = (.590734, .152563, .400290)
    RGB1[++i,] = (.596940, .154848, .398125)
    RGB1[++i,] = (.603139, .157151, .395891)
    RGB1[++i,] = (.609330, .159474, .393589)
    RGB1[++i,] = (.615513, .161817, .391219)
    RGB1[++i,] = (.621685, .164184, .388781)
    RGB1[++i,] = (.627847, .166575, .386276)
    RGB1[++i,] = (.633998, .168992, .383704)
    RGB1[++i,] = (.640135, .171438, .381065)
    RGB1[++i,] = (.646260, .173914, .378359)
    RGB1[++i,] = (.652369, .176421, .375586)
    RGB1[++i,] = (.658463, .178962, .372748)
    RGB1[++i,] = (.664540, .181539, .369846)
    RGB1[++i,] = (.670599, .184153, .366879)
    RGB1[++i,] = (.676638, .186807, .363849)
    RGB1[++i,] = (.682656, .189501, .360757)
    RGB1[++i,] = (.688653, .192239, .357603)
    RGB1[++i,] = (.694627, .195021, .354388)
    RGB1[++i,] = (.700576, .197851, .351113)
    RGB1[++i,] = (.706500, .200728, .347777)
    RGB1[++i,] = (.712396, .203656, .344383)
    RGB1[++i,] = (.718264, .206636, .340931)
    RGB1[++i,] = (.724103, .209670, .337424)
    RGB1[++i,] = (.729909, .212759, .333861)
    RGB1[++i,] = (.735683, .215906, .330245)
    RGB1[++i,] = (.741423, .219112, .326576)
    RGB1[++i,] = (.747127, .222378, .322856)
    RGB1[++i,] = (.752794, .225706, .319085)
    RGB1[++i,] = (.758422, .229097, .315266)
    RGB1[++i,] = (.764010, .232554, .311399)
    RGB1[++i,] = (.769556, .236077, .307485)
    RGB1[++i,] = (.775059, .239667, .303526)
    RGB1[++i,] = (.780517, .243327, .299523)
    RGB1[++i,] = (.785929, .247056, .295477)
    RGB1[++i,] = (.791293, .250856, .291390)
    RGB1[++i,] = (.796607, .254728, .287264)
    RGB1[++i,] = (.801871, .258674, .283099)
    RGB1[++i,] = (.807082, .262692, .278898)
    RGB1[++i,] = (.812239, .266786, .274661)
    RGB1[++i,] = (.817341, .270954, .270390)
    RGB1[++i,] = (.822386, .275197, .266085)
    RGB1[++i,] = (.827372, .279517, .261750)
    RGB1[++i,] = (.832299, .283913, .257383)
    RGB1[++i,] = (.837165, .288385, .252988)
    RGB1[++i,] = (.841969, .292933, .248564)
    RGB1[++i,] = (.846709, .297559, .244113)
    RGB1[++i,] = (.851384, .302260, .239636)
    RGB1[++i,] = (.855992, .307038, .235133)
    RGB1[++i,] = (.860533, .311892, .230606)
    RGB1[++i,] = (.865006, .316822, .226055)
    RGB1[++i,] = (.869409, .321827, .221482)
    RGB1[++i,] = (.873741, .326906, .216886)
    RGB1[++i,] = (.878001, .332060, .212268)
    RGB1[++i,] = (.882188, .337287, .207628)
    RGB1[++i,] = (.886302, .342586, .202968)
    RGB1[++i,] = (.890341, .347957, .198286)
    RGB1[++i,] = (.894305, .353399, .193584)
    RGB1[++i,] = (.898192, .358911, .188860)
    RGB1[++i,] = (.902003, .364492, .184116)
    RGB1[++i,] = (.905735, .370140, .179350)
    RGB1[++i,] = (.909390, .375856, .174563)
    RGB1[++i,] = (.912966, .381636, .169755)
    RGB1[++i,] = (.916462, .387481, .164924)
    RGB1[++i,] = (.919879, .393389, .160070)
    RGB1[++i,] = (.923215, .399359, .155193)
    RGB1[++i,] = (.926470, .405389, .150292)
    RGB1[++i,] = (.929644, .411479, .145367)
    RGB1[++i,] = (.932737, .417627, .140417)
    RGB1[++i,] = (.935747, .423831, .135440)
    RGB1[++i,] = (.938675, .430091, .130438)
    RGB1[++i,] = (.941521, .436405, .125409)
    RGB1[++i,] = (.944285, .442772, .120354)
    RGB1[++i,] = (.946965, .449191, .115272)
    RGB1[++i,] = (.949562, .455660, .110164)
    RGB1[++i,] = (.952075, .462178, .105031)
    RGB1[++i,] = (.954506, .468744, .099874)
    RGB1[++i,] = (.956852, .475356, .094695)
    RGB1[++i,] = (.959114, .482014, .089499)
    RGB1[++i,] = (.961293, .488716, .084289)
    RGB1[++i,] = (.963387, .495462, .079073)
    RGB1[++i,] = (.965397, .502249, .073859)
    RGB1[++i,] = (.967322, .509078, .068659)
    RGB1[++i,] = (.969163, .515946, .063488)
    RGB1[++i,] = (.970919, .522853, .058367)
    RGB1[++i,] = (.972590, .529798, .053324)
    RGB1[++i,] = (.974176, .536780, .048392)
    RGB1[++i,] = (.975677, .543798, .043618)
    RGB1[++i,] = (.977092, .550850, .039050)
    RGB1[++i,] = (.978422, .557937, .034931)
    RGB1[++i,] = (.979666, .565057, .031409)
    RGB1[++i,] = (.980824, .572209, .028508)
    RGB1[++i,] = (.981895, .579392, .026250)
    RGB1[++i,] = (.982881, .586606, .024661)
    RGB1[++i,] = (.983779, .593849, .023770)
    RGB1[++i,] = (.984591, .601122, .023606)
    RGB1[++i,] = (.985315, .608422, .024202)
    RGB1[++i,] = (.985952, .615750, .025592)
    RGB1[++i,] = (.986502, .623105, .027814)
    RGB1[++i,] = (.986964, .630485, .030908)
    RGB1[++i,] = (.987337, .637890, .034916)
    RGB1[++i,] = (.987622, .645320, .039886)
    RGB1[++i,] = (.987819, .652773, .045581)
    RGB1[++i,] = (.987926, .660250, .051750)
    RGB1[++i,] = (.987945, .667748, .058329)
    RGB1[++i,] = (.987874, .675267, .065257)
    RGB1[++i,] = (.987714, .682807, .072489)
    RGB1[++i,] = (.987464, .690366, .079990)
    RGB1[++i,] = (.987124, .697944, .087731)
    RGB1[++i,] = (.986694, .705540, .095694)
    RGB1[++i,] = (.986175, .713153, .103863)
    RGB1[++i,] = (.985566, .720782, .112229)
    RGB1[++i,] = (.984865, .728427, .120785)
    RGB1[++i,] = (.984075, .736087, .129527)
    RGB1[++i,] = (.983196, .743758, .138453)
    RGB1[++i,] = (.982228, .751442, .147565)
    RGB1[++i,] = (.981173, .759135, .156863)
    RGB1[++i,] = (.980032, .766837, .166353)
    RGB1[++i,] = (.978806, .774545, .176037)
    RGB1[++i,] = (.977497, .782258, .185923)
    RGB1[++i,] = (.976108, .789974, .196018)
    RGB1[++i,] = (.974638, .797692, .206332)
    RGB1[++i,] = (.973088, .805409, .216877)
    RGB1[++i,] = (.971468, .813122, .227658)
    RGB1[++i,] = (.969783, .820825, .238686)
    RGB1[++i,] = (.968041, .828515, .249972)
    RGB1[++i,] = (.966243, .836191, .261534)
    RGB1[++i,] = (.964394, .843848, .273391)
    RGB1[++i,] = (.962517, .851476, .285546)
    RGB1[++i,] = (.960626, .859069, .298010)
    RGB1[++i,] = (.958720, .866624, .310820)
    RGB1[++i,] = (.956834, .874129, .323974)
    RGB1[++i,] = (.954997, .881569, .337475)
    RGB1[++i,] = (.953215, .888942, .351369)
    RGB1[++i,] = (.951546, .896226, .365627)
    RGB1[++i,] = (.950018, .903409, .380271)
    RGB1[++i,] = (.948683, .910473, .395289)
    RGB1[++i,] = (.947594, .917399, .410665)
    RGB1[++i,] = (.946809, .924168, .426373)
    RGB1[++i,] = (.946392, .930761, .442367)
    RGB1[++i,] = (.946403, .937159, .458592)
    RGB1[++i,] = (.946903, .943348, .474970)
    RGB1[++i,] = (.947937, .949318, .491426)
    RGB1[++i,] = (.949545, .955063, .507860)
    RGB1[++i,] = (.951740, .960587, .524203)
    RGB1[++i,] = (.954529, .965896, .540361)
    RGB1[++i,] = (.957896, .971003, .556275)
    RGB1[++i,] = (.961812, .975924, .571925)
    RGB1[++i,] = (.966249, .980678, .587206)
    RGB1[++i,] = (.971162, .985282, .602154)
    RGB1[++i,] = (.976511, .989753, .616760)
    RGB1[++i,] = (.982257, .994109, .631017)
    RGB1[++i,] = (.988362, .998364, .644924)
}

void `MAIN'::plasma(`RM' RGB1)
{
    `Int' i
    
    i = 0
    RGB1 = J(256, 3 ,.)
    RGB1[++i,] = (.050383, .029803, .527975)
    RGB1[++i,] = (.063536, .028426, .533124)
    RGB1[++i,] = (.075353, .027206, .538007)
    RGB1[++i,] = (.086222, .026125, .542658)
    RGB1[++i,] = (.096379, .025165, .547103)
    RGB1[++i,] = (.105980, .024309, .551368)
    RGB1[++i,] = (.115124, .023556, .555468)
    RGB1[++i,] = (.123903, .022878, .559423)
    RGB1[++i,] = (.132381, .022258, .563250)
    RGB1[++i,] = (.140603, .021687, .566959)
    RGB1[++i,] = (.148607, .021154, .570562)
    RGB1[++i,] = (.156421, .020651, .574065)
    RGB1[++i,] = (.164070, .020171, .577478)
    RGB1[++i,] = (.171574, .019706, .580806)
    RGB1[++i,] = (.178950, .019252, .584054)
    RGB1[++i,] = (.186213, .018803, .587228)
    RGB1[++i,] = (.193374, .018354, .590330)
    RGB1[++i,] = (.200445, .017902, .593364)
    RGB1[++i,] = (.207435, .017442, .596333)
    RGB1[++i,] = (.214350, .016973, .599239)
    RGB1[++i,] = (.221197, .016497, .602083)
    RGB1[++i,] = (.227983, .016007, .604867)
    RGB1[++i,] = (.234715, .015502, .607592)
    RGB1[++i,] = (.241396, .014979, .610259)
    RGB1[++i,] = (.248032, .014439, .612868)
    RGB1[++i,] = (.254627, .013882, .615419)
    RGB1[++i,] = (.261183, .013308, .617911)
    RGB1[++i,] = (.267703, .012716, .620346)
    RGB1[++i,] = (.274191, .012109, .622722)
    RGB1[++i,] = (.280648, .011488, .625038)
    RGB1[++i,] = (.287076, .010855, .627295)
    RGB1[++i,] = (.293478, .010213, .629490)
    RGB1[++i,] = (.299855, .009561, .631624)
    RGB1[++i,] = (.306210, .008902, .633694)
    RGB1[++i,] = (.312543, .008239, .635700)
    RGB1[++i,] = (.318856, .007576, .637640)
    RGB1[++i,] = (.325150, .006915, .639512)
    RGB1[++i,] = (.331426, .006261, .641316)
    RGB1[++i,] = (.337683, .005618, .643049)
    RGB1[++i,] = (.343925, .004991, .644710)
    RGB1[++i,] = (.350150, .004382, .646298)
    RGB1[++i,] = (.356359, .003798, .647810)
    RGB1[++i,] = (.362553, .003243, .649245)
    RGB1[++i,] = (.368733, .002724, .650601)
    RGB1[++i,] = (.374897, .002245, .651876)
    RGB1[++i,] = (.381047, .001814, .653068)
    RGB1[++i,] = (.387183, .001434, .654177)
    RGB1[++i,] = (.393304, .001114, .655199)
    RGB1[++i,] = (.399411, .000859, .656133)
    RGB1[++i,] = (.405503, .000678, .656977)
    RGB1[++i,] = (.411580, .000577, .657730)
    RGB1[++i,] = (.417642, .000564, .658390)
    RGB1[++i,] = (.423689, .000646, .658956)
    RGB1[++i,] = (.429719, .000831, .659425)
    RGB1[++i,] = (.435734, .001127, .659797)
    RGB1[++i,] = (.441732, .001540, .660069)
    RGB1[++i,] = (.447714, .002080, .660240)
    RGB1[++i,] = (.453677, .002755, .660310)
    RGB1[++i,] = (.459623, .003574, .660277)
    RGB1[++i,] = (.465550, .004545, .660139)
    RGB1[++i,] = (.471457, .005678, .659897)
    RGB1[++i,] = (.477344, .006980, .659549)
    RGB1[++i,] = (.483210, .008460, .659095)
    RGB1[++i,] = (.489055, .010127, .658534)
    RGB1[++i,] = (.494877, .011990, .657865)
    RGB1[++i,] = (.500678, .014055, .657088)
    RGB1[++i,] = (.506454, .016333, .656202)
    RGB1[++i,] = (.512206, .018833, .655209)
    RGB1[++i,] = (.517933, .021563, .654109)
    RGB1[++i,] = (.523633, .024532, .652901)
    RGB1[++i,] = (.529306, .027747, .651586)
    RGB1[++i,] = (.534952, .031217, .650165)
    RGB1[++i,] = (.540570, .034950, .648640)
    RGB1[++i,] = (.546157, .038954, .647010)
    RGB1[++i,] = (.551715, .043136, .645277)
    RGB1[++i,] = (.557243, .047331, .643443)
    RGB1[++i,] = (.562738, .051545, .641509)
    RGB1[++i,] = (.568201, .055778, .639477)
    RGB1[++i,] = (.573632, .060028, .637349)
    RGB1[++i,] = (.579029, .064296, .635126)
    RGB1[++i,] = (.584391, .068579, .632812)
    RGB1[++i,] = (.589719, .072878, .630408)
    RGB1[++i,] = (.595011, .077190, .627917)
    RGB1[++i,] = (.600266, .081516, .625342)
    RGB1[++i,] = (.605485, .085854, .622686)
    RGB1[++i,] = (.610667, .090204, .619951)
    RGB1[++i,] = (.615812, .094564, .617140)
    RGB1[++i,] = (.620919, .098934, .614257)
    RGB1[++i,] = (.625987, .103312, .611305)
    RGB1[++i,] = (.631017, .107699, .608287)
    RGB1[++i,] = (.636008, .112092, .605205)
    RGB1[++i,] = (.640959, .116492, .602065)
    RGB1[++i,] = (.645872, .120898, .598867)
    RGB1[++i,] = (.650746, .125309, .595617)
    RGB1[++i,] = (.655580, .129725, .592317)
    RGB1[++i,] = (.660374, .134144, .588971)
    RGB1[++i,] = (.665129, .138566, .585582)
    RGB1[++i,] = (.669845, .142992, .582154)
    RGB1[++i,] = (.674522, .147419, .578688)
    RGB1[++i,] = (.679160, .151848, .575189)
    RGB1[++i,] = (.683758, .156278, .571660)
    RGB1[++i,] = (.688318, .160709, .568103)
    RGB1[++i,] = (.692840, .165141, .564522)
    RGB1[++i,] = (.697324, .169573, .560919)
    RGB1[++i,] = (.701769, .174005, .557296)
    RGB1[++i,] = (.706178, .178437, .553657)
    RGB1[++i,] = (.710549, .182868, .550004)
    RGB1[++i,] = (.714883, .187299, .546338)
    RGB1[++i,] = (.719181, .191729, .542663)
    RGB1[++i,] = (.723444, .196158, .538981)
    RGB1[++i,] = (.727670, .200586, .535293)
    RGB1[++i,] = (.731862, .205013, .531601)
    RGB1[++i,] = (.736019, .209439, .527908)
    RGB1[++i,] = (.740143, .213864, .524216)
    RGB1[++i,] = (.744232, .218288, .520524)
    RGB1[++i,] = (.748289, .222711, .516834)
    RGB1[++i,] = (.752312, .227133, .513149)
    RGB1[++i,] = (.756304, .231555, .509468)
    RGB1[++i,] = (.760264, .235976, .505794)
    RGB1[++i,] = (.764193, .240396, .502126)
    RGB1[++i,] = (.768090, .244817, .498465)
    RGB1[++i,] = (.771958, .249237, .494813)
    RGB1[++i,] = (.775796, .253658, .491171)
    RGB1[++i,] = (.779604, .258078, .487539)
    RGB1[++i,] = (.783383, .262500, .483918)
    RGB1[++i,] = (.787133, .266922, .480307)
    RGB1[++i,] = (.790855, .271345, .476706)
    RGB1[++i,] = (.794549, .275770, .473117)
    RGB1[++i,] = (.798216, .280197, .469538)
    RGB1[++i,] = (.801855, .284626, .465971)
    RGB1[++i,] = (.805467, .289057, .462415)
    RGB1[++i,] = (.809052, .293491, .458870)
    RGB1[++i,] = (.812612, .297928, .455338)
    RGB1[++i,] = (.816144, .302368, .451816)
    RGB1[++i,] = (.819651, .306812, .448306)
    RGB1[++i,] = (.823132, .311261, .444806)
    RGB1[++i,] = (.826588, .315714, .441316)
    RGB1[++i,] = (.830018, .320172, .437836)
    RGB1[++i,] = (.833422, .324635, .434366)
    RGB1[++i,] = (.836801, .329105, .430905)
    RGB1[++i,] = (.840155, .333580, .427455)
    RGB1[++i,] = (.843484, .338062, .424013)
    RGB1[++i,] = (.846788, .342551, .420579)
    RGB1[++i,] = (.850066, .347048, .417153)
    RGB1[++i,] = (.853319, .351553, .413734)
    RGB1[++i,] = (.856547, .356066, .410322)
    RGB1[++i,] = (.859750, .360588, .406917)
    RGB1[++i,] = (.862927, .365119, .403519)
    RGB1[++i,] = (.866078, .369660, .400126)
    RGB1[++i,] = (.869203, .374212, .396738)
    RGB1[++i,] = (.872303, .378774, .393355)
    RGB1[++i,] = (.875376, .383347, .389976)
    RGB1[++i,] = (.878423, .387932, .386600)
    RGB1[++i,] = (.881443, .392529, .383229)
    RGB1[++i,] = (.884436, .397139, .379860)
    RGB1[++i,] = (.887402, .401762, .376494)
    RGB1[++i,] = (.890340, .406398, .373130)
    RGB1[++i,] = (.893250, .411048, .369768)
    RGB1[++i,] = (.896131, .415712, .366407)
    RGB1[++i,] = (.898984, .420392, .363047)
    RGB1[++i,] = (.901807, .425087, .359688)
    RGB1[++i,] = (.904601, .429797, .356329)
    RGB1[++i,] = (.907365, .434524, .352970)
    RGB1[++i,] = (.910098, .439268, .349610)
    RGB1[++i,] = (.912800, .444029, .346251)
    RGB1[++i,] = (.915471, .448807, .342890)
    RGB1[++i,] = (.918109, .453603, .339529)
    RGB1[++i,] = (.920714, .458417, .336166)
    RGB1[++i,] = (.923287, .463251, .332801)
    RGB1[++i,] = (.925825, .468103, .329435)
    RGB1[++i,] = (.928329, .472975, .326067)
    RGB1[++i,] = (.930798, .477867, .322697)
    RGB1[++i,] = (.933232, .482780, .319325)
    RGB1[++i,] = (.935630, .487712, .315952)
    RGB1[++i,] = (.937990, .492667, .312575)
    RGB1[++i,] = (.940313, .497642, .309197)
    RGB1[++i,] = (.942598, .502639, .305816)
    RGB1[++i,] = (.944844, .507658, .302433)
    RGB1[++i,] = (.947051, .512699, .299049)
    RGB1[++i,] = (.949217, .517763, .295662)
    RGB1[++i,] = (.951344, .522850, .292275)
    RGB1[++i,] = (.953428, .527960, .288883)
    RGB1[++i,] = (.955470, .533093, .285490)
    RGB1[++i,] = (.957469, .538250, .282096)
    RGB1[++i,] = (.959424, .543431, .278701)
    RGB1[++i,] = (.961336, .548636, .275305)
    RGB1[++i,] = (.963203, .553865, .271909)
    RGB1[++i,] = (.965024, .559118, .268513)
    RGB1[++i,] = (.966798, .564396, .265118)
    RGB1[++i,] = (.968526, .569700, .261721)
    RGB1[++i,] = (.970205, .575028, .258325)
    RGB1[++i,] = (.971835, .580382, .254931)
    RGB1[++i,] = (.973416, .585761, .251540)
    RGB1[++i,] = (.974947, .591165, .248151)
    RGB1[++i,] = (.976428, .596595, .244767)
    RGB1[++i,] = (.977856, .602051, .241387)
    RGB1[++i,] = (.979233, .607532, .238013)
    RGB1[++i,] = (.980556, .613039, .234646)
    RGB1[++i,] = (.981826, .618572, .231287)
    RGB1[++i,] = (.983041, .624131, .227937)
    RGB1[++i,] = (.984199, .629718, .224595)
    RGB1[++i,] = (.985301, .635330, .221265)
    RGB1[++i,] = (.986345, .640969, .217948)
    RGB1[++i,] = (.987332, .646633, .214648)
    RGB1[++i,] = (.988260, .652325, .211364)
    RGB1[++i,] = (.989128, .658043, .208100)
    RGB1[++i,] = (.989935, .663787, .204859)
    RGB1[++i,] = (.990681, .669558, .201642)
    RGB1[++i,] = (.991365, .675355, .198453)
    RGB1[++i,] = (.991985, .681179, .195295)
    RGB1[++i,] = (.992541, .687030, .192170)
    RGB1[++i,] = (.993032, .692907, .189084)
    RGB1[++i,] = (.993456, .698810, .186041)
    RGB1[++i,] = (.993814, .704741, .183043)
    RGB1[++i,] = (.994103, .710698, .180097)
    RGB1[++i,] = (.994324, .716681, .177208)
    RGB1[++i,] = (.994474, .722691, .174381)
    RGB1[++i,] = (.994553, .728728, .171622)
    RGB1[++i,] = (.994561, .734791, .168938)
    RGB1[++i,] = (.994495, .740880, .166335)
    RGB1[++i,] = (.994355, .746995, .163821)
    RGB1[++i,] = (.994141, .753137, .161404)
    RGB1[++i,] = (.993851, .759304, .159092)
    RGB1[++i,] = (.993482, .765499, .156891)
    RGB1[++i,] = (.993033, .771720, .154808)
    RGB1[++i,] = (.992505, .777967, .152855)
    RGB1[++i,] = (.991897, .784239, .151042)
    RGB1[++i,] = (.991209, .790537, .149377)
    RGB1[++i,] = (.990439, .796859, .147870)
    RGB1[++i,] = (.989587, .803205, .146529)
    RGB1[++i,] = (.988648, .809579, .145357)
    RGB1[++i,] = (.987621, .815978, .144363)
    RGB1[++i,] = (.986509, .822401, .143557)
    RGB1[++i,] = (.985314, .828846, .142945)
    RGB1[++i,] = (.984031, .835315, .142528)
    RGB1[++i,] = (.982653, .841812, .142303)
    RGB1[++i,] = (.981190, .848329, .142279)
    RGB1[++i,] = (.979644, .854866, .142453)
    RGB1[++i,] = (.977995, .861432, .142808)
    RGB1[++i,] = (.976265, .868016, .143351)
    RGB1[++i,] = (.974443, .874622, .144061)
    RGB1[++i,] = (.972530, .881250, .144923)
    RGB1[++i,] = (.970533, .887896, .145919)
    RGB1[++i,] = (.968443, .894564, .147014)
    RGB1[++i,] = (.966271, .901249, .148180)
    RGB1[++i,] = (.964021, .907950, .149370)
    RGB1[++i,] = (.961681, .914672, .150520)
    RGB1[++i,] = (.959276, .921407, .151566)
    RGB1[++i,] = (.956808, .928152, .152409)
    RGB1[++i,] = (.954287, .934908, .152921)
    RGB1[++i,] = (.951726, .941671, .152925)
    RGB1[++i,] = (.949151, .948435, .152178)
    RGB1[++i,] = (.946602, .955190, .150328)
    RGB1[++i,] = (.944152, .961916, .146861)
    RGB1[++i,] = (.941896, .968590, .140956)
    RGB1[++i,] = (.940015, .975158, .131326)
}

void `MAIN'::viridis(`RM' RGB1)
{
    `Int' i
    
    i = 0
    RGB1 = J(256, 3 ,.)
    RGB1[++i,] = (.267004, .004874, .329415)
    RGB1[++i,] = (.268510, .009605, .335427)
    RGB1[++i,] = (.269944, .014625, .341379)
    RGB1[++i,] = (.271305, .019942, .347269)
    RGB1[++i,] = (.272594, .025563, .353093)
    RGB1[++i,] = (.273809, .031497, .358853)
    RGB1[++i,] = (.274952, .037752, .364543)
    RGB1[++i,] = (.276022, .044167, .370164)
    RGB1[++i,] = (.277018, .050344, .375715)
    RGB1[++i,] = (.277941, .056324, .381191)
    RGB1[++i,] = (.278791, .062145, .386592)
    RGB1[++i,] = (.279566, .067836, .391917)
    RGB1[++i,] = (.280267, .073417, .397163)
    RGB1[++i,] = (.280894, .078907, .402329)
    RGB1[++i,] = (.281446, .084320, .407414)
    RGB1[++i,] = (.281924, .089666, .412415)
    RGB1[++i,] = (.282327, .094955, .417331)
    RGB1[++i,] = (.282656, .100196, .422160)
    RGB1[++i,] = (.282910, .105393, .426902)
    RGB1[++i,] = (.283091, .110553, .431554)
    RGB1[++i,] = (.283197, .115680, .436115)
    RGB1[++i,] = (.283229, .120777, .440584)
    RGB1[++i,] = (.283187, .125848, .444960)
    RGB1[++i,] = (.283072, .130895, .449241)
    RGB1[++i,] = (.282884, .135920, .453427)
    RGB1[++i,] = (.282623, .140926, .457517)
    RGB1[++i,] = (.282290, .145912, .461510)
    RGB1[++i,] = (.281887, .150881, .465405)
    RGB1[++i,] = (.281412, .155834, .469201)
    RGB1[++i,] = (.280868, .160771, .472899)
    RGB1[++i,] = (.280255, .165693, .476498)
    RGB1[++i,] = (.279574, .170599, .479997)
    RGB1[++i,] = (.278826, .175490, .483397)
    RGB1[++i,] = (.278012, .180367, .486697)
    RGB1[++i,] = (.277134, .185228, .489898)
    RGB1[++i,] = (.276194, .190074, .493001)
    RGB1[++i,] = (.275191, .194905, .496005)
    RGB1[++i,] = (.274128, .199721, .498911)
    RGB1[++i,] = (.273006, .204520, .501721)
    RGB1[++i,] = (.271828, .209303, .504434)
    RGB1[++i,] = (.270595, .214069, .507052)
    RGB1[++i,] = (.269308, .218818, .509577)
    RGB1[++i,] = (.267968, .223549, .512008)
    RGB1[++i,] = (.266580, .228262, .514349)
    RGB1[++i,] = (.265145, .232956, .516599)
    RGB1[++i,] = (.263663, .237631, .518762)
    RGB1[++i,] = (.262138, .242286, .520837)
    RGB1[++i,] = (.260571, .246922, .522828)
    RGB1[++i,] = (.258965, .251537, .524736)
    RGB1[++i,] = (.257322, .256130, .526563)
    RGB1[++i,] = (.255645, .260703, .528312)
    RGB1[++i,] = (.253935, .265254, .529983)
    RGB1[++i,] = (.252194, .269783, .531579)
    RGB1[++i,] = (.250425, .274290, .533103)
    RGB1[++i,] = (.248629, .278775, .534556)
    RGB1[++i,] = (.246811, .283237, .535941)
    RGB1[++i,] = (.244972, .287675, .537260)
    RGB1[++i,] = (.243113, .292092, .538516)
    RGB1[++i,] = (.241237, .296485, .539709)
    RGB1[++i,] = (.239346, .300855, .540844)
    RGB1[++i,] = (.237441, .305202, .541921)
    RGB1[++i,] = (.235526, .309527, .542944)
    RGB1[++i,] = (.233603, .313828, .543914)
    RGB1[++i,] = (.231674, .318106, .544834)
    RGB1[++i,] = (.229739, .322361, .545706)
    RGB1[++i,] = (.227802, .326594, .546532)
    RGB1[++i,] = (.225863, .330805, .547314)
    RGB1[++i,] = (.223925, .334994, .548053)
    RGB1[++i,] = (.221989, .339161, .548752)
    RGB1[++i,] = (.220057, .343307, .549413)
    RGB1[++i,] = (.218130, .347432, .550038)
    RGB1[++i,] = (.216210, .351535, .550627)
    RGB1[++i,] = (.214298, .355619, .551184)
    RGB1[++i,] = (.212395, .359683, .551710)
    RGB1[++i,] = (.210503, .363727, .552206)
    RGB1[++i,] = (.208623, .367752, .552675)
    RGB1[++i,] = (.206756, .371758, .553117)
    RGB1[++i,] = (.204903, .375746, .553533)
    RGB1[++i,] = (.203063, .379716, .553925)
    RGB1[++i,] = (.201239, .383670, .554294)
    RGB1[++i,] = (.199430, .387607, .554642)
    RGB1[++i,] = (.197636, .391528, .554969)
    RGB1[++i,] = (.195860, .395433, .555276)
    RGB1[++i,] = (.194100, .399323, .555565)
    RGB1[++i,] = (.192357, .403199, .555836)
    RGB1[++i,] = (.190631, .407061, .556089)
    RGB1[++i,] = (.188923, .410910, .556326)
    RGB1[++i,] = (.187231, .414746, .556547)
    RGB1[++i,] = (.185556, .418570, .556753)
    RGB1[++i,] = (.183898, .422383, .556944)
    RGB1[++i,] = (.182256, .426184, .557120)
    RGB1[++i,] = (.180629, .429975, .557282)
    RGB1[++i,] = (.179019, .433756, .557430)
    RGB1[++i,] = (.177423, .437527, .557565)
    RGB1[++i,] = (.175841, .441290, .557685)
    RGB1[++i,] = (.174274, .445044, .557792)
    RGB1[++i,] = (.172719, .448791, .557885)
    RGB1[++i,] = (.171176, .452530, .557965)
    RGB1[++i,] = (.169646, .456262, .558030)
    RGB1[++i,] = (.168126, .459988, .558082)
    RGB1[++i,] = (.166617, .463708, .558119)
    RGB1[++i,] = (.165117, .467423, .558141)
    RGB1[++i,] = (.163625, .471133, .558148)
    RGB1[++i,] = (.162142, .474838, .558140)
    RGB1[++i,] = (.160665, .478540, .558115)
    RGB1[++i,] = (.159194, .482237, .558073)
    RGB1[++i,] = (.157729, .485932, .558013)
    RGB1[++i,] = (.156270, .489624, .557936)
    RGB1[++i,] = (.154815, .493313, .557840)
    RGB1[++i,] = (.153364, .497000, .557724)
    RGB1[++i,] = (.151918, .500685, .557587)
    RGB1[++i,] = (.150476, .504369, .557430)
    RGB1[++i,] = (.149039, .508051, .557250)
    RGB1[++i,] = (.147607, .511733, .557049)
    RGB1[++i,] = (.146180, .515413, .556823)
    RGB1[++i,] = (.144759, .519093, .556572)
    RGB1[++i,] = (.143343, .522773, .556295)
    RGB1[++i,] = (.141935, .526453, .555991)
    RGB1[++i,] = (.140536, .530132, .555659)
    RGB1[++i,] = (.139147, .533812, .555298)
    RGB1[++i,] = (.137770, .537492, .554906)
    RGB1[++i,] = (.136408, .541173, .554483)
    RGB1[++i,] = (.135066, .544853, .554029)
    RGB1[++i,] = (.133743, .548535, .553541)
    RGB1[++i,] = (.132444, .552216, .553018)
    RGB1[++i,] = (.131172, .555899, .552459)
    RGB1[++i,] = (.129933, .559582, .551864)
    RGB1[++i,] = (.128729, .563265, .551229)
    RGB1[++i,] = (.127568, .566949, .550556)
    RGB1[++i,] = (.126453, .570633, .549841)
    RGB1[++i,] = (.125394, .574318, .549086)
    RGB1[++i,] = (.124395, .578002, .548287)
    RGB1[++i,] = (.123463, .581687, .547445)
    RGB1[++i,] = (.122606, .585371, .546557)
    RGB1[++i,] = (.121831, .589055, .545623)
    RGB1[++i,] = (.121148, .592739, .544641)
    RGB1[++i,] = (.120565, .596422, .543611)
    RGB1[++i,] = (.120092, .600104, .542530)
    RGB1[++i,] = (.119738, .603785, .541400)
    RGB1[++i,] = (.119512, .607464, .540218)
    RGB1[++i,] = (.119423, .611141, .538982)
    RGB1[++i,] = (.119483, .614817, .537692)
    RGB1[++i,] = (.119699, .618490, .536347)
    RGB1[++i,] = (.120081, .622161, .534946)
    RGB1[++i,] = (.120638, .625828, .533488)
    RGB1[++i,] = (.121380, .629492, .531973)
    RGB1[++i,] = (.122312, .633153, .530398)
    RGB1[++i,] = (.123444, .636809, .528763)
    RGB1[++i,] = (.124780, .640461, .527068)
    RGB1[++i,] = (.126326, .644107, .525311)
    RGB1[++i,] = (.128087, .647749, .523491)
    RGB1[++i,] = (.130067, .651384, .521608)
    RGB1[++i,] = (.132268, .655014, .519661)
    RGB1[++i,] = (.134692, .658636, .517649)
    RGB1[++i,] = (.137339, .662252, .515571)
    RGB1[++i,] = (.140210, .665859, .513427)
    RGB1[++i,] = (.143303, .669459, .511215)
    RGB1[++i,] = (.146616, .673050, .508936)
    RGB1[++i,] = (.150148, .676631, .506589)
    RGB1[++i,] = (.153894, .680203, .504172)
    RGB1[++i,] = (.157851, .683765, .501686)
    RGB1[++i,] = (.162016, .687316, .499129)
    RGB1[++i,] = (.166383, .690856, .496502)
    RGB1[++i,] = (.170948, .694384, .493803)
    RGB1[++i,] = (.175707, .697900, .491033)
    RGB1[++i,] = (.180653, .701402, .488189)
    RGB1[++i,] = (.185783, .704891, .485273)
    RGB1[++i,] = (.191090, .708366, .482284)
    RGB1[++i,] = (.196571, .711827, .479221)
    RGB1[++i,] = (.202219, .715272, .476084)
    RGB1[++i,] = (.208030, .718701, .472873)
    RGB1[++i,] = (.214000, .722114, .469588)
    RGB1[++i,] = (.220124, .725509, .466226)
    RGB1[++i,] = (.226397, .728888, .462789)
    RGB1[++i,] = (.232815, .732247, .459277)
    RGB1[++i,] = (.239374, .735588, .455688)
    RGB1[++i,] = (.246070, .738910, .452024)
    RGB1[++i,] = (.252899, .742211, .448284)
    RGB1[++i,] = (.259857, .745492, .444467)
    RGB1[++i,] = (.266941, .748751, .440573)
    RGB1[++i,] = (.274149, .751988, .436601)
    RGB1[++i,] = (.281477, .755203, .432552)
    RGB1[++i,] = (.288921, .758394, .428426)
    RGB1[++i,] = (.296479, .761561, .424223)
    RGB1[++i,] = (.304148, .764704, .419943)
    RGB1[++i,] = (.311925, .767822, .415586)
    RGB1[++i,] = (.319809, .770914, .411152)
    RGB1[++i,] = (.327796, .773980, .406640)
    RGB1[++i,] = (.335885, .777018, .402049)
    RGB1[++i,] = (.344074, .780029, .397381)
    RGB1[++i,] = (.352360, .783011, .392636)
    RGB1[++i,] = (.360741, .785964, .387814)
    RGB1[++i,] = (.369214, .788888, .382914)
    RGB1[++i,] = (.377779, .791781, .377939)
    RGB1[++i,] = (.386433, .794644, .372886)
    RGB1[++i,] = (.395174, .797475, .367757)
    RGB1[++i,] = (.404001, .800275, .362552)
    RGB1[++i,] = (.412913, .803041, .357269)
    RGB1[++i,] = (.421908, .805774, .351910)
    RGB1[++i,] = (.430983, .808473, .346476)
    RGB1[++i,] = (.440137, .811138, .340967)
    RGB1[++i,] = (.449368, .813768, .335384)
    RGB1[++i,] = (.458674, .816363, .329727)
    RGB1[++i,] = (.468053, .818921, .323998)
    RGB1[++i,] = (.477504, .821444, .318195)
    RGB1[++i,] = (.487026, .823929, .312321)
    RGB1[++i,] = (.496615, .826376, .306377)
    RGB1[++i,] = (.506271, .828786, .300362)
    RGB1[++i,] = (.515992, .831158, .294279)
    RGB1[++i,] = (.525776, .833491, .288127)
    RGB1[++i,] = (.535621, .835785, .281908)
    RGB1[++i,] = (.545524, .838039, .275626)
    RGB1[++i,] = (.555484, .840254, .269281)
    RGB1[++i,] = (.565498, .842430, .262877)
    RGB1[++i,] = (.575563, .844566, .256415)
    RGB1[++i,] = (.585678, .846661, .249897)
    RGB1[++i,] = (.595839, .848717, .243329)
    RGB1[++i,] = (.606045, .850733, .236712)
    RGB1[++i,] = (.616293, .852709, .230052)
    RGB1[++i,] = (.626579, .854645, .223353)
    RGB1[++i,] = (.636902, .856542, .216620)
    RGB1[++i,] = (.647257, .858400, .209861)
    RGB1[++i,] = (.657642, .860219, .203082)
    RGB1[++i,] = (.668054, .861999, .196293)
    RGB1[++i,] = (.678489, .863742, .189503)
    RGB1[++i,] = (.688944, .865448, .182725)
    RGB1[++i,] = (.699415, .867117, .175971)
    RGB1[++i,] = (.709898, .868751, .169257)
    RGB1[++i,] = (.720391, .870350, .162603)
    RGB1[++i,] = (.730889, .871916, .156029)
    RGB1[++i,] = (.741388, .873449, .149561)
    RGB1[++i,] = (.751884, .874951, .143228)
    RGB1[++i,] = (.762373, .876424, .137064)
    RGB1[++i,] = (.772852, .877868, .131109)
    RGB1[++i,] = (.783315, .879285, .125405)
    RGB1[++i,] = (.793760, .880678, .120005)
    RGB1[++i,] = (.804182, .882046, .114965)
    RGB1[++i,] = (.814576, .883393, .110347)
    RGB1[++i,] = (.824940, .884720, .106217)
    RGB1[++i,] = (.835270, .886029, .102646)
    RGB1[++i,] = (.845561, .887322, .099702)
    RGB1[++i,] = (.855810, .888601, .097452)
    RGB1[++i,] = (.866013, .889868, .095953)
    RGB1[++i,] = (.876168, .891125, .095250)
    RGB1[++i,] = (.886271, .892374, .095374)
    RGB1[++i,] = (.896320, .893616, .096335)
    RGB1[++i,] = (.906311, .894855, .098125)
    RGB1[++i,] = (.916242, .896091, .100717)
    RGB1[++i,] = (.926106, .897330, .104071)
    RGB1[++i,] = (.935904, .898570, .108131)
    RGB1[++i,] = (.945636, .899815, .112838)
    RGB1[++i,] = (.955300, .901065, .118128)
    RGB1[++i,] = (.964894, .902323, .123941)
    RGB1[++i,] = (.974417, .903590, .130215)
    RGB1[++i,] = (.983868, .904867, .136897)
    RGB1[++i,] = (.993248, .906157, .143936)
}

void `MAIN'::cividis(`RM' RGB1)
{
    `Int' i
    
    i = 0
    RGB1 = J(256, 3 ,.)
    RGB1[++i,] = (.000000, .135112, .304751)
    RGB1[++i,] = (.000000, .138068, .311105)
    RGB1[++i,] = (.000000, .141013, .317579)
    RGB1[++i,] = (.000000, .143951, .323982)
    RGB1[++i,] = (.000000, .146877, .330479)
    RGB1[++i,] = (.000000, .149791, .337065)
    RGB1[++i,] = (.000000, .152673, .343704)
    RGB1[++i,] = (.000000, .155377, .350500)
    RGB1[++i,] = (.000000, .157932, .357521)
    RGB1[++i,] = (.000000, .160495, .364534)
    RGB1[++i,] = (.000000, .163058, .371608)
    RGB1[++i,] = (.000000, .165621, .378769)
    RGB1[++i,] = (.000000, .168204, .385902)
    RGB1[++i,] = (.000000, .170800, .393100)
    RGB1[++i,] = (.000000, .173420, .400353)
    RGB1[++i,] = (.000000, .176082, .407577)
    RGB1[++i,] = (.000000, .178802, .414764)
    RGB1[++i,] = (.000000, .181610, .421859)
    RGB1[++i,] = (.000000, .184550, .428802)
    RGB1[++i,] = (.000000, .186915, .435532)
    RGB1[++i,] = (.000000, .188769, .439563)
    RGB1[++i,] = (.000000, .190950, .441085)
    RGB1[++i,] = (.000000, .193366, .441561)
    RGB1[++i,] = (.003602, .195911, .441564)
    RGB1[++i,] = (.017852, .198528, .441248)
    RGB1[++i,] = (.032110, .201199, .440785)
    RGB1[++i,] = (.046205, .203903, .440196)
    RGB1[++i,] = (.058378, .206629, .439531)
    RGB1[++i,] = (.068968, .209372, .438863)
    RGB1[++i,] = (.078624, .212122, .438105)
    RGB1[++i,] = (.087465, .214879, .437342)
    RGB1[++i,] = (.095645, .217643, .436593)
    RGB1[++i,] = (.103401, .220406, .435790)
    RGB1[++i,] = (.110658, .223170, .435067)
    RGB1[++i,] = (.117612, .225935, .434308)
    RGB1[++i,] = (.124291, .228697, .433547)
    RGB1[++i,] = (.130669, .231458, .432840)
    RGB1[++i,] = (.136830, .234216, .432148)
    RGB1[++i,] = (.142852, .236972, .431404)
    RGB1[++i,] = (.148638, .239724, .430752)
    RGB1[++i,] = (.154261, .242475, .430120)
    RGB1[++i,] = (.159733, .245221, .429528)
    RGB1[++i,] = (.165113, .247965, .428908)
    RGB1[++i,] = (.170362, .250707, .428325)
    RGB1[++i,] = (.175490, .253444, .427790)
    RGB1[++i,] = (.180503, .256180, .427299)
    RGB1[++i,] = (.185453, .258914, .426788)
    RGB1[++i,] = (.190303, .261644, .426329)
    RGB1[++i,] = (.195057, .264372, .425924)
    RGB1[++i,] = (.199764, .267099, .425497)
    RGB1[++i,] = (.204385, .269823, .425126)
    RGB1[++i,] = (.208926, .272546, .424809)
    RGB1[++i,] = (.213431, .275266, .424480)
    RGB1[++i,] = (.217863, .277985, .424206)
    RGB1[++i,] = (.222264, .280702, .423914)
    RGB1[++i,] = (.226598, .283419, .423678)
    RGB1[++i,] = (.230871, .286134, .423498)
    RGB1[++i,] = (.235120, .288848, .423304)
    RGB1[++i,] = (.239312, .291562, .423167)
    RGB1[++i,] = (.243485, .294274, .423014)
    RGB1[++i,] = (.247605, .296986, .422917)
    RGB1[++i,] = (.251675, .299698, .422873)
    RGB1[++i,] = (.255731, .302409, .422814)
    RGB1[++i,] = (.259740, .305120, .422810)
    RGB1[++i,] = (.263738, .307831, .422789)
    RGB1[++i,] = (.267693, .310542, .422821)
    RGB1[++i,] = (.271639, .313253, .422837)
    RGB1[++i,] = (.275513, .315965, .422979)
    RGB1[++i,] = (.279411, .318677, .423031)
    RGB1[++i,] = (.283240, .321390, .423211)
    RGB1[++i,] = (.287065, .324103, .423373)
    RGB1[++i,] = (.290884, .326816, .423517)
    RGB1[++i,] = (.294669, .329531, .423716)
    RGB1[++i,] = (.298421, .332247, .423973)
    RGB1[++i,] = (.302169, .334963, .424213)
    RGB1[++i,] = (.305886, .337681, .424512)
    RGB1[++i,] = (.309601, .340399, .424790)
    RGB1[++i,] = (.313287, .343120, .425120)
    RGB1[++i,] = (.316941, .345842, .425512)
    RGB1[++i,] = (.320595, .348565, .425889)
    RGB1[++i,] = (.324250, .351289, .426250)
    RGB1[++i,] = (.327875, .354016, .426670)
    RGB1[++i,] = (.331474, .356744, .427144)
    RGB1[++i,] = (.335073, .359474, .427605)
    RGB1[++i,] = (.338673, .362206, .428053)
    RGB1[++i,] = (.342246, .364939, .428559)
    RGB1[++i,] = (.345793, .367676, .429127)
    RGB1[++i,] = (.349341, .370414, .429685)
    RGB1[++i,] = (.352892, .373153, .430226)
    RGB1[++i,] = (.356418, .375896, .430823)
    RGB1[++i,] = (.359916, .378641, .431501)
    RGB1[++i,] = (.363446, .381388, .432075)
    RGB1[++i,] = (.366923, .384139, .432796)
    RGB1[++i,] = (.370430, .386890, .433428)
    RGB1[++i,] = (.373884, .389646, .434209)
    RGB1[++i,] = (.377371, .392404, .434890)
    RGB1[++i,] = (.380830, .395164, .435653)
    RGB1[++i,] = (.384268, .397928, .436475)
    RGB1[++i,] = (.387705, .400694, .437305)
    RGB1[++i,] = (.391151, .403464, .438096)
    RGB1[++i,] = (.394568, .406236, .438986)
    RGB1[++i,] = (.397991, .409011, .439848)
    RGB1[++i,] = (.401418, .411790, .440708)
    RGB1[++i,] = (.404820, .414572, .441642)
    RGB1[++i,] = (.408226, .417357, .442570)
    RGB1[++i,] = (.411607, .420145, .443577)
    RGB1[++i,] = (.414992, .422937, .444578)
    RGB1[++i,] = (.418383, .425733, .445560)
    RGB1[++i,] = (.421748, .428531, .446640)
    RGB1[++i,] = (.425120, .431334, .447692)
    RGB1[++i,] = (.428462, .434140, .448864)
    RGB1[++i,] = (.431817, .436950, .449982)
    RGB1[++i,] = (.435168, .439763, .451134)
    RGB1[++i,] = (.438504, .442580, .452341)
    RGB1[++i,] = (.441810, .445402, .453659)
    RGB1[++i,] = (.445148, .448226, .454885)
    RGB1[++i,] = (.448447, .451053, .456264)
    RGB1[++i,] = (.451759, .453887, .457582)
    RGB1[++i,] = (.455072, .456718, .458976)
    RGB1[++i,] = (.458366, .459552, .460457)
    RGB1[++i,] = (.461616, .462405, .461969)
    RGB1[++i,] = (.464947, .465241, .463395)
    RGB1[++i,] = (.468254, .468083, .464908)
    RGB1[++i,] = (.471501, .470960, .466357)
    RGB1[++i,] = (.474812, .473832, .467681)
    RGB1[++i,] = (.478186, .476699, .468845)
    RGB1[++i,] = (.481622, .479573, .469767)
    RGB1[++i,] = (.485141, .482451, .470384)
    RGB1[++i,] = (.488697, .485318, .471008)
    RGB1[++i,] = (.492278, .488198, .471453)
    RGB1[++i,] = (.495913, .491076, .471751)
    RGB1[++i,] = (.499552, .493960, .472032)
    RGB1[++i,] = (.503185, .496851, .472305)
    RGB1[++i,] = (.506866, .499743, .472432)
    RGB1[++i,] = (.510540, .502643, .472550)
    RGB1[++i,] = (.514226, .505546, .472640)
    RGB1[++i,] = (.517920, .508454, .472707)
    RGB1[++i,] = (.521643, .511367, .472639)
    RGB1[++i,] = (.525348, .514285, .472660)
    RGB1[++i,] = (.529086, .517207, .472543)
    RGB1[++i,] = (.532829, .520135, .472401)
    RGB1[++i,] = (.536553, .523067, .472352)
    RGB1[++i,] = (.540307, .526005, .472163)
    RGB1[++i,] = (.544069, .528948, .471947)
    RGB1[++i,] = (.547840, .531895, .471704)
    RGB1[++i,] = (.551612, .534849, .471439)
    RGB1[++i,] = (.555393, .537807, .471147)
    RGB1[++i,] = (.559181, .540771, .470829)
    RGB1[++i,] = (.562972, .543741, .470488)
    RGB1[++i,] = (.566802, .546715, .469988)
    RGB1[++i,] = (.570607, .549695, .469593)
    RGB1[++i,] = (.574417, .552682, .469172)
    RGB1[++i,] = (.578236, .555673, .468724)
    RGB1[++i,] = (.582087, .558670, .468118)
    RGB1[++i,] = (.585916, .561674, .467618)
    RGB1[++i,] = (.589753, .564682, .467090)
    RGB1[++i,] = (.593622, .567697, .466401)
    RGB1[++i,] = (.597469, .570718, .465821)
    RGB1[++i,] = (.601354, .573743, .465074)
    RGB1[++i,] = (.605211, .576777, .464441)
    RGB1[++i,] = (.609105, .579816, .463638)
    RGB1[++i,] = (.612977, .582861, .462950)
    RGB1[++i,] = (.616852, .585913, .462237)
    RGB1[++i,] = (.620765, .588970, .461351)
    RGB1[++i,] = (.624654, .592034, .460583)
    RGB1[++i,] = (.628576, .595104, .459641)
    RGB1[++i,] = (.632506, .598180, .458668)
    RGB1[++i,] = (.636412, .601264, .457818)
    RGB1[++i,] = (.640352, .604354, .456791)
    RGB1[++i,] = (.644270, .607450, .455886)
    RGB1[++i,] = (.648222, .610553, .454801)
    RGB1[++i,] = (.652178, .613664, .453689)
    RGB1[++i,] = (.656114, .616780, .452702)
    RGB1[++i,] = (.660082, .619904, .451534)
    RGB1[++i,] = (.664055, .623034, .450338)
    RGB1[++i,] = (.668008, .626171, .449270)
    RGB1[++i,] = (.671991, .629316, .448018)
    RGB1[++i,] = (.675981, .632468, .446736)
    RGB1[++i,] = (.679979, .635626, .445424)
    RGB1[++i,] = (.683950, .638793, .444251)
    RGB1[++i,] = (.687957, .641966, .442886)
    RGB1[++i,] = (.691971, .645145, .441491)
    RGB1[++i,] = (.695985, .648334, .440072)
    RGB1[++i,] = (.700008, .651529, .438624)
    RGB1[++i,] = (.704037, .654731, .437147)
    RGB1[++i,] = (.708067, .657942, .435647)
    RGB1[++i,] = (.712105, .661160, .434117)
    RGB1[++i,] = (.716177, .664384, .432386)
    RGB1[++i,] = (.720222, .667618, .430805)
    RGB1[++i,] = (.724274, .670859, .429194)
    RGB1[++i,] = (.728334, .674107, .427554)
    RGB1[++i,] = (.732422, .677364, .425717)
    RGB1[++i,] = (.736488, .680629, .424028)
    RGB1[++i,] = (.740589, .683900, .422131)
    RGB1[++i,] = (.744664, .687181, .420393)
    RGB1[++i,] = (.748772, .690470, .418448)
    RGB1[++i,] = (.752886, .693766, .416472)
    RGB1[++i,] = (.756975, .697071, .414659)
    RGB1[++i,] = (.761096, .700384, .412638)
    RGB1[++i,] = (.765223, .703705, .410587)
    RGB1[++i,] = (.769353, .707035, .408516)
    RGB1[++i,] = (.773486, .710373, .406422)
    RGB1[++i,] = (.777651, .713719, .404112)
    RGB1[++i,] = (.781795, .717074, .401966)
    RGB1[++i,] = (.785965, .720438, .399613)
    RGB1[++i,] = (.790116, .723810, .397423)
    RGB1[++i,] = (.794298, .727190, .395016)
    RGB1[++i,] = (.798480, .730580, .392597)
    RGB1[++i,] = (.802667, .733978, .390153)
    RGB1[++i,] = (.806859, .737385, .387684)
    RGB1[++i,] = (.811054, .740801, .385198)
    RGB1[++i,] = (.815274, .744226, .382504)
    RGB1[++i,] = (.819499, .747659, .379785)
    RGB1[++i,] = (.823729, .751101, .377043)
    RGB1[++i,] = (.827959, .754553, .374292)
    RGB1[++i,] = (.832192, .758014, .371529)
    RGB1[++i,] = (.836429, .761483, .368747)
    RGB1[++i,] = (.840693, .764962, .365746)
    RGB1[++i,] = (.844957, .768450, .362741)
    RGB1[++i,] = (.849223, .771947, .359729)
    RGB1[++i,] = (.853515, .775454, .356500)
    RGB1[++i,] = (.857809, .778969, .353259)
    RGB1[++i,] = (.862105, .782494, .350011)
    RGB1[++i,] = (.866421, .786028, .346571)
    RGB1[++i,] = (.870717, .789572, .343333)
    RGB1[++i,] = (.875057, .793125, .339685)
    RGB1[++i,] = (.879378, .796687, .336241)
    RGB1[++i,] = (.883720, .800258, .332599)
    RGB1[++i,] = (.888081, .803839, .328770)
    RGB1[++i,] = (.892440, .807430, .324968)
    RGB1[++i,] = (.896818, .811030, .320982)
    RGB1[++i,] = (.901195, .814639, .317021)
    RGB1[++i,] = (.905589, .818257, .312889)
    RGB1[++i,] = (.910000, .821885, .308594)
    RGB1[++i,] = (.914407, .825522, .304348)
    RGB1[++i,] = (.918828, .829168, .299960)
    RGB1[++i,] = (.923279, .832822, .295244)
    RGB1[++i,] = (.927724, .836486, .290611)
    RGB1[++i,] = (.932180, .840159, .285880)
    RGB1[++i,] = (.936660, .843841, .280876)
    RGB1[++i,] = (.941147, .847530, .275815)
    RGB1[++i,] = (.945654, .851228, .270532)
    RGB1[++i,] = (.950178, .854933, .265085)
    RGB1[++i,] = (.954725, .858646, .259365)
    RGB1[++i,] = (.959284, .862365, .253563)
    RGB1[++i,] = (.963872, .866089, .247445)
    RGB1[++i,] = (.968469, .869819, .241310)
    RGB1[++i,] = (.973114, .873550, .234677)
    RGB1[++i,] = (.977780, .877281, .227954)
    RGB1[++i,] = (.982497, .881008, .220878)
    RGB1[++i,] = (.987293, .884718, .213336)
    RGB1[++i,] = (.992218, .888385, .205468)
    RGB1[++i,] = (.994847, .892954, .203445)
    RGB1[++i,] = (.995249, .898384, .207561)
    RGB1[++i,] = (.995503, .903866, .212370)
    RGB1[++i,] = (.995737, .909344, .217772)
}

void `MAIN'::twilight(`RM' RGB1)
{
    `Int' i
    
    i = 0
    RGB1 = J(510, 3 ,.)
    RGB1[++i,] = (.88575015840754434, .85000924943067835 , .8879736506427196)
    RGB1[++i,] = (.88378520195539056, .85072940540310626 , .88723222096949894)
    RGB1[++i,] = (.88172231059285788, .85127594077653468 , .88638056925514819)
    RGB1[++i,] = (.8795410528270573 , .85165675407495722 , .8854143767924102)
    RGB1[++i,] = (.87724880858965482, .85187028338870274 , .88434120381311432)
    RGB1[++i,] = (.87485347508575972, .85191526123023187 , .88316926967613829)
    RGB1[++i,] = (.87233134085124076, .85180165478080894 , .88189704355001619)
    RGB1[++i,] = (.86970474853509816, .85152403004797894 , .88053883390003362)
    RGB1[++i,] = (.86696015505333579, .8510896085314068  , .87909766977173343)
    RGB1[++i,] = (.86408985081463996, .85050391167507788 , .87757925784892632)
    RGB1[++i,] = (.86110245436899846, .84976754857001258 , .87599242923439569)
    RGB1[++i,] = (.85798259245670372, .84888934810281835 , .87434038553446281)
    RGB1[++i,] = (.85472593189256985, .84787488124672816 , .8726282980930582)
    RGB1[++i,] = (.85133714570857189, .84672735796116472 , .87086081657350445)
    RGB1[++i,] = (.84780710702577922, .8454546229209523  , .86904036783694438)
    RGB1[++i,] = (.8441261828674842 , .84406482711037389 , .86716973322690072)
    RGB1[++i,] = (.84030420805957784, .8425605950855084  , .865250882410458)
    RGB1[++i,] = (.83634031809191178, .84094796518951942 , .86328528001070159)
    RGB1[++i,] = (.83222705712934408, .83923490627754482 , .86127563500427884)
    RGB1[++i,] = (.82796894316013536, .83742600751395202 , .85922399451306786)
    RGB1[++i,] = (.82357429680252847, .83552487764795436 , .85713191328514948)
    RGB1[++i,] = (.81904654677937527, .8335364929949034  , .85500206287010105)
    RGB1[++i,] = (.81438982121143089, .83146558694197847 , .85283759062147024)
    RGB1[++i,] = (.8095999819094809 , .82931896673505456 , .85064441601050367)
    RGB1[++i,] = (.80469164429814577, .82709838780560663 , .84842449296974021)
    RGB1[++i,] = (.79967075421267997, .82480781812080928 , .84618210029578533)
    RGB1[++i,] = (.79454305089231114, .82245116226304615 , .84392184786827984)
    RGB1[++i,] = (.78931445564608915, .82003213188702007 , .8416486380471222)
    RGB1[++i,] = (.78399101042764918, .81755426400533426 , .83936747464036732)
    RGB1[++i,] = (.77857892008227592, .81502089378742548 , .8370834463093898)
    RGB1[++i,] = (.77308416590170936, .81243524735466011 , .83480172950579679)
    RGB1[++i,] = (.76751108504417864, .8098007598713145  , .83252816638059668)
    RGB1[++i,] = (.76186907937980286, .80711949387647486 , .830266486168872)
    RGB1[++i,] = (.75616443584381976, .80439408733477935 , .82802138994719998)
    RGB1[++i,] = (.75040346765406696, .80162699008965321 , .82579737851082424)
    RGB1[++i,] = (.74459247771890169, .79882047719583249 , .82359867586156521)
    RGB1[++i,] = (.73873771700494939, .79597665735031009 , .82142922780433014)
    RGB1[++i,] = (.73284543645523459, .79309746468844067 , .81929263384230377)
    RGB1[++i,] = (.72692177512829703, .7901846863592763  , .81719217466726379)
    RGB1[++i,] = (.72097280665536778, .78723995923452639 , .81513073920879264)
    RGB1[++i,] = (.71500403076252128, .78426487091581187 , .81311116559949914)
    RGB1[++i,] = (.70902078134539304, .78126088716070907 , .81113591855117928)
    RGB1[++i,] = (.7030297722540817 , .77822904973358131 , .80920618848056969)
    RGB1[++i,] = (.6970365443886174 , .77517050008066057 , .80732335380063447)
    RGB1[++i,] = (.69104641009309098, .77208629460678091 , .80548841690679074)
    RGB1[++i,] = (.68506446154395928, .7689774029354699  , .80370206267176914)
    RGB1[++i,] = (.67909554499882152, .76584472131395898 , .8019646617300199)
    RGB1[++i,] = (.67314422559426212, .76268908733890484 , .80027628545809526)
    RGB1[++i,] = (.66721479803752815, .7595112803730375  , .79863674654537764)
    RGB1[++i,] = (.6613112930078745 , .75631202708719025 , .7970456043491897)
    RGB1[++i,] = (.65543692326454717, .75309208756768431 , .79550271129031047)
    RGB1[++i,] = (.64959573004253479, .74985201221941766 , .79400674021499107)
    RGB1[++i,] = (.6437910831099849 , .7465923800833657  , .79255653201306053)
    RGB1[++i,] = (.63802586828545982, .74331376714033193 , .79115100459573173)
    RGB1[++i,] = (.6323027138710603 , .74001672160131404 , .78978892762640429)
    RGB1[++i,] = (.62662402022604591, .73670175403699445 , .78846901316334561)
    RGB1[++i,] = (.62099193064817548, .73336934798923203 , .78718994624696581)
    RGB1[++i,] = (.61540846411770478, .73001995232739691 , .78595022706750484)
    RGB1[++i,] = (.60987543176093062, .72665398759758293 , .78474835732694714)
    RGB1[++i,] = (.60439434200274855, .7232718614323369  , .78358295593535587)
    RGB1[++i,] = (.5989665814482068 , .71987394892246725 , .78245259899346642)
    RGB1[++i,] = (.59359335696837223, .7164606049658685  , .78135588237640097)
    RGB1[++i,] = (.58827579780555495, .71303214646458135 , .78029141405636515)
    RGB1[++i,] = (.58301487036932409, .70958887676997473 , .77925781820476592)
    RGB1[++i,] = (.5778116438998202 , .70613106157153982 , .77825345121025524)
    RGB1[++i,] = (.5726668948158774 , .7026589535425779  , .77727702680911992)
    RGB1[++i,] = (.56758117853861967, .69917279302646274 , .77632748534275298)
    RGB1[++i,] = (.56255515357219343, .69567278381629649 , .77540359142309845)
    RGB1[++i,] = (.55758940419605174, .69215911458254054 , .7745041337932782)
    RGB1[++i,] = (.55268450589347129, .68863194515166382 , .7736279426902245)
    RGB1[++i,] = (.54784098153018634, .68509142218509878 , .77277386473440868)
    RGB1[++i,] = (.54305932424018233, .68153767253065878 , .77194079697835083)
    RGB1[++i,] = (.53834015575176275, .67797081129095405 , .77112734439057717)
    RGB1[++i,] = (.53368389147728401, .67439093705212727 , .7703325054879735)
    RGB1[++i,] = (.529090861832473  , .67079812302806219 , .76955552292313134)
    RGB1[++i,] = (.52456151470593582, .66719242996142225 , .76879541714230948)
    RGB1[++i,] = (.52009627392235558, .66357391434030388 , .76805119403344102)
    RGB1[++i,] = (.5156955988596057 , .65994260812897998 , .76732191489596169)
    RGB1[++i,] = (.51135992541601927, .65629853981831865 , .76660663780645333)
    RGB1[++i,] = (.50708969576451657, .65264172403146448 , .76590445660835849)
    RGB1[++i,] = (.5028853540415561 , .64897216734095264 , .76521446718174913)
    RGB1[++i,] = (.49874733661356069, .6452898684900934  , .76453578734180083)
    RGB1[++i,] = (.4946761847863938 , .64159484119504429 , .76386719002130909)
    RGB1[++i,] = (.49067224938561221, .63788704858847078 , .76320812763163837)
    RGB1[++i,] = (.4867359599430568 , .63416646251100506 , .76255780085924041)
    RGB1[++i,] = (.4828677867260272 , .6304330455306234  , .76191537149895305)
    RGB1[++i,] = (.47906816236197386, .62668676251860134 , .76128000375662419)
    RGB1[++i,] = (.47533752394906287, .62292757283835809 , .76065085571817748)
    RGB1[++i,] = (.47167629518877091, .61915543242884641 , .76002709227883047)
    RGB1[++i,] = (.46808490970531597, .61537028695790286 , .75940789891092741)
    RGB1[++i,] = (.46456376716303932, .61157208822864151 , .75879242623025811)
    RGB1[++i,] = (.46111326647023881, .607760777169989   , .75817986436807139)
    RGB1[++i,] = (.45773377230160567, .60393630046586455 , .75756936901859162)
    RGB1[++i,] = (.45442563977552913, .60009859503858665 , .75696013660606487)
    RGB1[++i,] = (.45118918687617743, .59624762051353541 , .75635120643246645)
    RGB1[++i,] = (.44802470933589172, .59238331452146575 , .75574176474107924)
    RGB1[++i,] = (.44493246854215379, .5885055998308617  , .7551311041857901)
    RGB1[++i,] = (.44191271766696399, .58461441100175571 , .75451838884410671)
    RGB1[++i,] = (.43896563958048396, .58070969241098491 , .75390276208285945)
    RGB1[++i,] = (.43609138958356369, .57679137998186081 , .7532834105961016)
    RGB1[++i,] = (.43329008867358393, .57285941625606673 , .75265946532566674)
    RGB1[++i,] = (.43056179073057571, .56891374572457176 , .75203008099312696)
    RGB1[++i,] = (.42790652284925834, .5649543060909209  , .75139443521914839)
    RGB1[++i,] = (.42532423665011354, .56098104959950301 , .75075164989005116)
    RGB1[++i,] = (.42281485675772662, .55699392126996583 , .75010086988227642)
    RGB1[++i,] = (.42037822361396326, .55299287158108168 , .7494412559451894)
    RGB1[++i,] = (.41801414079233629, .54897785421888889 , .74877193167001121)
    RGB1[++i,] = (.4157223260454232 , .54494882715350401 , .74809204459000522)
    RGB1[++i,] = (.41350245743314729, .54090574771098476 , .74740073297543086)
    RGB1[++i,] = (.41135414697304568, .53684857765005933 , .74669712855065784)
    RGB1[++i,] = (.4092768899914751 , .53277730177130322 , .74598030635707824)
    RGB1[++i,] = (.40727018694219069, .52869188011057411 , .74524942637581271)
    RGB1[++i,] = (.40533343789303178, .52459228174983119 , .74450365836708132)
    RGB1[++i,] = (.40346600333905397, .52047847653840029 , .74374215223567086)
    RGB1[++i,] = (.40166714010896104, .51635044969688759 , .7429640345324835)
    RGB1[++i,] = (.39993606933454834, .51220818143218516 , .74216844571317986)
    RGB1[++i,] = (.3982719152586337 , .50805166539276136 , .74135450918099721)
    RGB1[++i,] = (.39667374905665609, .50388089053847973 , .74052138580516735)
    RGB1[++i,] = (.39514058808207631, .49969585326377758 , .73966820211715711)
    RGB1[++i,] = (.39367135736822567, .49549655777451179 , .738794102296364)
    RGB1[++i,] = (.39226494876209317, .49128300332899261 , .73789824784475078)
    RGB1[++i,] = (.39092017571994903, .48705520251223039 , .73697977133881254)
    RGB1[++i,] = (.38963580160340855, .48281316715123496 , .73603782546932739)
    RGB1[++i,] = (.38841053300842432, .47855691131792805 , .73507157641157261)
    RGB1[++i,] = (.38724301459330251, .47428645933635388 , .73408016787854391)
    RGB1[++i,] = (.38613184178892102, .4700018340988123  , .7330627749243106)
    RGB1[++i,] = (.38507556793651387, .46570306719930193 , .73201854033690505)
    RGB1[++i,] = (.38407269378943537, .46139018782416635 , .73094665432902683)
    RGB1[++i,] = (.38312168084402748, .45706323581407199 , .72984626791353258)
    RGB1[++i,] = (.38222094988570376, .45272225034283325 , .72871656144003782)
    RGB1[++i,] = (.38136887930454161, .44836727669277859 , .72755671317141346)
    RGB1[++i,] = (.38056380696565623, .44399837208633719 , .72636587045135315)
    RGB1[++i,] = (.37980403744848751, .43961558821222629 , .72514323778761092)
    RGB1[++i,] = (.37908789283110761, .43521897612544935 , .72388798691323131)
    RGB1[++i,] = (.378413635091359  , .43080859411413064 , .72259931993061044)
    RGB1[++i,] = (.37777949753513729, .4263845142616835  , .72127639993530235)
    RGB1[++i,] = (.37718371844251231, .42194680223454828 , .71991841524475775)
    RGB1[++i,] = (.37662448930806297, .41749553747893614 , .71852454736176108)
    RGB1[++i,] = (.37610001286385814, .41303079952477062 , .71709396919920232)
    RGB1[++i,] = (.37560846919442398, .40855267638072096 , .71562585091587549)
    RGB1[++i,] = (.37514802505380473, .4040612609993941  , .7141193695725726)
    RGB1[++i,] = (.37471686019302231, .3995566498711684  , .71257368516500463)
    RGB1[++i,] = (.37431313199312338, .39503894828283309 , .71098796522377461)
    RGB1[++i,] = (.37393499330475782, .39050827529375831 , .70936134293478448)
    RGB1[++i,] = (.3735806215098284 , .38596474386057539 , .70769297607310577)
    RGB1[++i,] = (.37324816143326384, .38140848555753937 , .70598200974806036)
    RGB1[++i,] = (.37293578646665032, .37683963835219841 , .70422755780589941)
    RGB1[++i,] = (.37264166757849604, .37225835004836849 , .7024287314570723)
    RGB1[++i,] = (.37236397858465387, .36766477862108266 , .70058463496520773)
    RGB1[++i,] = (.37210089702443822, .36305909736982378 , .69869434615073722)
    RGB1[++i,] = (.3718506155898596 , .35844148285875221 , .69675695810256544)
    RGB1[++i,] = (.37161133234400479, .3538121372967869  , .69477149919380887)
    RGB1[++i,] = (.37138124223736607, .34917126878479027 , .69273703471928827)
    RGB1[++i,] = (.37115856636209105, .34451911410230168 , .69065253586464992)
    RGB1[++i,] = (.37094151551337329, .33985591488818123 , .68851703379505125)
    RGB1[++i,] = (.37072833279422668, .33518193808489577 , .68632948169606767)
    RGB1[++i,] = (.37051738634484427, .33049741244307851 , .68408888788857214)
    RGB1[++i,] = (.37030682071842685, .32580269697872455 , .68179411684486679)
    RGB1[++i,] = (.37009487130772695, .3210981375964933  , .67944405399056851)
    RGB1[++i,] = (.36987980329025361, .31638410101153364 , .67703755438090574)
    RGB1[++i,] = (.36965987626565955, .31166098762951971 , .67457344743419545)
    RGB1[++i,] = (.36943334591276228, .30692923551862339 , .67205052849120617)
    RGB1[++i,] = (.36919847837592484, .30218932176507068 , .66946754331614522)
    RGB1[++i,] = (.36895355306596778, .29744175492366276 , .66682322089824264)
    RGB1[++i,] = (.36869682231895268, .29268709856150099 , .66411625298236909)
    RGB1[++i,] = (.36842655638020444, .28792596437778462 , .66134526910944602)
    RGB1[++i,] = (.36814101479899719, .28315901221182987 , .65850888806972308)
    RGB1[++i,] = (.36783843696531082, .27838697181297761 , .65560566838453704)
    RGB1[++i,] = (.36751707094367697, .27361063317090978 , .65263411711618635)
    RGB1[++i,] = (.36717513650699446, .26883085667326956 , .64959272297892245)
    RGB1[++i,] = (.36681085540107988, .26404857724525643 , .64647991652908243)
    RGB1[++i,] = (.36642243251550632, .25926481158628106 , .64329409140765537)
    RGB1[++i,] = (.36600853966739794, .25448043878086224 , .64003361803368586)
    RGB1[++i,] = (.36556698373538982, .24969683475296395 , .63669675187488584)
    RGB1[++i,] = (.36509579845886808, .24491536803550484 , .63328173520055586)
    RGB1[++i,] = (.36459308890125008, .24013747024823828 , .62978680155026101)
    RGB1[++i,] = (.36405693022088509, .23536470386204195 , .62621013451953023)
    RGB1[++i,] = (.36348537610385145, .23059876218396419 , .62254988622392882)
    RGB1[++i,] = (.36287643560041027, .22584149293287031 , .61880417410823019)
    RGB1[++i,] = (.36222809558295926, .22109488427338303 , .61497112346096128)
    RGB1[++i,] = (.36153829010998356, .21636111429594002 , .61104880679640927)
    RGB1[++i,] = (.36080493826624654, .21164251793458128 , .60703532172064711)
    RGB1[++i,] = (.36002681809096376, .20694122817889948 , .60292845431916875)
    RGB1[++i,] = (.35920088560930186, .20226037920758122 , .5987265295935138)
    RGB1[++i,] = (.35832489966617809, .197602942459778   , .59442768517501066)
    RGB1[++i,] = (.35739663292915563, .19297208197842461 , .59003011251063131)
    RGB1[++i,] = (.35641381143126327, .18837119869242164 , .5855320765920552)
    RGB1[++i,] = (.35537415306906722, .18380392577704466 , .58093191431832802)
    RGB1[++i,] = (.35427534960663759, .17927413271618647 , .57622809660668717)
    RGB1[++i,] = (.35311574421123737, .17478570377561287 , .57141871523555288)
    RGB1[++i,] = (.35189248608873791, .17034320478524959 , .56650284911216653)
    RGB1[++i,] = (.35060304441931012, .16595129984720861 , .56147964703993225)
    RGB1[++i,] = (.34924513554955644, .16161477763045118 , .55634837474163779)
    RGB1[++i,] = (.34781653238777782, .15733863511152979 , .55110853452703257)
    RGB1[++i,] = (.34631507175793091, .15312802296627787 , .5457599924248665)
    RGB1[++i,] = (.34473901574536375, .14898820589826409 , .54030245920406539)
    RGB1[++i,] = (.34308600291572294, .14492465359918028 , .53473704282067103)
    RGB1[++i,] = (.34135411074506483, .1409427920655632  , .52906500940336754)
    RGB1[++i,] = (.33954168752669694, .13704801896718169 , .52328797535085236)
    RGB1[++i,] = (.33764732090671112, .13324562282438077 , .51740807573979475)
    RGB1[++i,] = (.33566978565015315, .12954074251271822 , .51142807215168951)
    RGB1[++i,] = (.33360804901486002, .12593818301005921 , .50535164796654897)
    RGB1[++i,] = (.33146154891145124, .12244245263391232 , .49918274588431072)
    RGB1[++i,] = (.32923005203231409, .11905764321981127 , .49292595612342666)
    RGB1[++i,] = (.3269137124539796 , .1157873496841953  , .48658646495697461)
    RGB1[++i,] = (.32451307931207785, .11263459791730848 , .48017007211645196)
    RGB1[++i,] = (.32202882276069322, .10960114111258401 , .47368494725726878)
    RGB1[++i,] = (.31946262395497965, .10668879882392659 , .46713728801395243)
    RGB1[++i,] = (.31681648089023501, .10389861387653518 , .46053414662739794)
    RGB1[++i,] = (.31409278414755532, .10123077676403242 , .45388335612058467)
    RGB1[++i,] = (.31129434479712365, .098684771934052201, .44719313715161618)
    RGB1[++i,] = (.30842444457210105, .096259385340577736, .44047194882050544)
    RGB1[++i,] = (.30548675819945936, .093952764840823738, .43372849999361113)
    RGB1[++i,] = (.30248536364574252, .091761187397303601, .42697404043749887)
    RGB1[++i,] = (.29942483960214772, .089682253716750038, .42021619665853854)
    RGB1[++i,] = (.29631000388905288, .087713250960463951, .41346259134143476)
    RGB1[++i,] = (.29314593096985248, .085850656889620708, .40672178082365834)
    RGB1[++i,] = (.28993792445176608, .08409078829085731 , .40000214725256295)
    RGB1[++i,] = (.28669151388283165, .082429873848480689, .39331182532243375)
    RGB1[++i,] = (.28341239797185225, .080864153365499375, .38665868550105914)
    RGB1[++i,] = (.28010638576975472, .079389994802261526, .38005028528138707)
    RGB1[++i,] = (.27677939615815589, .078003941033788216, .37349382846504675)
    RGB1[++i,] = (.27343739342450812, .076702800237496066, .36699616136347685)
    RGB1[++i,] = (.27008637749114051, .075483675584275545, .36056376228111864)
    RGB1[++i,] = (.26673233211995284, .074344018028546205, .35420276066240958)
    RGB1[++i,] = (.26338121807151404, .073281657939897077, .34791888996380105)
    RGB1[++i,] = (.26003895187439957, .072294781043362205, .3417175669546984)
    RGB1[++i,] = (.25671191651083902, .071380106242082242, .33560648984600089)
    RGB1[++i,] = (.25340685873736807, .070533582926851829, .3295945757321303)
    RGB1[++i,] = (.25012845306199383, .069758206429106989, .32368100685760637)
    RGB1[++i,] = (.24688226237958999, .069053639449204451, .31786993834254956)
    RGB1[++i,] = (.24367372557466271, .068419855150922693, .31216524050888372)
    RGB1[++i,] = (.24050813332295939, .067857103814855602, .30657054493678321)
    RGB1[++i,] = (.23739062429054825, .067365888050555517, .30108922184065873)
    RGB1[++i,] = (.23433055727563878, .066935599661639394, .29574009929867601)
    RGB1[++i,] = (.23132955273021344, .066576186939090592, .29051361067988485)
    RGB1[++i,] = (.2283917709422868 , .06628997924139618 , .28541074411068496)
    RGB1[++i,] = (.22552164337737857, .066078173119395595, .28043398847505197)
    RGB1[++i,] = (.22272706739121817, .065933790675651943, .27559714652053702)
    RGB1[++i,] = (.22001251100779617, .065857918918907604, .27090279994325861)
    RGB1[++i,] = (.21737845072382705, .065859661233562045, .26634209349669508)
    RGB1[++i,] = (.21482843531473683, .065940385613778491, .26191675992376573)
    RGB1[++i,] = (.21237411048541005, .066085024661758446, .25765165093569542)
    RGB1[++i,] = (.21001214221188125, .066308573918947178, .2535289048041211)
    RGB1[++i,] = (.2077442377448806 , .06661453200418091 , .24954644291943817)
    RGB1[++i,] = (.20558051999470117, .066990462397868739, .24572497420147632)
    RGB1[++i,] = (.20352007949514977, .067444179612424215, .24205576625191821)
    RGB1[++i,] = (.20156133764129841, .067983271026200248, .23852974228695395)
    RGB1[++i,] = (.19971571438603364, .068592710553704722, .23517094067076993)
    RGB1[++i,] = (.19794834061899208, .069314066071660657, .23194647381302336)
    RGB1[++i,] = (.1960826032659409 , .070321227242423623, .22874673279569585)
    RGB1[++i,] = (.19410351363791453, .071608304856891569, .22558727307410353)
    RGB1[++i,] = (.19199449184606268, .073182830649273306, .22243385243433622)
    RGB1[++i,] = (.18975853639094634, .075019861862143766, .2193005075652994)
    RGB1[++i,] = (.18739228342697645, .077102096899588329, .21618875376309582)
    RGB1[++i,] = (.18488035509396164, .079425730279723883, .21307651648984993)
    RGB1[++i,] = (.18774482037046955, .077251588468039312, .21387448578597812)
    RGB1[++i,] = (.19049578401722037, .075311278416787641, .2146562337112265)
    RGB1[++i,] = (.1931548636579131 , .073606819040117955, .21542362939081539)
    RGB1[++i,] = (.19571853588267552, .072157781039602742, .21617499187076789)
    RGB1[++i,] = (.19819343656336558, .070974625252738788, .21690975060032436)
    RGB1[++i,] = (.20058760685133747, .070064576149984209, .21762721310371608)
    RGB1[++i,] = (.20290365333558247, .069435248580458964, .21833167885096033)
    RGB1[++i,] = (.20531725273301316, .068919592266397572, .21911516689288835)
    RGB1[++i,] = (.20785704662965598, .068484398797025281, .22000133917653536)
    RGB1[++i,] = (.21052882914958676, .06812195249816172 , .22098759107715404)
    RGB1[++i,] = (.2133313859647627 , .067830148426026665, .22207043213024291)
    RGB1[++i,] = (.21625279838647882, .067616330270516389, .22324568672294431)
    RGB1[++i,] = (.21930503925136402, .067465786362940039, .22451023616807558)
    RGB1[++i,] = (.22247308588973624, .067388214053092838, .22585960379408354)
    RGB1[++i,] = (.2257539681670791 , .067382132300147474, .22728984778098055)
    RGB1[++i,] = (.22915620278592841, .067434730871152565, .22879681433956656)
    RGB1[++i,] = (.23266299920501882, .067557104388479783, .23037617493752832)
    RGB1[++i,] = (.23627495835774248, .06774359820987802 , .23202360805926608)
    RGB1[++i,] = (.23999586188690308, .067985029964779953, .23373434258507808)
    RGB1[++i,] = (.24381149720247919, .068289851529011875, .23550427698321885)
    RGB1[++i,] = (.24772092990501099, .068653337909486523, .2373288009471749)
    RGB1[++i,] = (.25172899728289466, .069064630826035506, .23920260612763083)
    RGB1[++i,] = (.25582135547481771, .06953231029187984 , .24112190491594204)
    RGB1[++i,] = (.25999463887892144, .070053855603861875, .24308218808684579)
    RGB1[++i,] = (.26425512207060942, .070616595622995437, .24507758869355967)
    RGB1[++i,] = (.26859095948172862, .071226716277922458, .24710443563450618)
    RGB1[++i,] = (.27299701518897301, .071883555446163511, .24915847093232929)
    RGB1[++i,] = (.27747150809142801, .072582969899254779, .25123493995942769)
    RGB1[++i,] = (.28201746297366942, .073315693214040967, .25332800295084507)
    RGB1[++i,] = (.28662309235899847, .074088460826808866, .25543478673717029)
    RGB1[++i,] = (.29128515387578635, .074899049847466703, .25755101595750435)
    RGB1[++i,] = (.2960004726065818 , .075745336000958424, .25967245030364566)
    RGB1[++i,] = (.30077276812918691, .076617824336164764, .26179294097819672)
    RGB1[++i,] = (.30559226007249934, .077521963107537312, .26391006692119662)
    RGB1[++i,] = (.31045520848595526, .078456871676182177, .2660200572779356)
    RGB1[++i,] = (.31535870009205808, .079420997315243186, .26811904076941961)
    RGB1[++i,] = (.32029986557994061, .080412994737554838, .27020322893039511)
    RGB1[++i,] = (.32527888860401261, .081428390076546092, .27226772884656186)
    RGB1[++i,] = (.33029174471181438, .08246763389003825 , .27430929404579435)
    RGB1[++i,] = (.33533353224455448, .083532434119003962, .27632534356790039)
    RGB1[++i,] = (.34040164359597463, .084622236191702671, .27831254595259397)
    RGB1[++i,] = (.34549355713871799, .085736654965126335, .28026769921081435)
    RGB1[++i,] = (.35060678246032478, .08687555176033529 , .28218770540182386)
    RGB1[++i,] = (.35573889947341125, .088038974350243354, .2840695897279818)
    RGB1[++i,] = (.36088752387578377, .089227194362745205, .28591050458531014)
    RGB1[++i,] = (.36605031412464006, .090440685427697898, .2877077458811747)
    RGB1[++i,] = (.37122508431309342, .091679997480262732, .28945865397633169)
    RGB1[++i,] = (.3764103053221462 , .092945198093777909, .29116024157313919)
    RGB1[++i,] = (.38160247377467543, .094238731263712183, .29281107506269488)
    RGB1[++i,] = (.38679939079544168, .09556181960083443 , .29440901248173756)
    RGB1[++i,] = (.39199887556812907, .09691583650296684 , .29595212005509081)
    RGB1[++i,] = (.39719876876325577, .098302320968278623, .29743856476285779)
    RGB1[++i,] = (.40239692379737496, .099722930314950553, .29886674369733968)
    RGB1[++i,] = (.40759120392688708, .10117945586419633 , .30023519507728602)
    RGB1[++i,] = (.41277985630360303, .1026734006932461  , .30154226437468967)
    RGB1[++i,] = (.41796105205173684, .10420644885760968 , .30278652039631843)
    RGB1[++i,] = (.42313214269556043, .10578120994917611 , .3039675809469457)
    RGB1[++i,] = (.42829101315789753, .1073997763055258  , .30508479060294547)
    RGB1[++i,] = (.4334355841041439 , .1090642347484701  , .30613767928289148)
    RGB1[++i,] = (.43856378187931538, .11077667828375456 , .30712600062348083)
    RGB1[++i,] = (.44367358645071275, .11253912421257944 , .30804973095465449)
    RGB1[++i,] = (.44876299173174822, .11435355574622549 , .30890905921943196)
    RGB1[++i,] = (.45383005086999889, .11622183788331528 , .30970441249844921)
    RGB1[++i,] = (.45887288947308297, .11814571137706886 , .31043636979038808)
    RGB1[++i,] = (.46389102840284874, .12012561256850712 , .31110343446582983)
    RGB1[++i,] = (.46888111384598413, .12216445576414045 , .31170911458932665)
    RGB1[++i,] = (.473841437035254  , .12426354237989065 , .31225470169927194)
    RGB1[++i,] = (.47877034239726296, .12642401401409453 , .31274172735821959)
    RGB1[++i,] = (.48366628618847957, .12864679022013889 , .31317188565991266)
    RGB1[++i,] = (.48852847371852987, .13093210934893723 , .31354553695453014)
    RGB1[++i,] = (.49335504375145617, .13328091630401023 , .31386561956734976)
    RGB1[++i,] = (.49814435462074153, .13569380302451714 , .314135190862664)
    RGB1[++i,] = (.50289524974970612, .13817086581280427 , .31435662153833671)
    RGB1[++i,] = (.50760681181053691, .14071192654913128 , .31453200120082569)
    RGB1[++i,] = (.51227835105321762, .14331656120063752 , .3146630922831542)
    RGB1[++i,] = (.51690848800544464, .14598463068714407 , .31475407592280041)
    RGB1[++i,] = (.52149652863229956, .14871544765633712 , .31480767954534428)
    RGB1[++i,] = (.52604189625477482, .15150818660835483 , .31482653406646727)
    RGB1[++i,] = (.53054420489856446, .15436183633886777 , .31481299789187128)
    RGB1[++i,] = (.5350027976174474 , .15727540775107324 , .31477085207396532)
    RGB1[++i,] = (.53941736649199057, .16024769309971934 , .31470295028655965)
    RGB1[++i,] = (.54378771313608565, .16327738551419116 , .31461204226295625)
    RGB1[++i,] = (.54811370033467621, .1663630904279047  , .31450102990914708)
    RGB1[++i,] = (.55239521572711914, .16950338809328983 , .31437291554615371)
    RGB1[++i,] = (.55663229034969341, .17269677158182117 , .31423043195101424)
    RGB1[++i,] = (.56082499039117173, .17594170887918095 , .31407639883970623)
    RGB1[++i,] = (.56497343529017696, .17923664950367169 , .3139136046337036)
    RGB1[++i,] = (.56907784784011428, .18258004462335425 , .31374440956796529)
    RGB1[++i,] = (.57313845754107873, .18597036007065024 , .31357126868520002)
    RGB1[++i,] = (.57715550812992045, .18940601489760422 , .31339704333572083)
    RGB1[++i,] = (.58112932761586555, .19288548904692518 , .31322399394183942)
    RGB1[++i,] = (.58506024396466882, .19640737049066315 , .31305401163732732)
    RGB1[++i,] = (.58894861935544707, .19997020971775276 , .31288922211590126)
    RGB1[++i,] = (.59279480536520257, .20357251410079796 , .31273234839304942)
    RGB1[++i,] = (.59659918109122367, .207212956082026   , .31258523031121233)
    RGB1[++i,] = (.60036213010411577, .21089030138947745 , .31244934410414688)
    RGB1[++i,] = (.60408401696732739, .21460331490206347 , .31232652641170694)
    RGB1[++i,] = (.60776523994818654, .21835070166659282 , .31221903291870201)
    RGB1[++i,] = (.6114062072731884 , .22213124697023234 , .31212881396435238)
    RGB1[++i,] = (.61500723236391375, .22594402043981826 , .31205680685765741)
    RGB1[++i,] = (.61856865258877192, .22978799249179921 , .31200463838728931)
    RGB1[++i,] = (.62209079821082613, .2336621873300741  , .31197383273627388)
    RGB1[++i,] = (.62557416500434959, .23756535071152696 , .31196698314912269)
    RGB1[++i,] = (.62901892016985872, .24149689191922535 , .31198447195645718)
    RGB1[++i,] = (.63242534854210275, .24545598775548677 , .31202765974624452)
    RGB1[++i,] = (.6357937104834237 , .24944185818822678 , .31209793953300591)
    RGB1[++i,] = (.6391243387840212 , .25345365461983138 , .31219689612063978)
    RGB1[++i,] = (.642417577481186  , .257490519876798   , .31232631707560987)
    RGB1[++i,] = (.64567349382645434, .26155203161615281 , .31248673753935263)
    RGB1[++i,] = (.64889230169458245, .26563755336209077 , .31267941819570189)
    RGB1[++i,] = (.65207417290277303, .26974650525236699 , .31290560605819168)
    RGB1[++i,] = (.65521932609327127, .27387826652410152 , .3131666792687211)
    RGB1[++i,] = (.6583280801134499 , .27803210957665631 , .3134643447952643)
    RGB1[++i,] = (.66140037532601781, .28220778870555907 , .31379912926498488)
    RGB1[++i,] = (.66443632469878844, .28640483614256179 , .31417223403606975)
    RGB1[++i,] = (.66743603766369131, .29062280081258873 , .31458483752056837)
    RGB1[++i,] = (.67039959547676198, .29486126309253047 , .31503813956872212)
    RGB1[++i,] = (.67332725564817331, .29911962764489264 , .31553372323982209)
    RGB1[++i,] = (.67621897924409746, .30339762792450425 , .3160724937230589)
    RGB1[++i,] = (.67907474028157344, .30769497879760166 , .31665545668946665)
    RGB1[++i,] = (.68189457150944521, .31201133280550686 , .31728380489244951)
    RGB1[++i,] = (.68467850942494535, .31634634821222207 , .31795870784057567)
    RGB1[++i,] = (.68742656435169625, .32069970535138104 , .31868137622277692)
    RGB1[++i,] = (.6901389321505248 , .32507091815606004 , .31945332332898302)
    RGB1[++i,] = (.69281544846764931, .32945984647042675 , .3202754315314667)
    RGB1[++i,] = (.69545608346891119, .33386622163232865 , .32114884306985791)
    RGB1[++i,] = (.6980608153581771 , .33828976326048621 , .32207478855218091)
    RGB1[++i,] = (.70062962477242097, .34273019305341756 , .32305449047765694)
    RGB1[++i,] = (.70316249458814151, .34718723719597999 , .32408913679491225)
    RGB1[++i,] = (.70565951122610093, .35166052978120937 , .32518014084085567)
    RGB1[++i,] = (.70812059568420482, .35614985523380299 , .32632861885644465)
    RGB1[++i,] = (.7105456546582587 , .36065500290840113 , .32753574162788762)
    RGB1[++i,] = (.71293466839773467, .36517570519856757 , .3288027427038317)
    RGB1[++i,] = (.71528760614847287, .36971170225223449 , .3301308728723546)
    RGB1[++i,] = (.71760444908133847, .37426272710686193 , .33152138620958932)
    RGB1[++i,] = (.71988521490549851, .37882848839337313 , .33297555200245399)
    RGB1[++i,] = (.7221299918421461 , .38340864508963057 , .33449469983585844)
    RGB1[++i,] = (.72433865647781592, .38800301593162145 , .33607995965691828)
    RGB1[++i,] = (.72651122900227549, .3926113126792577  , .3377325942005665)
    RGB1[++i,] = (.72864773856716547, .39723324476747235 , .33945384341064017)
    RGB1[++i,] = (.73074820754845171, .401868526884681   , .3412449533046818)
    RGB1[++i,] = (.73281270506268747, .4065168468778026  , .34310715173410822)
    RGB1[++i,] = (.73484133598564938, .41117787004519513 , .34504169470809071)
    RGB1[++i,] = (.73683422173585866, .41585125850290111 , .34704978520758401)
    RGB1[++i,] = (.73879140024599266, .42053672992315327 , .34913260148542435)
    RGB1[++i,] = (.74071301619506091, .4252339389526239  , .35129130890802607)
    RGB1[++i,] = (.7425992159973317 , .42994254036133867 , .35352709245374592)
    RGB1[++i,] = (.74445018676570673, .43466217184617112 , .35584108091122535)
    RGB1[++i,] = (.74626615789163442, .43939245044973502 , .35823439142300639)
    RGB1[++i,] = (.74804739275559562, .44413297780351974 , .36070813602540136)
    RGB1[++i,] = (.74979420547170472, .44888333481548809 , .36326337558360278)
    RGB1[++i,] = (.75150685045891663, .45364314496866825 , .36590112443835765)
    RGB1[++i,] = (.75318566369046569, .45841199172949604 , .36862236642234769)
    RGB1[++i,] = (.75483105066959544, .46318942799460555 , .3714280448394211)
    RGB1[++i,] = (.75644341577140706, .46797501437948458 , .37431909037543515)
    RGB1[++i,] = (.75802325538455839, .4727682731566229  , .37729635531096678)
    RGB1[++i,] = (.75957111105340058, .47756871222057079 , .380360657784311)
    RGB1[++i,] = (.7610876378057071 , .48237579130289127 , .38351275723852291)
    RGB1[++i,] = (.76257333554052609, .48718906673415824 , .38675335037837993)
    RGB1[++i,] = (.76402885609288662, .49200802533379656 , .39008308392311997)
    RGB1[++i,] = (.76545492593330511, .49683212909727231 , .39350254000115381)
    RGB1[++i,] = (.76685228950643891, .5016608471009063  , .39701221751773474)
    RGB1[++i,] = (.76822176599735303, .50649362371287909 , .40061257089416885)
    RGB1[++i,] = (.7695642334401418 , .5113298901696085  , .40430398069682483)
    RGB1[++i,] = (.77088091962302474, .51616892643469103 , .40808667584648967)
    RGB1[++i,] = (.77217257229605551, .5210102658711383  , .41196089987122869)
    RGB1[++i,] = (.77344021829889886, .52585332093451564 , .41592679539764366)
    RGB1[++i,] = (.77468494746063199, .53069749384776732 , .41998440356963762)
    RGB1[++i,] = (.77590790730685699, .53554217882461186 , .42413367909988375)
    RGB1[++i,] = (.7771103295521099 , .54038674910561235 , .42837450371258479)
    RGB1[++i,] = (.77829345807633121, .54523059488426595 , .432706647838971)
    RGB1[++i,] = (.77945862731506643, .55007308413977274 , .43712979856444761)
    RGB1[++i,] = (.78060774749483774, .55491335744890613 , .44164332426364639)
    RGB1[++i,] = (.78174180478981836, .55975098052594863 , .44624687186865436)
    RGB1[++i,] = (.78286225264440912, .56458533111166875 , .45093985823706345)
    RGB1[++i,] = (.78397060836414478, .56941578326710418 , .45572154742892063)
    RGB1[++i,] = (.78506845019606841, .5742417003617839  , .46059116206904965)
    RGB1[++i,] = (.78615737132332963, .5790624629815756  , .46554778281918402)
    RGB1[++i,] = (.78723904108188347, .58387743744557208 , .47059039582133383)
    RGB1[++i,] = (.78831514045623963, .58868600173562435 , .47571791879076081)
    RGB1[++i,] = (.78938737766251943, .5934875421745599  , .48092913815357724)
    RGB1[++i,] = (.79045776847727878, .59828134277062461 , .48622257801969754)
    RGB1[++i,] = (.79152832843475607, .60306670593147205 , .49159667021646397)
    RGB1[++i,] = (.79260034304237448, .60784322087037024 , .49705020621532009)
    RGB1[++i,] = (.79367559698664958, .61261029334072192 , .50258161291269432)
    RGB1[++i,] = (.79475585972654039, .61736734400220705 , .50818921213102985)
    RGB1[++i,] = (.79584292379583765, .62211378808451145 , .51387124091909786)
    RGB1[++i,] = (.79693854719951607, .62684905679296699 , .5196258425240281)
    RGB1[++i,] = (.79804447815136637, .63157258225089552 , .52545108144834785)
    RGB1[++i,] = (.7991624518501963 , .63628379372029187 , .53134495942561433)
    RGB1[++i,] = (.80029415389753977, .64098213306749863 , .53730535185141037)
    RGB1[++i,] = (.80144124292560048, .64566703459218766 , .5433300863249918)
    RGB1[++i,] = (.80260531146112946, .65033793748103852 , .54941691584603647)
    RGB1[++i,] = (.80378792531077625, .65499426549472628 , .55556350867083815)
    RGB1[++i,] = (.80499054790810298, .65963545027564163 , .56176745110546977)
    RGB1[++i,] = (.80621460526927058, .66426089585282289 , .56802629178649788)
    RGB1[++i,] = (.8074614045096935 , .6688700095398864  , .57433746373459582)
    RGB1[++i,] = (.80873219170089694, .67346216702194517 , .58069834805576737)
    RGB1[++i,] = (.81002809466520687, .67803672673971815 , .58710626908082753)
    RGB1[++i,] = (.81135014011763329, .68259301546243389 , .59355848909050757)
    RGB1[++i,] = (.81269922039881493, .68713033714618876 , .60005214820435104)
    RGB1[++i,] = (.81407611046993344, .69164794791482131 , .6065843782630862)
    RGB1[++i,] = (.81548146627279483, .69614505508308089 , .61315221209322646)
    RGB1[++i,] = (.81691575775055891, .70062083014783982 , .61975260637257923)
    RGB1[++i,] = (.81837931164498223, .70507438189635097 , .62638245478933297)
    RGB1[++i,] = (.81987230650455289, .70950474978787481 , .63303857040067113)
    RGB1[++i,] = (.8213947205565636 , .7139109141951604  , .63971766697672761)
    RGB1[++i,] = (.82294635110428427, .71829177331290062 , .6464164243818421)
    RGB1[++i,] = (.8245268129450285 , .72264614312088882 , .65313137915422603)
    RGB1[++i,] = (.82613549710580259, .72697275518238258 , .65985900156216504)
    RGB1[++i,] = (.8277716072353446 , .73127023324078089 , .66659570204682972)
    RGB1[++i,] = (.82943407816481474, .7355371221572935  , .67333772009301907)
    RGB1[++i,] = (.83112163529096306, .73977184647638616 , .68008125203631464)
    RGB1[++i,] = (.83283277185777982, .74397271817459876 , .68682235874648545)
    RGB1[++i,] = (.8345656905566583 , .7481379479992134  , .69355697649863846)
    RGB1[++i,] = (.83631898844737929, .75226548952875261 , .70027999028864962)
    RGB1[++i,] = (.83809123476131964, .75635314860808633 , .70698561390212977)
    RGB1[++i,] = (.83987839884120874, .76039907199779677 , .71367147811129228)
    RGB1[++i,] = (.84167750766845151, .76440101200982946 , .72033299387284622)
    RGB1[++i,] = (.84348529222933699, .76835660399870176 , .72696536998972039)
    RGB1[++i,] = (.84529810731955113, .77226338601044719 , .73356368240541492)
    RGB1[++i,] = (.84711195507965098, .77611880236047159 , .74012275762807056)
    RGB1[++i,] = (.84892245563117641, .77992021407650147 , .74663719293664366)
    RGB1[++i,] = (.85072697023178789, .78366457342383888 , .7530974636118285)
    RGB1[++i,] = (.85251907207708444, .78734936133548439 , .7594994148789691)
    RGB1[++i,] = (.85429219611470464, .79097196777091994 , .76583801477914104)
    RGB1[++i,] = (.85604022314725403, .79452963601550608 , .77210610037674143)
    RGB1[++i,] = (.85775662943504905, .79801963142713928 , .77829571667247499)
    RGB1[++i,] = (.8594346370300241 , .8014392309950078  , .78439788751383921)
    RGB1[++i,] = (.86107117027565516, .80478517909812231 , .79039529663736285)
    RGB1[++i,] = (.86265601051127572, .80805523804261525 , .796282666437655)
    RGB1[++i,] = (.86418343723941027, .81124644224653542 , .80204612696863953)
    RGB1[++i,] = (.86564934325605325, .81435544067514909 , .80766972324164554)
    RGB1[++i,] = (.86705314907048503, .81737804041911244 , .81313419626911398)
    RGB1[++i,] = (.86839954695818633, .82030875512181523 , .81841638963128993)
    RGB1[++i,] = (.86969131502613806, .82314158859569164 , .82350476683173168)
    RGB1[++i,] = (.87093846717297507, .82586857889438514 , .82838497261149613)
    RGB1[++i,] = (.87215331978454325, .82848052823709672 , .8330486712880828)
    RGB1[++i,] = (.87335171360916275, .83096715251272624 , .83748851001197089)
    RGB1[++i,] = (.87453793320260187, .83331972948645461 , .84171925358069011)
    RGB1[++i,] = (.87571458709961403, .8355302318472394  , .84575537519027078)
    RGB1[++i,] = (.87687848451614692, .83759238071186537 , .84961373549150254)
    RGB1[++i,] = (.87802298436649007, .83950165618540074 , .85330645352458923)
    RGB1[++i,] = (.87913244240792765, .84125554884475906 , .85685572291039636)
    RGB1[++i,] = (.88019293315695812, .84285224824778615 , .86027399927156634)
    RGB1[++i,] = (.88119169871341951, .84429066717717349 , .86356595168669881)
    RGB1[++i,] = (.88211542489401606, .84557007254559347 , .86673765046233331)
    RGB1[++i,] = (.88295168595448525, .84668970275699273 , .86979617048190971)
    RGB1[++i,] = (.88369127145898041, .84764891761519268 , .87274147101441557)
    RGB1[++i,] = (.88432713054113543, .84844741572055415 , .87556785228242973)
    RGB1[++i,] = (.88485138159908572, .84908426422893801 , .87828235285372469)
    RGB1[++i,] = (.88525897972630474, .84955892810989209 , .88088414794024839)
    RGB1[++i,] = (.88554714811952384, .84987174283631584 , .88336206121170946)
    RGB1[++i,] = (.88571155122845646, .85002186115856315 , .88572538990087124)
}

end

exit

