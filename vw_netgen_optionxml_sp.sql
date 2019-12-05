/************************************************************************************
procedure name and id   vw_netgen_optionxml_sp
name of the author      Kiruthika R
date created            
query file name         vw_netgen_optionxml_sp.sql
modifications history 
************************************************************************************/
alter procedure vw_netgen_optionxml_sp
@guid    engg_guid,
@ecrno    engg_name
as
begin
set nocount on

declare 
@CustomerName engg_name,
@ProjectName engg_name,
@ECRDescr  engg_description,
@ProcessName engg_name,
@ProcessDescr engg_description,
@ComponentName engg_name,
@ComponentDescr engg_description,
@ActivityName engg_name,
@ActivityDescr engg_description,
@UIName   engg_name,
@UIDescr  engg_description,
@ActivityChk engg_flag,
@error engg_flag,
@RtHtmlChk  engg_flag,
@chart   engg_flag,
@state   engg_flag,
@ddt   engg_flag,
@edksscript  engg_flag,
@controlextn engg_flag,
@datadriventask engg_flag,
@rtgif   engg_flag,
@selallforgridcheckbox engg_flag,
@contextmenu   engg_flag,
@extjs     engg_flag,
@compresshtml   engg_flag,
@compressjs    engg_flag,
@alltaskdata   engg_flag,
@cellspacing   engg_flag,
@comments    engg_flag,
@trialbar    engg_name,
@ServiceChk    engg_flag,
@WScriptChk    engg_flag,
@depscript    engg_flag,
@deploydeliverables  engg_flag,
@wflowoffset   engg_seqno,
@activityoffset   engg_seqno,
@platform    engg_name,
@appliation_rm_type  engg_name,
@generationpath   engg_description,
@repprintdate   engg_flag,
@multittx    engg_flag,
@CEXml     engg_flag, 
@InTD     engg_flag, 
@onlyxml    engg_flag, 
@reportaspx    engg_name, 
@errorlookup   engg_flag, 
@gridfilter    engg_flag, 
@labelselect            engg_flag,  
@dynamicclientevent  engg_flag,  
@split        engg_name,   
@ellipses       engg_name,    
@generatedatejs   engg_name,
@desktopdlv    engg_name, 
@DeviceConfigpath     engg_description,
@iPhone     engg_name,
@RTState		engg_name, 
@SecondaryLink engg_name, 
@extjs6 engg_name, 
@defaultasnull engg_name, 
@mhub2 engg_flag,
@allstyle engg_flag


--code commented and modified by 11536 to identify glance ui or not 

--select  distinct a.* into #engg_gen_deliverables
--from engg_gen_deliverables a(nolock),de_fw_req_publish_activity b(nolock)
--where   a.Guid = @guid
--and  a.ecrno = @ecrno
--and  a.ECRNo =b.ecrno
--and  a.CustomerName=b.customername
--and  a.ProjectName=b.projectname
--and  a.ProcessName =b.processname
--and	 a.ComponentName=b.componentname
--and  a.ActivityName=b.activityname
--and  ISNULL(b.for_extjs6,'')<>'N'

select  distinct a.*,LOWER(c.IsGlance) IsGlance into #engg_gen_deliverables
from	engg_gen_deliverables a(nolock),
		de_fw_req_publish_activity b(nolock),
		de_published_ui c (nolock)
where	a.Guid				=	@guid
and		a.ecrno				=	@ecrno
and		a.ECRNo				=	b.ecrno
and		a.CustomerName		=	b.customername
and		a.ProjectName		=	b.projectname
and		a.ProcessName		=	b.processname
and		a.ComponentName		=	b.componentname
and		a.ActivityName		=	b.activityname

and		a.CustomerName		=	c.customer_name
and		a.ProjectName		=	c.project_name
and		a.ProcessName		=	c.process_name
and		a.ComponentName		=	c.component_name
and		a.ActivityName		=	c.activity_name
and		a.UIName			=	c.ui_name
and		a.ECRNo				=	c.ecrno

and		ISNULL(b.for_extjs6,'')<>'N'



select  distinct @CustomerName = CustomerName,
@ProjectName = ProjectName,
@ECRNo   = ECRNo,
@ECRDescr  = ECRDescr,
@ProcessName = ProcessName,
@ProcessDescr = ProcessDescr,
@ComponentName = ComponentName,
@ComponentDescr = ComponentDescr,
@ServiceChk  = case when isnull(ServiceChk,0) = 0 then 'n' else 'y' end,
@WScriptChk  = case when isnull(WScriptChk,0) = 0 then 'n' else 'y' end,
@depscript  = case when isnull(depscript,0) = 0 then 'n' else 'y' end,
@error  = case when isnull(ServiceChk,0) = 0 then 'n' else 'y' end
from #engg_gen_deliverables (nolock)
where   Guid = @guid
and  ecrno = @ecrno


select @ComponentDescr  = replace(@ComponentDescr,'&','&amp;')
select @ComponentDescr  = replace(@ComponentDescr,'<','&lt;')
select @ComponentDescr  = replace(@ComponentDescr,'>','&gt;')
select @ComponentDescr  = replace(@ComponentDescr,'"','&quot;')

If not exists(select 'X'   
			  from engg_devcon_codegen_comp_metadata(nolock)
			  where componentname=@ComponentName)
begin 
insert engg_devcon_codegen_comp_metadata
				(chart,state,[pivot],ddt,cvs,excelreport,logicalextn,errorxml,instconfig,imptoolkitdel,spstub,refdocs,quicklink,datascript,
				  edksscript,controlextn,customurl,datadriventask,seperrordll,app,sys,grc,rtgif,fpgrid,sectioncollapse,displaysepcification,
				  fillerrow,gridalternaterowcolor,glowcorners,niftybuttons,smoothbuttons,blockerrors,linkmode,scrolltitle,tooltip,wizardhtml,
				  helpmode,impdeliverables,quicklinks,richui,widgetui,selallforgridcheckbox,contextmenu,extjs,accesskey,richtree,richchart,
				  compresshtml,compressjs,allstyle,alltaskdata,cellspacing,applicationcss,comments,inplacetrialbar,captionalignment,uiformat,
				  trialbar,smartspan,stylesheet,custombr,alllanguage,deploydeliverables,platform,appliation_rm_type,generationpath,multittx,
				  repprintdate,componentName,iEdk,statejs,ucd,ezreport,cexml,intd,onlyxml,reportaspx,webasync,errorlookup,taskpane,
				  suffixcolon,gridfilter,ezlookup,labelselect,ReleaseVersion,inlinetab,split,ellipses,reportxml,generatedatejs,
			      typebro,rbtnalign,ipad5,desktopdlv,DeviceConfigPath,iPhone,ellipsesleft,ezeewizard,LayoutControls,RTState,SecondaryLink,ltm,
				  language,Manual_options,depscript_with_actname,extjs6,defaultasnull,mHUB2)
select 'y','y','n','y','n','n','n','n','n','n','n','n','n','n','n','n','n','n','y','n','n','n','n','n','y','n','n','n',
'n','n','n','n','n','n','y','n','n','n','n','n','n','n','n','y','n','n','n','n','n','n','n',null,
'n','n','n','Left','Controls Beside captions','Both','y','RSGLOBALStyles',null,'n','n','DOTNET','SQL Server',null,'n','n',@ComponentName,'y',null,null,null,null,null,null,
null,'y','y','n',null,null,null,null,null,'y',null,null,null,null,null,null,null,null,null,null,'n','y','y','n',null,'y',
null,null,'y',null,null,null
end




 if exists ( select 'x'
		from engg_devcon_codegen_comp_metadata (nolock)
		where ComponentName = @ComponentName
		and isnull(manual_options,'N' ) = 'N' ) 
		begin
				
				select
				@chart = isnull(chart,''),
				@state = isnull(state,''),
				@ddt = isnull(ddt,''),
				@edksscript = isnull(edksscript,''),
				@rtgif = isnull(rtgif,''),
				@selallforgridcheckbox = isnull(selallforgridcheckbox,''),
				@contextmenu = isnull(contextmenu,''),
				@extjs = isnull(extjs,''),
				@compresshtml = isnull(compresshtml,''),
				@compressjs = isnull(compressjs,''),
				@alltaskdata = isnull(alltaskdata,''),
				@cellspacing = isnull(cellspacing,''),
				@deploydeliverables = isnull(deploydeliverables,''),
				@platform = isnull(platform,''),
				@appliation_rm_type = isnull(appliation_rm_type, ''),
				@generationpath = isnull(generationpath, ''),
				@multittx = isnull(multittx, ''), 
				@CEXml = isnull(cexml, ''),
				@InTD = isnull(intd, ''), 
				@reportaspx = isnull(reportaspx, ''), 
				@errorlookup = isnull(errorlookup, ''),  
				@gridfilter = isnull(gridfilter, ''), 
				@labelselect = isnull(labelselect, ''), 
				@split = isnull(split, ''),  
				@ellipses = isnull(ellipses, ''),   
				@desktopdlv = isnull(desktopdlv, ''), 
				@DeviceConfigpath = isnull(DeviceConfigpath, ''),
				@iPhone = isnull(iPhone, ''),
				@RTState = isnull(RTState, ''), 
				@SecondaryLink = isnull(SecondaryLink,''),	
				@extjs6 = isnull(extjs6,''), 
				@defaultasnull = isnull(defaultasnull,''), 
				@mhub2 = isnull(mhub2,'') ,
				@allstyle = isnull(allstyle,'')
				from engg_devcon_codegen_comp_metadata (nolock)
				where ComponentName = @ComponentName
				
				select @chart = case when @chart='' then isnull(chart, '') else @chart end,
				@state = case when @state='' then isnull(state, '') else @state end,
				@ddt = case when @ddt='' then isnull(ddt, '') else @ddt end,
				@edksscript = case when @edksscript='' then isnull(edksscript, '') else @edksscript end,
				@rtgif = case when @rtgif='' then isnull(rtgif, '') else @rtgif end,
				@selallforgridcheckbox = case when @selallforgridcheckbox='' then isnull(selallforgridcheckbox, '') else @selallforgridcheckbox end,
				@contextmenu = case when @contextmenu='' then isnull(contextmenu, '') else @contextmenu end,
				@extjs = case when @extjs='' then isnull(extjs, '') else @extjs end,
				@compresshtml = case when @compresshtml='' then isnull(compresshtml, '') else @compresshtml end,
				@compressjs = case when @compressjs='' then isnull(compressjs, '') else @compressjs end,
				@alltaskdata = case when @alltaskdata='' then isnull(alltaskdata, '') else @alltaskdata end,
				@cellspacing = case when @cellspacing='' then isnull(cellspacing, '') else @cellspacing end,
				@deploydeliverables = case when @deploydeliverables='' then isnull(deploydeliverables, '') else @deploydeliverables end,
				@platform = case when @platform='' then isnull(platform, '') else @platform end,
				@appliation_rm_type = case when @appliation_rm_type='' then isnull(appliation_rm_type, '') else @appliation_rm_type end,
				@generationpath = case when @generationpath='' then isnull(generationpath, '') else @generationpath end,
				@multittx = case when @multittx='' then isnull(multittx, '') else @multittx end,
				@CEXml = case when @CEXml = '' then isnull(CEXml, '') else @CEXml end,
				@InTD = case when @InTD= '' then isnull(intd, '') else @InTD end, 
				@reportaspx = case when @reportaspx= '' then isnull(reportaspx, '') else @reportaspx end,
				@errorlookup = case when @errorlookup = '' then isnull(errorlookup, '') else @errorlookup end,
				@gridfilter = case when @gridfilter = '' then isnull(gridfilter, '') else @gridfilter end,  
				@labelselect = case when @labelselect = '' then isnull(labelselect, '') else @labelselect end,
				@split = case when @split = '' then isnull(split, '') else @split end,    
				@ellipses = case when @ellipses = '' then isnull(ellipses, '') else @ellipses end,    
				@desktopdlv = case when @desktopdlv = '' then isnull(desktopdlv, '') else @desktopdlv end, 
				@DeviceConfigpath = case when @DeviceConfigpath = '' then isnull(DeviceConfigpath, '') else @DeviceConfigpath end,
				@iPhone = case when @iPhone = '' then isnull(iPhone, '') else @iPhone end,
				@RTState = case when @RTState= '' then isnull(RTState, '') else @RTState end, 
				@SecondaryLink = case when @SecondaryLink='' then isnull(SecondaryLink,'') else @SecondaryLink end,
				@extjs6 = case when @extjs6 = '' then ISNULL(extjs6,'') else @extjs6 end, 
				@defaultasnull = case when @defaultasnull = '' then ISNULL(defaultasnull,'') else @defaultasnull end, 
				@mhub2 = case when @mhub2 = '' then ISNULL(mhub2,'') else @mhub2 end ,
				@allstyle = case when @allstyle='' then isnull(allstyle, '') else @allstyle end
				from engg_devcon_codegen_options (nolock)
				where guid = @guid
				
				end
else
				begin
				select
				@chart = isnull(chart,'n'),
				@state = isnull(state,'n'),
				@ddt = isnull(ddt,'n'),
				@edksscript = isnull(edksscript,'n'),
				@rtgif = isnull(rtgif,'n'),
				@selallforgridcheckbox = isnull(selallforgridcheckbox,'n'),
				@contextmenu = isnull(contextmenu,'n'),
				@extjs = isnull(extjs,'n'),
				@compresshtml = isnull(compresshtml,'n'),
				@compressjs = isnull(compressjs,'n'),
				@alltaskdata = isnull(alltaskdata,'n'),
				@cellspacing = isnull(cellspacing,'n'),
				@deploydeliverables = isnull(deploydeliverables,'n'),
				@platform = isnull(platform,'Dotnet'),
				@appliation_rm_type = lower(isnull(appliation_rm_type, 'sql')) ,
				@generationpath  =  isnull(generationpath, 'c:\temp'),
				@multittx   =  isnull(multittx, 'n'),
				@CEXml    = isnull(CEXml, 'n'),
				@InTD    =  isnull(intd, 'n'),  
				@reportaspx   =  isnull(reportaspx, 'Crystal'),  
				@errorlookup  =  isnull(errorlookup, 'n'), 
				@gridfilter   =  isnull(gridfilter, 'n'), 
				@labelselect        =   isnull(labelselect, 'n'), 
				@split    =   isnull(split, 'n'),     
				@ellipses   =   isnull(ellipses, 'n'),   
				@desktopdlv   =   isnull(desktopdlv, 'n'), 
				@DeviceConfigpath = isnull(DeviceConfigpath, ''),
				@iPhone    =   isnull(iPhone, 'n'),
				@RTState    =  isnull(RTState, 'n'), 
				@SecondaryLink = isnull(SecondaryLink,'n'), 
				@extjs6 = ISNULL(extjs6,''), 
				@defaultasnull = ISNULL(defaultasnull,''), 
				@mhub2 = ISNULL(mhub2,''),
				@allstyle = isnull(allstyle,'n') 
				from engg_devcon_codegen_options (nolock)
				where guid = @guid
				end





declare @RequestID    engg_name,
@CodeGenClient   engg_name,
@Requeststart_datetime engg_datetime,
@genpath    engg_desc 

select @RequestID    = Request_ID,
@CodeGenClient   = CodeGenClient,
@Requeststart_datetime = Requeststart_datetime,
@genpath    = CodegenPath
from engg_devcon_codegen_schedule_dtls_vw (nolock)
where guid = @guid
and  ecrno= @ecrno

if (@RequestID is not null)
	select @generationpath = 'e:\deliverables\fromnewgenerator' + '\' + @RequestID

if @mhub2 = 'y'
begin
	select @desktopdlv = 'y'
end

declare @model varchar(4000),@languages varchar(max),@configxml varchar(1000),@scripts varchar(1000),
@service varchar(1000),@activity varchar(max),@options varchar(max),@htm varchar(max),@optionxml varchar(max)

Select @model = '<model customer="' + @CustomerName + '" project="' + @ProjectName + '" ecrno="' + @ECRNo 
			    + '" process="'+ @ProcessName + '" component="' + @ComponentName +'" componentdesc="'+ @ComponentDescr 
				+ '" appliation_rm_type="'+ @appliation_rm_type +'" generationpath="'+ isnull(@generationpath,'') +'" platform="'+ @platform 
				+'" deploydeliverables="'+ @deploydeliverables + '" requestid="'+ isnull(@RequestID, '') 
				+'" codegenclient="' + isnull(@CodeGenClient, '') 
				+ '" requeststart_datetime="'+ convert(varchar(50), isnull(@Requeststart_datetime, '')) +'" guid="'+ @guid +'"/>'  




 if  exists (select 'k' from engg_devcon_codegen_comp_metadata (nolock) 
			 where componentname =@componentname 
			 and language is not null)

begin
		create  table #result (langid varchar(5))
		declare  @commadelimitedstring xml
											
		select  @commadelimitedstring = cast(('<X>'+replace(language,',','</X><X>')+'</X>') as xml)   
		from engg_devcon_codegen_comp_metadata (nolock)
		where componentname =@componentname

											
		insert #result (langid)
		select N.value('.', 'varchar(5)') 
		FROM @commadelimitedstring.nodes('X') as T(N)


		select @languages = (select distinct  quick_code as id ,
												quick_code_value as [desc]
							from #result         a (nolock) ,
									ep_language_met language (nolock)
							where  langid = quick_code
							FOR XML AUTO,root('languages'))
										
		drop table #result
end
									
else
			
begin 
						select @languages = (select distinct  lang_id as id , lang_descr as [desc]
											from engg_devcon_codegen_options_lang language (nolock)
											where  Guid = @guid
											FOR XML AUTO,root('languages'))


				
end




select @activityoffset = isnull(ActivityOffset,0),
@wflowoffset = isnull(WorkflowOffset,0)
from engg_devcon_deliv_activityoffset (nolock)
where customerName = @customerName
and  projectName  = @projectName
and  ComponentName = @ComponentName

Select @configxml = '<configxmls chart="'+ @chart +'" state="' + @RTState + '" ddt="' +@ddt + '" cexml="' + @CEXml 
				    + '" errorlookup="' + @errorlookup + '"/>' 


select @scripts = '<scripts edksscript="'+ @edksscript + '" depscript="'+ @depscript 
                   + '" activityoffset="'+ convert(varchar(12),@activityoffset) +'" wflowscript="'+ @WScriptChk 
				   + '" wflowoffset="' + convert(varchar(12),@wflowoffset) + '"/>' 



select @service = '<service dll="' + @ServiceChk  +'" error="' + @error + '" intd="'+ @InTD+'" defaultasnull = "'+ @defaultasnull +'" />'   


 select @activity = (select distinct  activityname  as name, 'y' as dll
					from    #engg_gen_deliverables activity (nolock)
					where   Guid = @guid
					and     ecrno = @ECRNo
					and     isnull(ActivityChk,0) = 1 
					FOR XML AUTO)

select @activity = '<activities>'+isnull(@activity,'')+'</activities>'


select @options = '<options>'+'<option rtgif="' + @rtgif + '" />'
+ ' <option selallforgridcheckbox="' + @selallforgridcheckbox + '" />'
+ ' <option contextmenu="' + @contextmenu + '" />'
+ ' <option extjs="'+ @extjs + '" />'
+ ' <option compresshtml="' + @compresshtml + '" />'
+ ' <option compressjs="'+ @compressjs  +'" />'
+ ' <option alltaskdata="' + @alltaskdata +'" />'
+ ' <option cellspacing="' + @cellspacing +'" />'
+ ' <option gridfilter="' + @gridfilter +'" />' 
+ ' <option labelselect="' + @labelselect +'" />' 
+ ' <option split="' + @split +'" />' 
+ ' <option ellipses="' + @ellipses +'" />' 
+ ' <option deviceconfigpath="' + @DeviceConfigPath +'" />'
+ ' <option iPhone="' + @iPhone +'" />'
+ ' <option secondarylinks="' + @SecondaryLink +'" />'
+ ' <option extjs6="' + @extjs6 +'" />'
+ ' <option mhub2="' + @mhub2 +'" />' 
+ ' <option multiplettx="' + @multittx +'" />' 
+ ' <option reportformat="' + @reportaspx +'" />' 
+ ' <option desktopdlv="' + @desktopdlv +'" />' 
+ ' <option allstyle="' + @allstyle +'" />' 
+ '</options>'




 select @htm = (select  distinct
			    activityname ,
				replace(replace(replace(replace(ActivityDescr,'&','&amp;'),'<','&lt;'),'>','&gt;'),'"','&quot;') as activitydesc,
			    uiname,
				replace(replace(replace(replace(UIDescr,'&','&amp;'),'<','&lt;'),'>','&gt;'),'"','&quot;') as uidesc, 
			    case when isnull(RtHtmlChk,0) = 0 then 'n' else 'y' end as html ,
				case when isnull(AspxXml,0) = 0 then 'n' else 'y' end as aspx,
				case when isnull(IsGlance,'') = '' then 'n' else 'y'end as isglanceui
			from    #engg_gen_deliverables htm (nolock)
			where   Guid = @guid
			and     ecrno = @ECRNo
			and     (isnull(RtHtmlChk,0) = 1 or AspxXml    =  1)
			FOR XML AUTO)
select @htm = '<htmls>'+isnull(@htm,'')+'</htmls>'


drop table #engg_gen_deliverables

select @optionxml = '<codegeneration>'+isnull(@model,'')+isnull(@languages,'')+lower(isnull(@configxml,'')+isnull(@scripts,'')+isnull(@options,'')+isnull(@service,''))+isnull(@activity,'')+isnull(@htm,'')+'</codegeneration>'

select cast(@optionxml as xml) 'gen_xml'

set nocount off
end