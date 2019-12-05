CREATE procedure vw_netgen_codegen_options_save
@guid     engg_guid,
@rtgif     engg_flag,
@fpgrid     engg_flag,
@sectioncollapse  engg_flag,
@displaysepcification engg_flag,
@fillerrow    engg_flag,
@gridalternaterowcolor engg_flag,
@glowcorners   engg_flag,
@niftybuttons   engg_flag,
@smoothbuttons   engg_flag,
@blockerrors   engg_flag,
@linkmode    engg_flag,
@scrolltitle   engg_flag,
@tooltip    engg_flag,
@wizardhtml    engg_flag,
@helpmode    engg_flag,
@impdeliverables  engg_flag,
@quicklinks    engg_flag,
@richui     engg_flag,
@widgetui    engg_flag,
@selallforgridcheckbox engg_flag,
@contextmenu   engg_flag,
@extjs     engg_flag,
@accesskey    engg_flag,
@richtree    engg_flag,
@richchart    engg_flag,
@compresshtml   engg_flag,
@compressjs    engg_flag,
@allstyle    engg_flag,
@alltaskdata   engg_flag,
@cellspacing   engg_flag,
@applicationcss   engg_flag,
@comments    engg_flag,
@inplacetrialbar  engg_flag,
@captionalignment  engg_name,
@uiformat    engg_name,
@trialbar    engg_name,
@smartspan    engg_flag,
@stylesheet    engg_name,
@chart     engg_flag,
@state     engg_flag,
@pivot     engg_flag,
@ddt     engg_flag,
@cvs     engg_flag,
@excelreport   engg_flag,
@logicalextn   engg_flag,
@errorxml    engg_flag,
@instconfig engg_flag,
@imptoolkitdel   engg_flag,
@spstub     engg_flag,
@refdocs    engg_flag,
@quicklink    engg_flag,
@datascript    engg_flag,
@edksscript    engg_flag,
@controlextn   engg_flag,
@seperrordll   engg_flag,
@customurl    engg_flag,
@datadriventask   engg_flag,
@custombr    engg_flag,
@app     engg_flag,
@sys     engg_flag,
@grc     engg_flag,
@deploydeliverables  engg_flag,
@alllanguage   engg_flag,
@platform    engg_name,
@appliation_rm_type  engg_name,
@generationpath   engg_desc,
@multittx    engg_flag,
@repprintdate   engg_flag, --  Code modified for bug id : PNR2.0_22503
@iEDK     engg_flag,  --  Code added for bug id : PNR2.0_22503, PNR2.0_23740
@statejs    engg_flag,  --  Code added for bug id : PNR2.0_23740, PNR2.0_24678
@ucd     engg_flag,  --  Code added for bug id : PNR2.0_24678
@ezreport    engg_flag,
@CEXml     engg_flag,
@InTD     engg_flag,
@onlyxml    engg_flag, --  Code added for bug id : PNR2.0_28097
@reportaspx    engg_name, --  Code added for bug id : PNR2.0_28097
@webasync    engg_flag, --  Code added for bug id : PNR2.0_29089
@errorlookup   engg_flag, --  Code added for bug id : PNR2.0_29495
@taskpane    engg_flag,  --  Code added for bug id : PNR2.0_29932
@suffixcolon   engg_flag,  --  Code added for bug id : PNR2.0_30446
@gridfilter    engg_flag,  --  Code added for bug id : PNR2.0_32535
@ezlookup    engg_flag,  --  Code added for bug id : PNR2.0_32815
@labelselect   engg_flag ,    --  Code added for bug id :PNR2.0_33513
@ReleaseVersion   engg_name, -- Code added for bug id : PNR2.0_34753
@inlinetab   engg_name, -- Code added for bug id : PNR2.0_35094
@split   engg_name, -- Code added for bug id : PNR2.0_35383
@ellipses engg_name, -- Code added for bug id : PNR2.0_35840
-- Code added for bug id : PLF2.0_00302  **Start**
@reportxml engg_name,
@generatedatejs engg_name,
-- Code added for bug id : PLF2.0_00302  **End**
@typebro engg_name,  -- Code added for bug id : PLF2.0_00295
@iPad5 engg_name, -- Code added for bug id : PLF2.0_02398
@desktopdlv engg_name, -- code added for bug id: PLF2.0_03462
-- code added for bug id: PLF2.0_03761 ***start***
@DeviceConfigPath engg_desc,
@iPhone engg_name,
-- code added for bug id: PLF2.0_03761 ***end***
@ellipsesleft engg_name, -- code added for bug id: PLF2.0_04721
@ezeewizard engg_name, -- PLF2.0_07530
@layoutcontrols engg_name, --PLF2.0_08401
@rtstate		engg_name, --PLF2.0_08966
@SecondaryLink engg_name,  --PLF2.0_11168
--@ltm				engg_flag,  --PLF2.0_15017
@depscript_with_actname			engg_flag, --PLF2.0_16751
@extjs6 engg_flag, --PLF2.0_19114 
@defaultasnull engg_flag, --PLF2.0_20078
@mhub2 engg_flag, --TECH-6468
@customer engg_name, --TECH-2669 **starts**
@project engg_name,
@ecrno engg_name,
@component engg_name,
@codegenclient engg_desc,
@status engg_name, ----TECH-2669 **ends**
@previousgenerationpath engg_desc
as
begin


if not exists( select 'x'
from engg_devcon_codegen_options (nolock)
where guid  = @guid
)
begin
insert engg_devcon_codegen_options
(guid,     chart,     state,     [pivot],     ddt,     cvs,     excelreport,
logicalextn,   errorxml,    instconfig,    imptoolkitdel,   spstub,     refdocs,    quicklink,
datascript,    edksscript,    controlextn,   customurl,    datadriventask,   seperrordll,   app,
sys,     grc,     rtgif,     fpgrid,     sectioncollapse,  displaysepcification, fillerrow,
gridalternaterowcolor, glowcorners,   niftybuttons,   smoothbuttons,   blockerrors,   linkmode,
scrolltitle,   tooltip,    wizardhtml,    helpmode,    impdeliverables,  quicklinks,    richui,
widgetui,    selallforgridcheckbox, contextmenu,   extjs,     accesskey,    richtree,    richchart,
compresshtml,   compressjs,    allstyle,    alltaskdata,   cellspacing,   applicationcss,   comments,
inplacetrialbar,  captionalignment,  uiformat,    trialbar,    smartspan,    stylesheet,
custombr,    alllanguage,   deploydeliverables,  platform,    appliation_rm_type,  generationpath,
multittx,    repprintdate,   iEDK,     statejs,    ucd,     ezreport,    CEXml,
InTD,     onlyxml,    reportaspx,    webasync,    errorlookup,   taskpane,    suffixcolon,
gridfilter,  ezlookup,labelselect,ReleaseVersion, inlinetab, split,ellipses,reportxml,generatedatejs,
typebro,ipad5,desktopdlv,DeviceConfigPath,iPhone,ellipsesleft, ezeewizard, layoutcontrols, rtstate,SecondaryLink,depscript_with_actname,extjs6,defaultasnull,customer_name,project_name,ecr_no,component_name,codegenclient,starttime,[status],mhub2,previousgenerationpath) 
values (@guid,     @chart,     @state,     @pivot,     @ddt,     @cvs,     @excelreport,
@logicalextn,   @errorxml,    @instconfig,   @imptoolkitdel,   @spstub,    @refdocs,    @quicklink,
@datascript,   @edksscript,   @controlextn,   @customurl,    @datadriventask,  @seperrordll,   @app,
@sys,     @grc,     @rtgif,     @fpgrid,    @sectioncollapse,  @displaysepcification, @fillerrow,
@gridalternaterowcolor, @glowcorners,   @niftybuttons,   @smoothbuttons,   @blockerrors,   @linkmode,
@scrolltitle,   @tooltip,    @wizardhtml,   @helpmode,    @impdeliverables,  @quicklinks,   @richui,
@widgetui,    @selallforgridcheckbox, @contextmenu,   @extjs,     @accesskey,    @richtree,    @richchart,
@compresshtml,   @compressjs,   @allstyle,    @alltaskdata,   @cellspacing,   @applicationcss,  @comments,
@inplacetrialbar,  @captionalignment,  @uiformat,    @trialbar,    @smartspan,    @stylesheet,
@custombr,    @alllanguage,   @deploydeliverables, @platform,    @appliation_rm_type, @generationpath,
@multittx,    @repprintdate,   @iEDK,     @statejs,    @ucd,     @ezreport,    @CEXml,
@InTD,     @onlyxml,    @reportaspx,   @webasync,    @errorlookup,   @taskpane,    @suffixcolon,
@gridfilter,   @ezlookup, @labelselect,@ReleaseVersion, @inlinetab, @split,@ellipses,@reportxml,@generatedatejs,
@typebro,@ipad5,@desktopdlv,@DeviceConfigPath,@iPhone,@ellipsesleft, @ezeewizard, @layoutcontrols, @RTState, @SecondaryLink,@depscript_with_actname,@extjs6,@defaultasnull,@customer,@project,@ecrno,@component,@codegenclient,GETDATE(),'inprogress',@mhub2,@previousgenerationpath)  
end
else
begin
update engg_devcon_codegen_options
set  chart     = @chart,
state     = @state,
[pivot]     = @pivot,
ddt      = @ddt,
cvs      = @cvs,
excelreport    = @excelreport,
logicalextn    = @logicalextn,
errorxml    = @errorxml,
instconfig    = @instconfig,
imptoolkitdel   = @imptoolkitdel,
spstub     = @spstub,
refdocs     = @refdocs,
quicklink    = @quicklink,
datascript    = @datascript,
edksscript    = @edksscript,
controlextn    = @controlextn,
customurl    = @customurl,
datadriventask   = @datadriventask,
seperrordll    = @seperrordll,
app      = @app,
sys      = @sys,
grc   = @grc,
rtgif     = @rtgif,
fpgrid     = @fpgrid,
sectioncollapse   = @sectioncollapse,
displaysepcification = @displaysepcification,
fillerrow    = @fillerrow,
gridalternaterowcolor = @gridalternaterowcolor,
glowcorners    = @glowcorners,
niftybuttons   = @niftybuttons,
smoothbuttons   = @smoothbuttons,
blockerrors    = @blockerrors,
linkmode    = @linkmode,
scrolltitle    = @scrolltitle,
tooltip     = @tooltip,
wizardhtml    = @wizardhtml,
helpmode    = @helpmode,
impdeliverables   = @impdeliverables,
quicklinks    = @quicklinks,
richui     = @richui,
widgetui    = @widgetui,
selallforgridcheckbox = @selallforgridcheckbox,
contextmenu    = @contextmenu,
extjs     = @extjs,
accesskey    = @accesskey,
richtree    = @richtree,
richchart    = @richchart,
compresshtml   = @compresshtml,
compressjs    = @compressjs,
allstyle    = @allstyle,
alltaskdata    = @alltaskdata,
cellspacing    = @cellspacing,
applicationcss   = @applicationcss,
comments    = @comments,
inplacetrialbar   = @inplacetrialbar,
captionalignment  = @captionalignment,
uiformat    = @uiformat,
trialbar    = @trialbar,
smartspan    = @smartspan,
stylesheet    = @stylesheet,
custombr    = @custombr,
alllanguage    = @alllanguage,
deploydeliverables  = @deploydeliverables,
platform    = @platform,
appliation_rm_type  = @appliation_rm_type,
generationpath   = @generationpath,
multittx    = @multittx,    -- Fix for bug id : PNR2.0_21679
repprintdate= @repprintdate, --  Code modified for bug id : PNR2.0_22503
iEDK        = @iEDK,    --  Code added for bug id : PNR2.0_22503, PNR2.0_23740
statejs     = @statejs,   --  Code added for bug id : PNR2.0_23740, PNR2.0_24678
ucd         = @ucd,    --  Code added for bug id : PNR2.0_24678
ezreport    = @ezreport,
CEXml       = @CEXml,
InTD        = @InTD, --  Code added for bug id : PNR2.0_26443, PNR2.0_28097
onlyxml     = @onlyxml, --  Code added for bug id : PNR2.0_28097
reportaspx  = @reportaspx, --  Code added for bug id : PNR2.0_28097
webasync  = @webasync,  --  Code added for bug id : PNR2.0_29089
errorlookup = @errorlookup,  --  Code added for bug id : PNR2.0_29495
taskpane    = @taskpane,  --  Code added for bug id : PNR2.0_29932
suffixcolon = @suffixcolon,  --  Code added for bug id : PNR2.0_30446
gridfilter  = @gridfilter,  --  Code added for bug id : PNR2.0_32535
ezlookup    = @ezlookup,  --  Code added for bug id : PNR2.0_32815
labelselect = @labelselect ,     --  Code added for bug id :PNR2.0_33513
ReleaseVersion  =  @ReleaseVersion,  -- Code added for bug id : PNR2.0_34753
inlinetab  = @inlinetab,   -- Code added for bug id : PNR2.0_35094
split   = @split,   -- Code added for bug id : PNR2.0_35383
ellipses     = @ellipses, -- Code added for bug id : PNR2.0_35840
-- Code added for bug id : PLF2.0_00302  **start**
reportxml= @reportxml,
generatedatejs= @generatedatejs,
-- Code added for bug id : PLF2.0_00302  **end**
typebro= @typebro,  --Code added for bug id : PLF2.0_00295
ipad5 = @ipad5,  -- Code added for bug id : PLF2.0_02398
desktopdlv = @desktopdlv, -- Code added for bug id :PLF2.0_03462
-- code added for bug id: PLF2.0_03761 ***start***
DeviceConfigPath = @DeviceConfigPath,
iPhone = @iPhone,
-- code added for bug id: PLF2.0_03761 ***end***
ellipsesleft= @ellipsesleft, -- code added for bug id: PLF2.0_04721
ezeewizard = @ezeewizard, -- PLF2.0_07530
layoutcontrols = @layoutcontrols, --PLF2.0_08401
RTState = @RTState, --PLF2.0_08966
SecondaryLink=@SecondaryLink, --PLF2.0_11168
--ltm  =@ltm, --PLF2.0_15017
depscript_with_actname =  @depscript_with_actname, --PLF2.0_16751
extjs6 = @extjs6, --PLF2.0_19114 
defaultasnull = @defaultasnull, --PLF2.0_20078
customer_name = @customer, --TECH-2669 **starts**
project_name = @project,
ecr_no = @ecrno,
component_name = @component,
codegenclient = @codegenclient,
endtime = GETDATE(),
status = @status, --TECH-2669 **ends**
mhub2 = @mhub2, --TECH-6468
previousgenerationpath = @previousgenerationpath
where guid     = @guid
end
end



