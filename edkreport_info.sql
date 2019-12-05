--set quoted_identifier off

/*
exec edkreport_info 'bcdg','7h118','Staffing','HRMSHRES2',1
*/

CREATE proc edkreport_info
@customer_name		engg_name,
@Project_Name		engg_name,
@Process_Name		engg_name,
@Component_Name	engg_name,
@langid					int
as

begin 
set nocount on

if object_id('edk_temp') is null
	begin 

			create table #edk_temp(query varchar(max),seq int identity)
	end 

insert #edk_temp(query)
select 'set nocount on'

insert #edk_temp(query)
select 'set quoted_identifier off'

insert #edk_temp(query)
select '-- Creation of Temp Table Starts'
union all
select 'Declare @dw_vw_component Table(componentname nvarchar(20) NOT NULL,componentdesc nvarchar(128) NOT NULL)'
union all
select 'Declare @dw_vw_component_local_info Table(componentname nvarchar(20) NOT NULL,langid int not null,componentdesc nvarchar(128) NOT NULL)'
union all
select 'Declare @dw_vw_activity Table(activityname nvarchar(20) NOT NULL,componentname nvarchar(20) NOT NULL,edkactivity int  NOT NULL)'
union all
select 'Declare @dw_vw_activity_local_info Table(activityname nvarchar(20) NOT NULL,langid int NOT NULL,activitydesc nvarchar(128) NOT NULL)'
union all
select 'Declare @dw_vw_ilbo Table(ilbocode nvarchar(100) Not NULL)'
union all
select 'Declare @dw_vw_ilbo_local_info Table(ilbocode nvarchar(100) NOT NULL,langid int NOT NULL,ilbodesc nvarchar(255) NOT NULL)'
union all
select 'Declare @dw_vw_activity_ilbo Table(activityname nvarchar(20) NOT NULL,ilbocode nvarchar(100) NOT NULL)'
union all
select 'Declare @dw_vw_ilbo_task Table(ilbocode nvarchar(100) NOT NULL,taskname nvarchar(50) NOT NULL,extended int)'
union all
select 'Declare @dw_vw_ilbo_task_local_info Table(ilbocode nvarchar(100) NOT NULL,taskname nvarchar(50) NOT NULL,langid int NOT NULL,reportdesc nvarchar(50), extended int)'
union all
select 'Declare @dw_vw_bterm Table(componentname nvarchar(20) NOT NULL,btname nvarchar(30) NOT NULL,bt_datatype nvarchar(50) NOT NULL,bt_length int NOT NULL,extended bit NOT NULL)'
union all
select 'Declare @dw_vw_bterm_synonym Table(componentname nvarchar(20) NOT NULL,btname nvarchar(30) NOT NULL,btsynonym nvarchar(30) NOT NULL,extended bit NOT NULL)'
union all
select 'Declare @dw_vw_bterm_synonym_local_info Table(componentname nvarchar(20) NOT NULL,btsynonym nvarchar(30) NOT NULL,langid int NOT NULL,pltext nvarchar(255) NOT NULL,extended bit NOT NULL)'
union all
select 'Declare @dw_vw_service Table(ilbocode nvarchar(100) NOT NULL,taskname nvarchar(50) NOT NULL,servicename nvarchar(30) NOT NULL,rptname nvarchar(250) not null)'
union all
select 'Declare @dw_vw_service_segment Table(ilbocode nvarchar(100) NOT NULL,taskname nvarchar(50) NOT NULL,servicename nvarchar(30) NOT NULL,segmentname nvarchar(30) NOT NULL,segmentsequence int not null,instanceflag int NOT NULL,extended bit NOT NULL)'


union all
select 'Declare @dw_vw_service_data_item Table(ilbocode nvarchar(100) NOT NULL,taskname nvarchar(50) NOT NULL,servicename nvarchar(30) NOT NULL,segmentname nvarchar(30) NOT NULL,dataitemname nvarchar(30) NOT NULL,flowdirection nvarchar(30) NOT NULL,defaul
tvalue nvarchar(255) NOT NULL,extended bit NOT NULL)	'
union all
select 'Declare @dw_vw_report_task_file_dtl Table(ilbocode nvarchar(100) NOT NULL,taskname nvarchar(50) NOT NULL,report_file_name varchar(200) NOT NULL,report_type varchar(50))'
union all
select 'Declare @dw_vw_report_segment_dataitem Table(ilbocode nvarchar(100) NOT NULL,taskname nvarchar(50) NOT NULL,report_file_name varchar(200) NOT NULL,segment_name varchar(30),dataitem_name varchar(30))'
union all
select '-- Creation of Temp Table Ends'
union all
select '--Insert script into the above temp table Starts'

insert #edk_temp(query)
select '/*Logic To Insert into above temp table*/'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_component' + space(4)+ '(componentname,componentdesc)' + space(4) + 'values' + space(4) +'(' +""""+a.component_name+""""+','+""""+b.componentdesc+""""+')'
from de_report_attributes a (nolock),de_fw_req_component_local_info b (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  =  @Component_Name
and			b.langid					=  @langid	
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.componentname

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_component_local_info' + space(4)+ '(componentname,langid,componentdesc)' + space(4) + 'values' + space(4) +'(' +""""+a.component_name+""""+','+cast(b.langid as varchar(40))+','+""""+b.componentdesc+""""+')'
from de_report_attributes a (nolock),de_fw_req_component_local_info b (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  =  @Component_Name
and			b.langid					=  @langid	
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.ComponentName

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_activity' + space(4)+ '(activityname,componentname,edkactivity)' + space(4) + 'values' + space(4) +'(' +""""+a.activity_name+""""+','+""""+a.component_name+""""+','+'0'+')'
from de_report_attributes a (nolock),de_fw_req_activity_local_info b (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  =  @Component_Name
and			b.langid					=  @langid	
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.activity_name		=	b.activity_name
 
 insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_activity_local_info' + space(4)+ '(activityname,langid,activitydesc)' + space(4) + 'values' + space(4) +'(' +""""+a.activity_name+""""+','+cast(b.langid as varchar(40))+','+""""+b.activitydesc+""""+')'
from de_report_attributes a (nolock),de_fw_req_activity_local_info b (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  =  @Component_Name
and			b.langid					=  @langid	
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.activity_name		=	b.activity_name

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_ilbo' + space(4)+ '(ilbocode)' + space(4) + 'values' + space(4) +'(' +""""+a.ui_name+""""+')'
from de_report_attributes a (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  =  @Component_Name

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_ilbo_local_info' + space(4)+ '(ilbocode,langid,ilbodesc)' + space(4) + 'values' + space(4) +'(' +""""+a.ui_name+""""+','+cast(b.langid as varchar(40))+','+""""+b.description+""""+')'
from de_report_attributes a (nolock),de_fw_req_ilbo_local_info b (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  =  @Component_Name
and			b.langid					=  @langid	
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.ui_name				=	b.ilbocode

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_activity_ilbo' + space(4)+ '(activityname,ilbocode)' + space(4) + 'values' + space(4) +'(' +""""+a.activity_name+""""+','+""""+a.ui_name+""""+')'
from de_report_attributes a (nolock) 
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  =  @Component_Name

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_ilbo_task' + space(4)+ '(ilbocode,taskname,extended)' + space(4) + 'values' + space(4) +'(' +""""+a.ilbocode+""""+','+""""+a.taskname+""""+','+'0'+')'
from de_fw_req_ilbo_task_rpt a (nolock) , de_report_attributes b (nolock)
where		b.customer_name		=	@customer_name
and			b.project_name		=  @Project_Name
and			b.process_name		=  @Process_Name
and			b.component_name  =  @Component_Name
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.activity_name		=	b.activity_name
and			a.ilbocode				=	b.ui_name
and			a.taskname				=  b.task_name

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_ilbo_task_local_info' + space(4)+ '(ilbocode,taskname,langid,reportdesc,extended)' + space(4) + 'values' + space(4) +'(' +""""+a.ui_name+""""+','+""""+a.task_name+""""+','+cast(b.langid as varchar(40))+','+""""+isnull(a.repo
rt_descr,'')+""""+','+'0'+')'
from de_report_attributes a (nolock) , de_fw_req_task_local_info b (nolock)
where		b.customer_name		=	@customer_name
and			b.project_name		=  @Project_Name
and			b.process_name		=  @Process_Name
and			b.component_name  =  @Component_Name
and			b.langid					=	@langid
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.task_name				=  b.taskname

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_bterm' + space(4)+ '(componentname,btname,bt_datatype,bt_length,extended)' + space(4) + 'values' + space(4) +'(' +""""+a.component_name+""""+','+""""+c.bt_name+""""+','+""""+c.data_type+""""+','+""""+cast (c.length as varcha
r(40))+""""+','+'0'+')'
from de_fw_des_service_dataitem a (nolock) , de_glossary b (nolock) , de_business_term c (nolock),de_task_service_map d (nolock),de_report_attributes e (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  	=  @Component_Name
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.dataitemname		=   b.bt_synonym_name
and			b.Customer_Name 	=	c.Customer_Name 
and			b.Project_Name		=	c.Project_Name
and			b.Process_Name		=	c.Process_Name
and			b.Component_Name	=	c.Component_Name
and			b.bt_name			=   c.bt_name
and			a.customer_name		=	d.customer_name
and			a.project_name		=	d.project_name
and			a.process_name		=	d.process_name
and			a.component_name	=	d.component_name
and			a.servicename			=	d.service_name
and			d.customer_name		=	e.customer_name
and			d.project_name		=	e.project_name
and			d.process_name		=	e.process_name
and			d.component_name	=	e.component_name
and			d.task_name			=	e.task_name
union
select distinct 'insert @dw_vw_bterm' + space(4)+ '(componentname,btname,bt_datatype,bt_length,extended)' + space(4) + 'values' + space(4) +'(' +""""+a.component_name+""""+','+""""+a.bt_name+""""+','+""""+a.data_type+""""+','+""""+cast (a.length as varcha
r(40))+""""+','+'0'+')'
from de_business_term a (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  	=  @Component_Name
and			a.bt_name				= 'modeflag'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_bterm_synonym' + space(4)+ '(componentname,btname,btsynonym,extended)' + space(4) + 'values' + space(4) +'(' +""""+a.component_name+""""+','+""""+c.bt_name+""""+','+""""+b.bt_synonym_name+""""+','+'0'+')'

from de_fw_des_service_dataitem a (nolock) , de_glossary b (nolock),de_business_term c (nolock),de_task_service_map d (nolock),de_report_attributes e (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=   @Project_Name
and			a.process_name		=   @Process_Name
and			a.component_name  	=   @Component_Name
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.dataitemname		=   b.bt_synonym_name
and			b.customer_name		=	c.customer_name							
and			b.project_name		=	c.project_name
and			b.process_name		=	c.process_name
and			b.component_name	=	c.component_name
and			b.bt_name				=	c.bt_name
and			a.customer_name		=	d.customer_name
and			a.project_name		=	d.project_name
and			a.process_name		=	d.process_name
and			a.component_name	=	d.component_name
and			a.servicename			=	d.service_name
and			d.customer_name		=	e.customer_name
and			d.project_name		=	e.project_name
and			d.process_name		=	e.process_name
and			d.component_name	=	e.component_name
and			d.task_name			=	e.task_name
union
select distinct 'insert @dw_vw_bterm_synonym' + space(4)+ '(componentname,btname,btsynonym,extended)' + space(4) + 'values' + space(4) +'(' +""""+a.component_name+""""+','+""""+a.foreignname+""""+','+""""+a.btsynonym+""""+','+'0'+')'

from de_fw_req_lang_bterm_synonym a (nolock) 
where		a.customer_name		=	@customer_name
and			a.project_name		=   @Project_Name
and			a.process_name		=   @Process_Name
and			a.component_name  	=   @Component_Name
and			a.btsynonym = 'modeflag'
and			exists (select 'K'
						  from de_fw_Des_service_dataitem b (nolock) , de_report_attributes c (nolock) ,de_task_service_map d (nolock)
						  where  b.customer_name		=	d.customer_name
and			b.project_name		=	d.project_name
and			b.process_name		=	d.process_name
and			b.component_name	=	d.component_name
and			b.servicename			=	d.service_name
and			a.customer_name		=	b.customer_name
and			a.project_name		=	b.project_name
and			a.process_name		=	b.process_name
and			a.component_name	=	b.component_name
and			c.customer_name		=	d.customer_name
and			c.project_name		=	d.project_name
and			c.process_name		=	d.process_name
and			c.component_name	=	d.component_name
and			c.task_name			=	d.task_name 
and b.dataitemname = 'modeflag'    )


insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_bterm_synonym_local_info' + space(4)+ '(componentname,btsynonym,langid,pltext,extended)' + space(4) + 'values' + space(4) +'(' +""""+a.component_name+""""+','+""""+b.btsynonym+""""+','+cast(b.langid as varchar(40))+','+""""+
b.shortpltext+""""+','+'0'+')'

from de_fw_des_service_dataitem a (nolock) , de_fw_req_lang_bterm_synonym b (nolock),de_task_service_map d (nolock),de_report_attributes e (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  =  @Component_Name
and			b.langid					=	@langid
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.dataitemname		=  b.btsynonym
and			a.customer_name		=	d.customer_name
and			a.project_name		=	d.project_name
and			a.process_name		=	d.process_name
and			a.component_name	=	d.component_name
and			a.servicename			=	d.service_name
and			d.customer_name		=	e.customer_name
and			d.project_name		=	e.project_name
and			d.process_name		=	e.process_name
and			d.component_name	=	e.component_name
and			d.task_name			=	e.task_name

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_service' + space(4)+ '(ilbocode,taskname,servicename,rptname)' + space(4) + 'values' + space(4) +'(' +""""+a.ui_name+""""+','+""""+a.task_name+""""+','+""""+b.service_name+""""+','+""""+a.rpt_name+""""+')'

from de_report_attributes a (nolock) , de_task_service_map b (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  =  @Component_Name
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.activity_name		=  b.activity_name
and			a.ui_name				=  b.ui_name
and			a.task_name			=  b.task_name

insert #edk_temp(query)
select '                                    '


select distinct a.ui_name,a.task_name,c.servicename,c.segmentname,c.instanceflag into #service_details --,row_number() over(partition by c.servicename order by c.instanceflag asc) as no into #service_details
from de_action a (nolock) ,  de_task_service_map b (nolock),de_fw_des_service_segment c (nolock),de_report_attributes d (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  	=  @Component_Name
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.activity_name		=  b.activity_name
and			a.ui_name				=  b.ui_name
and			a.task_name			=  b.task_name
and			b.Customer_Name 	=	c.Customer_Name 
and			b.Project_Name		=	c.Project_Name
and			b.Process_Name		=	c.Process_Name
and			b.Component_Name	=	c.Component_Name
and			b.service_name		=  c.servicename
and			b.Customer_Name 	=	d.Customer_Name 
and			b.Project_Name		=	d.Project_Name
and			b.Process_Name		=	d.Process_Name
and			b.Component_Name	=	d.Component_Name
and			b.task_name		=  d.task_name
and 			a.task_type = 'Report'
--order by c.instanceflag


select ui_name,task_name,servicename,segmentname,instanceflag, row_number() over(partition by servicename order by instanceflag asc) as no
into #service_detail
from #service_details



insert #edk_temp(query)
select distinct 'insert @dw_vw_service_segment' + space(4)+ '(ilbocode,taskname,servicename,segmentname,segmentsequence,instanceflag,extended)' + space(4) + 'values' + space(4) +'(' +""""+a.ui_name+""""+','+""""+a.task_name+""""+','+""""+c.servicename+"""
"+','+""""+c.segmentname+""""+','+ cast(e.no as varchar(40))+','+case when cast(c.instanceflag as varchar(40)) = '0' then '0'
	   when cast(c.instanceflag as varchar(40)) = '1' then '1' 
	   else null 
	   end+','+'0'+')'

from de_action a (nolock) ,  de_task_service_map b (nolock),de_fw_des_service_segment c (nolock),de_report_attributes d (nolock),#service_detail e (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  	=  @Component_Name
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.activity_name		=  b.activity_name
and			a.ui_name			=  b.ui_name
and			a.task_name			=  b.task_name
and			b.Customer_Name 	=	c.Customer_Name 
and			b.Project_Name		=	c.Project_Name
and			b.Process_Name		=	c.Process_Name
and			b.Component_Name	=	c.Component_Name
and			b.service_name		=  c.servicename
and			b.Customer_Name 	=	d.Customer_Name 
and			b.Project_Name		=	d.Project_Name
and			b.Process_Name		=	d.Process_Name
and			b.Component_Name	=	d.Component_Name
and			b.task_name			=  d.task_name
and			d.ui_name				=  e.ui_name
and			c.servicename		=  e.servicename
and			c.segmentname		=  e.segmentname
and			c.instanceflag			= e.instanceflag
and 			a.task_type = 'Report'


--and			c.instanceflag	=  '1'
--union
--select distinct 'insert @dw_vw_service_segment' + space(4)+ '(ilbocode,taskname,servicename,segmentname,segmentsequence,instanceflag,extended)' + 
--space(4) + 'values' + space(4) +'(' +""""+a.ui_name+""""+','+""""+a.task_name+""""+','+""""+c.servicename+""""+','+""""+c.segmentname+""""+','+""""+cast(c.instanceflag as varchar(40))+""""+','+'0'+','+'0'+')'

--from de_action a (nolock) ,  de_task_service_map b (nolock),de_fw_des_service_segment c (nolock)
--where		a.customer_name		=	@customer_name
--and			a.project_name		=  @Project_Name
--and			a.process_name		=  @Process_Name
--and			a.component_name  =  @Component_Name
--and			a.Customer_Name 	=	b.Customer_Name 
--and			a.Project_Name		=	b.Project_Name
--and			a.Process_Name		=	b.Process_Name
--and			a.Component_Name	=	b.Component_Name
--and			a.activity_name		=  b.activity_name
--and			a.ui_name				=  b.ui_name
--and			a.task_name			=  b.task_name
--and			b.Customer_Name 	=	c.Customer_Name 
--and			b.Project_Name		=	c.Project_Name
--and			b.Process_Name		=	c.Process_Name
--and			b.Component_Name	=	c.Component_Name
--and			b.service_name		=  c.servicename
--and 		a.task_type 		= 'Report'
--and			c.instanceflag	=  '0'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_service_data_item' + space(4)+ '(ilbocode,taskname,servicename,segmentname,dataitemname,flowdirection,defaultvalue,extended)' + space(4) + 'values' + space(4) +'(' +""""+a.ui_name+""""+','+""""+a.task_name+""""+','+""""+c.se
rvicename+""""+','+""""+c.segmentname+""""+','+""""+c.dataitemname+""""+','+""""+cast(c.flowattribute as varchar(40))+""""+','+""""+c.defaultvalue+""""+','+'0'+')'
from de_action a (nolock) ,  de_task_service_map b (nolock),de_fw_des_service_dataitem c (nolock),de_report_attributes d (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  	=  @Component_Name
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.activity_name		=  b.activity_name
and			a.ui_name			    =  b.ui_name
and			a.task_name		    =  b.task_name
and			b.Customer_Name 	=	c.Customer_Name 
and			b.Project_Name		=	c.Project_Name
and			b.Process_Name		=	c.Process_Name
and			b.Component_Name	=	c.Component_Name
and			b.service_name		=  c.servicename
and			b.Customer_Name 	=	d.Customer_Name 
and			b.Project_Name		=	d.Project_Name
and			b.Process_Name		=	d.Process_Name
and			b.Component_Name	=	d.Component_Name
and			b.task_name		=  d.task_name
and 		     a.task_type 		    = 'Report'
and			c.flowattribute       in ('2','0')
union
select distinct 'insert @dw_vw_service_data_item' + space(4)+ '(ilbocode,taskname,servicename,segmentname,dataitemname,flowdirection,defaultvalue,extended)' + space(4) + 'values' + space(4) +'(' +""""+a.ui_name+""""+','+""""+a.task_name+""""+','+""""+e.se
rvicename+""""+','+""""+e.segmentname+""""+','+""""+c.segment_dataitemname+""""+','+""""+cast(e.flowattribute as varchar(40))+""""+','+""""+e.defaultvalue+""""+','+'0'+')'
from de_action a (nolock) ,  de_task_service_map b(nolock),de_report_action_dataset_dataitem c (nolock),de_report_attributes d (nolock),
de_fw_des_service_dataitem e (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  	=  @Component_Name
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.activity_name		=  b.activity_name
and			a.ui_name			    =  b.ui_name
and			a.task_name		    =  b.task_name
and			b.Customer_Name 	=	c.Customer_Name 
and			b.Project_Name		=	c.Project_Name
and			b.Process_Name		=	c.Process_Name
and			b.Component_Name	=	c.Component_Name
and			b.task_name			=  c.action_name
and			c.Customer_Name 	=	d.Customer_Name 
and			c.Project_Name		=	d.Project_Name
and			c.Process_Name		=	d.Process_Name
and			c.Component_Name	=	d.Component_Name
and			c.action_name		=  d.task_name
and			b.Customer_Name 	=	e.Customer_Name 
and			b.Project_Name		=	e.Project_Name
and			b.Process_Name		=	e.Process_Name
and			b.Component_Name	=	e.Component_Name
and			b.service_name		=  e.servicename
and			c.segment_name	 =  e.segmentname
and			c.segment_dataitemname = e.dataitemname
and 		     a.task_type 		    = 'Report'
and			e.flowattribute       = '1'
and			e.defaultvalue is not null


insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select distinct 'insert @dw_vw_report_task_file_dtl' + space(4)+ '(ilbocode,taskname,report_file_name,report_type)' +space(4) + 'values' + space(4) +'(' +""""+a.ui_name+""""+','+""""+a.task_name+""""+','+""""+b.rpt_name+""""+','+'''Sub'''+')'
from de_report_attributes a (nolock) ,de_report_action_dataset_segment b (nolock)
where	   a.customer_name				=	@customer_name
and		   a.project_name				=  @Project_Name
and		   a.process_name				=  @Process_Name
and		   a.component_name				=  @Component_Name
and		   a.customer_name				=	b.customer_name
and		   a.project_name				=	b.project_name
and		   a.process_name				=	b.process_name
and		   a.component_name				=	b.component_name
and		   a.activity_name				=	b.activity_name
and		   a.ui_name					=	b.ui_name
and		   a.task_name					=	b.action_name
and 	   b.sub_report					=	'Yes'
union
select distinct 'insert @dw_vw_report_task_file_dtl' + space(4)+ '(ilbocode,taskname,report_file_name,report_type)' + space(4) + 'values' + space(4) +'(' +""""+a.ui_name+""""+','+""""+a.task_name+""""+','+""""+b.rpt_name+""""+','+'''Main'''+')'
from de_report_attributes a (nolock) ,de_report_action_dataset_segment b (nolock)
where	   a.customer_name				=	@customer_name
and		   a.project_name				=  @Project_Name
and		   a.process_name				=  @Process_Name
and		   a.component_name				=  @Component_Name
and		   a.customer_name				=	b.customer_name
and		   a.project_name				=	b.project_name
and		   a.process_name				=	b.process_name
and		   a.component_name				=	b.component_name
and		   a.activity_name				=	b.activity_name
and		   a.ui_name					=	b.ui_name
and		   a.task_name					=	b.action_name
and 	   b.sub_report					=	'No'

insert #edk_temp(query)
select '                                    '


insert #edk_temp(query)
select distinct 'insert @dw_vw_report_segment_dataitem' + space(4)+ '(ilbocode,taskname,report_file_name,segment_name,dataitem_name)' + space(4) + 'values' + space(4) +'(' +""""+b.ui_name+""""+','+""""+a.taskname+""""+','+""""+c.rpt_name+""""+','+""""+b.s
egment_name+""""+','+""""+b.segment_dataitemname+""""+')'
from de_fw_req_task_local_info a (nolock) , de_report_action_dataset_dataitem b (nolock),de_report_action_dataset_segment c (nolock)
where		a.customer_name		=	@customer_name
and			a.project_name		=  @Project_Name
and			a.process_name		=  @Process_Name
and			a.component_name  =  @Component_Name
and			a.langid					=	@langid
and			a.Customer_Name 	=	b.Customer_Name 
and			a.Project_Name		=	b.Project_Name
and			a.Process_Name		=	b.Process_Name
and			a.Component_Name	=	b.Component_Name
and			a.taskname				=  b.action_name
and			b.Customer_Name 	=	c.Customer_Name 
and			b.Project_Name		=	c.Project_Name
and			b.Process_Name		=	c.Process_Name
and			b.Component_Name	=	c.Component_Name
and			b.action_name			=  c.action_name
and			b.segment_name		=	c.segment_name


insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select '-- Movement of Data into Temp Table for the provided Component'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'DECLARE	@New_Guid	uniqueIdentifier'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'SET		@New_Guid	= NEWID()'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_component_tmp (componentname,componentdesc, unique_id)
SELECT	componentname, componentdesc, @New_Guid
FROM	@dw_vw_component'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_component_local_info_tmp (componentname,langid, componentdesc,unique_id)
SELECT	componentname, langid,componentdesc, @New_Guid
FROM	@dw_vw_component_local_info'

insert #edk_temp(query)
select '                                    '


insert #edk_temp(query)
select 'INSERT INTO dw_vw_activity_tmp (activityname,componentname, edkactivity,unique_id)
SELECT	activityname, componentname,edkactivity, @New_Guid
FROM	@dw_vw_activity'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_activity_local_info_tmp (activityname,langid, activitydesc,unique_id)
SELECT	activityname, langid,activitydesc, @New_Guid
FROM	@dw_vw_activity_local_info'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_ilbo_tmp (ilbocode,unique_id)
SELECT	ilbocode, @New_Guid
FROM	@dw_vw_ilbo'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_ilbo_local_info_tmp (ilbocode,langid,ilbodesc,unique_id)
SELECT	ilbocode,langid,ilbodesc, @New_Guid
FROM	@dw_vw_ilbo_local_info'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_activity_ilbo_tmp (activityname,ilbocode,unique_id)
SELECT	activityname,ilbocode, @New_Guid
FROM	@dw_vw_activity_ilbo'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_ilbo_task_tmp (ilbocode,taskname,extended,unique_id)
SELECT	ilbocode,taskname,extended, @New_Guid
FROM	@dw_vw_ilbo_task'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_ilbo_task_local_info_tmp (ilbocode,taskname,langid,reportdesc,extended,unique_id)
SELECT	ilbocode,taskname,langid,reportdesc,extended, @New_Guid
FROM	@dw_vw_ilbo_task_local_info'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_bterm_tmp (componentname,btname,bt_datatype,bt_length,extended,unique_id)
SELECT	componentname,btname,bt_datatype,bt_length,extended, @New_Guid
FROM	@dw_vw_bterm'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_bterm_synonym_tmp (componentname,btname,btsynonym,extended,unique_id)
SELECT	componentname,btname,btsynonym,extended, @New_Guid
FROM	@dw_vw_bterm_synonym'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_bterm_synonym_local_info_tmp (componentname,btsynonym,langid,pltext,extended,unique_id)
SELECT	componentname,btsynonym,langid,pltext,extended, @New_Guid
FROM	@dw_vw_bterm_synonym_local_info'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_service_tmp (ilbocode,taskname,servicename,rptname,unique_id)
SELECT	ilbocode,taskname,servicename,rptname, @New_Guid
FROM	@dw_vw_service'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_service_segment_tmp (ilbocode,taskname,servicename,segmentname,segmentsequence,instanceflag,extended,unique_id)
SELECT	ilbocode,taskname,servicename,segmentname, segmentsequence,instanceflag,extended,@New_Guid
FROM	@dw_vw_service_segment'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_service_data_item_tmp (ilbocode,taskname,servicename,segmentname,dataitemname,flowdirection,defaultvalue,extended,unique_id)
SELECT	ilbocode,taskname,servicename,segmentname, dataitemname,flowdirection,defaultvalue,extended,@New_Guid
FROM	@dw_vw_service_data_item'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_report_task_file_dtl_tmp (ilbocode,taskname,report_file_name,report_type,unique_id)
SELECT	ilbocode,taskname,report_file_name,report_type,@New_Guid
FROM	@dw_vw_report_task_file_dtl'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'INSERT INTO dw_vw_report_segment_dataitem_tmp (ilbocode,taskname,report_file_name,segment_name,dataitem_name,unique_id)
SELECT	ilbocode,taskname,report_file_name,segment_name,dataitem_name,@New_Guid
FROM	@dw_vw_report_segment_dataitem'

insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'EXEC Dw_Vw_Report_Metadata_Ins @New_Guid'


insert #edk_temp(query)
select '                                    '

insert #edk_temp(query)
select 'set quoted_identifier on'

insert #edk_temp(query)
select 'set nocount off'

select query 
from #edk_temp
order by seq

drop table #service_details
drop table #service_detail

set nocount off
end










