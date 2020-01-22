/************************************************************************************
procedure name and id   vw_netgen_populate_temptable_sp
name of the author      Kiruthika R
date created            
query file name         vw_netgen_populate_temptable_sp.sql
modifications history 
************************************************************************************/

CREATE procedure vw_netgen_populate_temptable_sp
 @customername	varchar(30),  
 @projectname	varchar(30),  
 @componentname varchar(30),  
 @ecrno			varchar(30)
 as
 begin
 Set nocount on
 declare @m_errorid int
    insert into #de_listedit_view_datamap (activity_name, ilbocode, controlid, viewname, listedit, instance) 
    exec de_listedit_ctrl_map @customername, @projectname, @ecrno



    insert into #fw_req_activity (activitydesc, activityid, activityname, activityposition, activitysequence, activitytype,
								  componentname, iswfenabled ,UpdUser, Updtime) 
    select activitydesc, activityid, activityname, activityposition, activitysequence, activitytype,
		   componentname,iswfenabled ,host_name(), getdate() 
	from de_fw_req_publish_activity_vw_fn (@customername, @projectname, @ecrno)  


    insert into #fw_req_activity_ilbo (activityid, ilbocode, activityname, UpdUser, Updtime) 
    select activityid, ilbocode, activityname , host_name(), getdate() 
	from  de_fw_req_publish_activity_ilbo_vw_fn (@customername, @projectname, @ecrno) 


    insert into #fw_req_ilbo (aspofilepath, description, ilbocode, ilbotype, progid, statusflag, UpdUser, Updtime) 
    select aspofilepath, description, ilbocode, ilbotype, progid, statusflag , host_name(), getdate() 
	from de_fw_req_publish_ilbo_vw_fn (@customername, @projectname, @ecrno) 

    
    insert into #fw_req_ilbo_control_property (controlid, ilbocode, propertyname, type, value, viewname, UpdUser, Updtime) 
    select controlid, ilbocode, propertyname, type, value,
	       viewname , host_name(), getdate() 
	from  de_fw_req_publish_ilbo_control_property_vw_fn (@customername, @projectname, @ecrno)


    insert into #fw_req_ilbo_view (btsynonym, controlid, displayflag, displaylength, ilbocode, viewname, isItkCtrl, UpdUser, Updtime ) 
    select btsynonym, controlid, displayflag, displaylength,
		   ilbocode,viewname, 'n', host_name(), getdate()
	from   de_fw_req_publish_ilbo_view_vw_fn (@customername, @projectname, @ecrno) 

	  


    insert into #fw_req_bterm (btdesc, btname, datatype, isbterm, length, maxvalue, minvalue, precisiontype , UpdUser, Updtime) 
    select btdesc, btname, LOWER(LTRIM(RTRIM(datatype))), isbterm, length, maxvalue, minvalue, LOWER(LTRIM(RTRIM(precisiontype))) ,
		   host_name(), getdate() 
	from    de_fw_req_publish_bterm_vw_fn (@customername, @projectname, @ecrno) 


    insert into #fw_req_bterm_synonym (btname, btsynonym, UpdUser, Updtime)
    select btname, btsynonym, host_name(), getdate() 
	from de_fw_req_publish_bterm_synonym_vw_fn (@customername, @projectname, @ecrno) 




    insert into #fw_req_ilbo_tab_properties (ilbocode, propertyname, tabname, value, UpdUser, Updtime) 
    select ilbocode, propertyname, tabname, value , host_name(), getdate() 
	from de_fw_req_publish_ilbo_tab_properties_vw_fn (@customername, @projectname, @ecrno) 


    insert into #fw_req_activity_ilbo_task (activityid, datasavingtask, ilbocode, linktype, taskname,activityname, Taskconfirmation, 
										    usageid, ddt_control_id, ddt_view_name, UpdUser, Updtime, Tasktype)
    select activityid, datasavingtask, ilbocode, linktype, taskname,
		  activityname, Taskconfirmation,usageid, ddt_control_id,
		   ddt_view_name, host_name(), getdate(), Tasktype 
	from de_fw_req_publish_activity_ilbo_task_vw_fn (@customername, @projectname, @ecrno)

	
    insert into #fw_req_task (taskdesc, taskname, tasktype, UpdUser, Updtime) 
    select taskdesc, LOWER(LTRIM(RTRIM(taskname))), LOWER(LTRIM(RTRIM(tasktype))) , host_name(), getdate() 
	from de_fw_req_publish_task_vw_fn (@customername, @projectname, @ecrno) 


    insert into #fw_req_bterm_enumerated_option (btname, langid, optioncode, optiondesc, sequenceno, UpdUser, Updtime) 
    select btname, langid, optioncode, optiondesc, sequenceno , host_name(), getdate() 
	from de_fw_req_publish_bterm_enumerated_option_vw_fn (@customername, @projectname, @ecrno) 


    insert into #fw_req_ilbo_link_publish (activityid, description, ilbocode, linkid, taskname, UpdUser, Updtime) 
    select activityid, description, ilbocode, linkid, taskname , host_name(), getdate() 
	from de_fw_req_publish_ilbo_link_publish_vw_fn (@customername, @projectname, @ecrno) 


    insert into #fw_req_ilbo_data_publish (controlid, controlvariablename, dataitemname, flowtype, havemultiple, ilbocode, iscontrol,
										   linkid, mandatoryflag, viewname, UpdUser, Updtime) 
    select controlid, controlvariablename, dataitemname, flowtype,
		   havemultiple, ilbocode, iscontrol,linkid, mandatoryflag, viewname ,
		   host_name(), getdate() 
	from de_fw_req_publish_ilbo_data_publish_vw_fn(@customername, @projectname, @ecrno) 


    insert into #fw_req_ilbo_data_use (childilbocode, controlid, controlvariablename, dataitemname, flowtype, iscontrol,
									   linkid, parentilbocode,primarydata, retrievemultiple, taskname, viewname, UpdUser, Updtime) 
    select childilbocode, controlid, controlvariablename,
		   dataitemname, flowtype, iscontrol, linkid,parentilbocode,primarydata,
		   retrievemultiple, taskname, viewname , host_name(), getdate() 
	from de_fw_req_publish_ilbo_data_use_vw_fn (@customername, @projectname, @ecrno) 


    insert into #fw_req_ilbo_linkuse (childilbocode, childorder, linkid, parentilbocode, taskname, posttask, post_linktask,
									  UpdUser, Updtime)
    select childilbocode, childorder, linkid, parentilbocode, taskname, 
		   post_task , post_linktask, host_name(), getdate() 
	from de_fw_req_publish_ilbo_linkuse_vw_fn (@customername, @projectname, @ecrno) 


    insert into #fw_des_ilbo_services (ilbocode, isprepopulate, servicename, UpdUser, Updtime,	IsUniversalPersonalization) 
    select ilbocode, isprepopulate, servicename , host_name(), getdate() ,	IsUniversalPersonalization		
	from de_fw_des_publish_ilbo_services_vw_fn (@customername, @projectname, @ecrno) 


    insert into #fw_des_service_dataitem 
    select  LOWER(LTRIM(RTRIM(dataitemname))) ,defaultvalue , flowattribute ,ispartofkey ,mandatoryflag ,
			LOWER(LTRIM(RTRIM(segmentname))) , LOWER(LTRIM(RTRIM(servicename))), itk_dataitem, 'dbo', getdate(), '' 
	From de_fw_des_publish_service_dataitem_vw_fn (@customername, @projectname, @ecrno) 


    insert into #fw_des_service  ( isintegser, componentname, processingtype, servicename, servicetype, statusflag, svconame, isCached, 
								   isZipped, SetKey_Pattern, ClearKey_Pattern)
    select  isintegser,LOWER(LTRIM(RTRIM(componentname))), processingtype, LOWER(LTRIM(RTRIM(servicename))), servicetype, 1,
			svconame, isCached,isZipped, SetKey_Pattern, ClearKey_Pattern  
	from  de_fw_des_publish_service_vw_fn (@customername, @projectname, @ecrno) 


    insert  into #fw_des_service_segment ( bocode, bosegmentname, instanceflag, mandatoryflag, parentsegmentname, segmentname,
										   SegmentSequence, servicename ,process_selrows, process_updrows,process_selupdrows)
    select  bocode, bosegmentname, instanceflag, mandatoryflag, parentsegmentname, LOWER(LTRIM(RTRIM(segmentname))), 
		    SegmentSequence, LOWER(LTRIM(RTRIM(servicename))),LOWER(ISNULL(process_selrows,'')), LOWER(ISNULL(process_updrows,'')),
			LOWER(ISNULL(process_selupdrows,''))
	 from de_fw_des_publish_service_segment_vw_fn (@customername, @projectname, @ecrno) 


    insert into #fw_des_ilbo_service_view_datamap (activityid, controlid, dataitemname, ilbocode, iscontrol, segmentname, servicename, taskname,
												   variablename, viewname, page_bt_synonym, UpdUser, Updtime) 
    select activityid, LOWER(LTRIM(RTRIM(controlid))), LOWER(LTRIM(RTRIM(dataitemname))), LOWER(LTRIM(RTRIM(ilbocode))), iscontrol, LOWER(LTRIM(RTRIM(segmentname))), LOWER(LTRIM(RTRIM(servicename))),
		   LOWER(LTRIM(RTRIM(taskname))),variablename, LOWER(LTRIM(RTRIM(viewname))), LOWER(LTRIM(RTRIM(page_bt_synonym))), host_name(), getdate() 
	from de_fw_des_publish_ilbo_service_view_datamap_vw_fn (@customername, @projectname, @ecrno)


    insert into #fw_des_ilbo_service_view_datamap (activityid, controlid, dataitemname, ilbocode, iscontrol, segmentname, servicename,
												   taskname, variablename, viewname, UpdUser, Updtime) 
    select distinct b.activityid,'','',LOWER(LTRIM(RTRIM(b.ilbocode))),'','',LOWER(LTRIM(RTRIM(service_name))),LOWER(LTRIM(RTRIM(task_name))) TaskName,'','','','' 
	from de_published_task_service_map_fn (@customername, @projectname, @ecrno) a, 
		 #fw_req_activity_ilbo b (nolock) 
	where  a.activity_name collate database_default = b.activityname 
	and   not exists (select 'x' from #fw_des_ilbo_service_view_datamap c (nolock)
					  where a.ui_name   collate database_default = c.ilbocode
					  and   a.task_name collate database_default = c.taskname)

	
    insert into #fw_req_ilbo_control (controlid, ilbocode, tabname, type, listedit, UpdUser, Updtime)
    select LOWER(LTRIM(RTRIM(controlid))), LOWER(LTRIM(RTRIM(ilbocode))), LOWER(LTRIM(RTRIM(tabname))), LOWER(LTRIM(RTRIM(type))),
		   LOWER(LTRIM(RTRIM(listedit))), host_name(), getdate() 
	from de_fw_req_publish_ilbo_control_vw_fn (@customername, @projectname, @ecrno) 
    

    insert into #fw_des_task_segment_attribs (activityid, ilbocode, taskname, servicename, segmentname, combofill, UpdUser, Updtime) 
    select a.activityid, LOWER(LTRIM(RTRIM(a.ilbocode))), LOWER(LTRIM(RTRIM(a.taskname))), LOWER(LTRIM(RTRIM(a.servicename))), LOWER(LTRIM(RTRIM(a.segmentname))),
		   case b.tasktype when 'fetch' then 0 else a.combofill end , host_name(), getdate() 
	from de_fw_des_publish_task_segment_attribs_vw_fn (@customername, @projectname, @ecrno) a,
		 #fw_req_activity_ilbo_task b(nolock)
	where a.ilbocode collate database_default = b.ilbocode
	and   a.taskname collate database_default = b.taskname

	update #fw_des_task_segment_attribs
	set   combofill = 1
	from de_fw_des_publish_task_segment_attribs_vw_fn (@customername, @projectname, @ecrno) a,
		 #fw_req_activity_ilbo_task b(nolock),
		 #fw_des_ilbo_service_view_datamap c(nolock),
		 #fw_req_ilbo_control              d(nolock)
	where a.ilbocode collate database_default = b.ilbocode
	and   a.taskname collate database_default = b.taskname
	and   b.tasktype                          = 'fetch'
	and   a.ilbocode collate database_default = c.ilbocode
	and   a.taskname collate database_default = c.taskname
	and   a.segmentname collate database_default = c.segmentname
	and   c.ilbocode collate database_default = d.ilbocode
	and   c.controlid collate database_default = d.controlid
	and   d.type                               = 'rslistedit'


	      

    insert into #fw_req_activity_ilbo_task_extension_map (componentname, activityid, ilbocode, taskname, resultantaspname, sessionvariable, UpdUser, Updtime) 
    select LOWER(LTRIM(RTRIM(componentname))), activityid, LOWER(LTRIM(RTRIM(ilbocode))), LOWER(LTRIM(RTRIM(taskname))), LOWER(LTRIM(RTRIM(resultantaspname))), 
		   LOWER(LTRIM(RTRIM(sessionvariable))) , host_name(), getdate() 
	from de_fw_req_publish_activity_ilbo_task_extension_map (nolock) 
	where  customername = @customername  
	 and   projectname  = @projectname 
	 and   ecrno        = @ecrno
	 
  


    insert into #fw_req_ilbo_layout_control (ilbocode, tabname, controlid, type) 
    select LOWER(LTRIM(RTRIM(ilbocode))), LOWER(LTRIM(RTRIM(tabname))), LOWER(LTRIM(RTRIM(controlid))), LOWER(LTRIM(RTRIM(type))) 
	from de_fw_req_ilbo_layout_control_vw_fn (@customername, @projectname, @ecrno)

    insert into #fw_req_lang_bterm_synonym (BTSynonym, Langid, ForeignName, LongPLText, ShortPLText, ShortDesc, LongDesc, UpdUser, UpdTime) 
    select BTSynonym, Langid, ForeignName, LongPLText, ShortPLText, ShortDesc, LongDesc, host_name(),getdate() 
	from de_fw_req_publish_lang_bterm_synonym_vw_fn (@customername, @projectname, @ecrno) 


    insert into #fw_req_precision (PrecisionType, TotalLength, DecimalLength, UpdUser, UpdTime) 
    select PrecisionType, TotalLength, DecimalLength, host_name(), getdate() 
	from de_fw_req_publish_precision_vw_fn (@customername, @projectname, @ecrno) 


    
    Insert into #fw_des_be_placeholder ( errorid, methodid, parametername, placeholdername ) 
    select errorid, methodid, parametername, placeholdername  
	from de_fw_des_publish_be_placeholder_vw_fn (@customername, @projectname, @ecrno) 


    insert  into #fw_des_br_logical_parameter ( btname,  flowdirection, logicalparametername, logicalparamseqno, methodid, 
												recordsetname, rssequenceno, spparametertype )
    select  btname, flowdirection, LOWER(LTRIM(RTRIM(logicalparametername))), logicalparamseqno, methodid, 
			recordsetname, rssequenceno, LOWER(LTRIM(RTRIM(spparametertype))) 
	from de_fw_des_publish_br_logical_parameter_vw_fn (@customername, @projectname, @ecrno) 


    insert  into #fw_des_brerror (  errorid, methodid ,sperrorcode )
    select  errorid, methodid, sperrorcode 
	from de_fw_des_publish_brerror_vw_fn (@customername, @projectname, @ecrno) 



    insert  into #fw_des_businessrule ( accessesdatabase, bocode, broname, dispid,   isintegbr, methodid, methodname, operationtype, statusflag, systemgenerated )
    select  accessesdatabase, bocode, broname,  dispid,   isintegbr, methodid, LOWER(LTRIM(RTRIM(methodname))), operationtype,  statusflag, systemgenerated 
	from  de_fw_des_publish_businessrule_vw_fn (@customername, @projectname, @ecrno) 


    insert  into #fw_des_context ( correctiveaction,  errorcontext, errorid, severityid )
    select  correctiveaction,   errorcontext, errorid, severityid 
	from de_fw_des_publish_context_vw (nolock) 
	where  customername = @customername  
	 and   projectname  = @projectname 
	 and   ecrno        = @ecrno
    
    insert  into #fw_des_di_parameter (  dataitemname,  methodid, parametername, sectionname, segmentname, sequenceno, servicename )
    select  LOWER(LTRIM(RTRIM(dataitemname))),  methodid, LOWER(LTRIM(RTRIM(parametername))), LOWER(LTRIM(RTRIM(sectionname))),
		    LOWER(LTRIM(RTRIM(segmentname))), sequenceno, LOWER(LTRIM(RTRIM(servicename)))
	from de_fw_des_publish_di_parameter_vw_fn  (@customername, @projectname, @ecrno)


    insert  into #fw_des_di_placeholder ( dataitemname,  errorid, methodid, placeholdername, sectionname, segmentname, sequenceno, servicename )
    select  LOWER(LTRIM(RTRIM(dataitemname))),  errorid, methodid, placeholdername, LOWER(LTRIM(RTRIM(sectionname))), LOWER(LTRIM(RTRIM(segmentname))), 
		    sequenceno, LOWER(LTRIM(RTRIM(servicename))) 
	from de_fw_des_publish_di_placeholder_vw_fn (@customername, @projectname, @ecrno) 


    insert  into #fw_des_error ( defaultcorrectiveaction, defaultseverity,  detaileddesc, displaytype,   errorid, errormessage, errorsource, reqerror )
    select  LTRIM(RTRIM(defaultcorrectiveaction)), defaultseverity,  detaileddesc, displaytype,   errorid, LTRIM(RTRIM(errormessage)), errorsource, reqerror 
	from de_fw_des_publish_error_vw_fn (@customername, @projectname, @ecrno) 


    insert  into #fw_des_integ_serv_map ( callingdataitem, callingsegment, callingservicename, integdataitem, integsegment, 
										  integservicename, sectionname, sequenceno )
    select  LOWER(LTRIM(RTRIM(callingdataitem))), LOWER(LTRIM(RTRIM(callingsegment))), LOWER(LTRIM(RTRIM(callingservicename))), LOWER(LTRIM(RTRIM(integdataitem))),
			LOWER(LTRIM(RTRIM(integsegment))),LOWER(LTRIM(RTRIM(integservicename))), LOWER(LTRIM(RTRIM(sectionname))), sequenceno 
	from de_fw_des_publish_integ_serv_map_vw_fn (@customername, @projectname, @ecrno) 

	 insert into #fw_task_service_map (activity_name,service_name,task_name,ui_name ) 
    select activity_name,service_name,task_name,ui_name 
	from de_published_task_service_map_fn (@customername, @projectname, @ecrno)

	
    insert into #fw_des_processsection (  controlexpression, processingtype, sectionname, sectiontype, sequenceno, servicename)
    select  case controlexpression when '' then NUll else controlexpression end, processingtype,  LOWER(LTRIM(RTRIM(sectionname))),
			sectiontype, sequenceno, LOWER(LTRIM(RTRIM(servicename)))
	from de_fw_des_publish_processsection_vw_fn (@customername, @projectname, @ecrno) 

    insert  into #fw_des_processsection_br_is ( connectivityflag, controlexpression, executionflag, integservicename, isbr,  methodid,
											    sectionname, sequenceno, servicename,Method_Ext, methodid_ref, methodname_ref, sequenceno_ref,
												sectionname_ref, ps_sequenceno_ref,SpecID,SpecName,SpecVersion,Path,OperationID,OperationVerb)
    select  connectivityflag, controlexpression, executionflag, LOWER(LTRIM(RTRIM(integservicename))), isbr,  methodid, 
			LOWER(LTRIM(RTRIM(sectionname))), sequenceno, LOWER(LTRIM(RTRIM(servicename))), '' as Method_Ext, '' as methodid_ref,
			'' as methodname_ref, '' as sequenceno_ref,'' as sectionname_ref, '' as ps_sequenceno_ref ,
			SpecID,SpecName,SpecVersion,Path,OperationID,OperationVerb
	from de_fw_des_publish_processsection_br_is_vw_fn (@customername, @projectname, @ecrno)  
	


    insert  into #fw_des_sp ( methodid, sperrorprotocol, spname )
    select  methodid, sperrorprotocol, LOWER(LTRIM(RTRIM(spname))) 
	from de_fw_des_publish_sp_vw_fn (@customername, @projectname, @ecrno) 

	

    insert into #fw_des_error_placeholder (ErrorID,PlaceholderName) 
    select ErrorID,PlaceholderName 
	from  de_fw_des_publish_ERROR_PLACEHOLDER_vw_fn (@customername, @projectname, @ecrno) 


    
    insert into #fw_req_ilbo_task_rpt (ilbocode, taskname, PageName, ProcessingType, ContextName, ReportType) 
    select LOWER(LTRIM(RTRIM(ilbocode))), LOWER(LTRIM(RTRIM(taskname))), LOWER(LTRIM(RTRIM(PageName))), LOWER(LTRIM(RTRIM(ProcessingType))),
		   LOWER(LTRIM(RTRIM(ContextName))), LOWER(LTRIM(RTRIM(ReportType))) 
	from  de_fw_req_publish_ilbo_task_rpt_vw_fn (@customername, @projectname, @ecrno) 

	
	
    insert into #fw_des_focus_control (errorcontext,errorid,controlid,segmentname,focusdataitem,methodid,method_name) 
    select errorcontext,errorid, lower(controlid),LOWER(LTRIM(RTRIM(segmentname))),LOWER(LTRIM(RTRIM(focusdataitem))),methodid,methodname
	from de_fw_des_publish_focus_control_vw_fn (@customername, @projectname, @ecrno)  



    insert into     #fw_des_err_det_local_info (ErrorID, ErrorMessage, DetailedDesc, LangId ) 
    select ErrorID, LTRIM(RTRIM(ErrorMessage)), DetailedDesc, LangId  
	from de_fw_des_publish_err_det_local_info_vw_fn (@customername, @projectname, @ecrno) 

    insert into  #fw_des_corr_action_local_info (ErrorID, ErrorContext, CorrectiveAction, LangId) 
    select ErrorID, ErrorContext, LTRIM(RTRIM(CorrectiveAction)), LangId 
	from de_fw_des_publish_corr_action_local_info_vw (nolock)
	where  customername = @customername  
	 and   projectname  = @projectname 
	 and   ecrno        = @ecrno

                    
    

    insert into  #de_published_ui_page( activity_name, component_name, horder, page_bt_synonym, page_doc, page_prefix, timestamp, ui_name, 
										ui_page_sysid, ui_sysid, vorder, req_no)
    select activity_name, component_name, horder, page_bt_synonym, page_doc, page_prefix, timestamp, ui_name,
		   ui_page_sysid, ui_sysid, vorder, req_no 
	from de_published_ui_page_vw_fn (@customername, @projectname, @ecrno) 


    insert into  #fw_ezeeview_sp(component_name, activity_name, ui_name, taskname, page_bt_synonym, Link_ControlName, Target_SPName,
							     Link_Caption, Linked_Component, Linked_Activity, Linked_ui)
    select component_name, activity_name, LOWER(LTRIM(RTRIM(ui_name))), LOWER(LTRIM(RTRIM(task_name))), page_bt_synonym, Link_ControlName, LOWER(LTRIM(RTRIM(Target_SPName))),
		   Link_Caption, Linked_Component, Linked_Activity, Linked_ui 
	from de_published_ezeeview_sp_vw_fn (@customername, @projectname, @ecrno)


    insert into  #fw_ezeeview_spparamlist(component_name, activity_name, ui_name, page_bt_synonym, Link_ControlName, Target_SPName,
										  ParameterName, Mapped_Control, Link_Caption, taskname, controlid, viewname)
    select component_name, activity_name, ui_name, page_bt_synonym, Link_ControlName, Target_SPName, LOWER(LTRIM(RTRIM(ParameterName))), 
		   LOWER(LTRIM(RTRIM(Mapped_Control))), Link_Caption, task_name, LOWER(LTRIM(RTRIM(control_id))), LOWER(LTRIM(RTRIM(view_name))) 
	from de_published_ezeeview_spparamlist_vw_fn (@customername, @projectname, @ecrno) 


    


    insert into #fw_extjs_control_dtl (activityname, uiname, taskname, servicename, segmentname, sectiontype, controlid)
    select LOWER(LTRIM(RTRIM(activity_name))), LOWER(LTRIM(RTRIM(ui_name))), LOWER(LTRIM(RTRIM(task_name))), LOWER(LTRIM(RTRIM(service_name))), 
		   LOWER(LTRIM(RTRIM(segment_name))), LOWER(LTRIM(RTRIM(section_type))), LOWER(LTRIM(RTRIM(control_id))) 
	from de_published_extjs_control_dtl_vw_fn (@customername, @projectname, @ecrno)  


    insert into #de_published_action(activity_name, component_name, page_bt_synonym, primary_control_bts, task_descr, task_name, task_pattern,
								     task_seq, task_type, ui_name,task_confirm_msg, task_status_msg, usageid, ddt_page_bt_synonym, 
									 ddt_control_bt_synonym, ddt_control_id, ddt_view_name, task_process_msg)
    select activity_name, component_name, page_bt_synonym, LOWER(LTRIM(RTRIM(primary_control_bts))), task_descr, LOWER(LTRIM(RTRIM(task_name))), task_pattern, task_seq, task_type, LOWER(LTRIM(RTRIM(ui_name))), 
	task_confirm_msg, task_status_msg, usageid, ddt_page_bt_synonym, ddt_control_bt_synonym, ddt_control_id, ddt_view_name, task_process_msg 
	from de_published_action_vw (nolock)
	where customer_name = @customername  
	and   project_name  = @projectname  
	and   ecrno         = @ecrno

    insert into #fw_des_publish_ilbo_service_view_attributemap (activityid, controlid, dataitemname, ilbocode, segmentname, servicename, taskname, viewname, 
																PropertyType, PropertyName, Page_BT_Synonym) 
    select activityid, LOWER(LTRIM(RTRIM(controlid))), LOWER(LTRIM(RTRIM(dataitemname))), LOWER(LTRIM(RTRIM(ilbocode))), LOWER(LTRIM(RTRIM(segmentname))),
		   LOWER(LTRIM(RTRIM(servicename))), LOWER(LTRIM(RTRIM(taskname))), LOWER(LTRIM(RTRIM(viewname))), propertytype,
		   propertyname, LOWER(LTRIM(RTRIM(Page_BT_Synonym))) 
	from de_fw_des_publish_ilbo_service_view_attributemap_vw (nolock) 
	where  customername = @customername  
	 and   projectname  = @projectname 
	 and   ecrno        = @ecrno

    insert into #fw_req_ilbo_pivot_fields(component_name, activity_name, ilbocode, PageName, controlid, viewname, rowlabel, columnlabel,
										  fieldValue, rowlabelseq, columnlabelseq, valueseq, ValueFunction)
    select component_name, activity_name, LOWER(LTRIM(RTRIM(ui_name))), LOWER(LTRIM(RTRIM(isnull(page_name,'')))), LOWER(LTRIM(RTRIM(isnull(control_id,'')))), isnull(view_name,''), isnull(rowlabel,''),
		   isnull(columnlabel,''), isnull(fieldValue,''), isnull(rowlabelseq,0), isnull(columnlabelseq,0), isnull(valueseq,0),isnull(ValueFunction,'')
    from de_published_pivot_fields_vw_fn (@customername,@projectname,@ecrno)
    order by component_name, activity_name, ui_name, page_name, control_id, view_name
    
    insert into #de_published_ui_control_association_map(component_name, activity_name, ilbocode, PageName, section_bt_synonym, controlid, viewname, PropertyName, 
	PropertyControl, PropertyViewName, TaskName)
    select component_name, activity_name, ui_name, isnull(page_bt_synonym,''), isnull(section_bt_synonym,''), isnull(control_id,''), isnull(View_Name,''), isnull(PropertyName,''), 
	isnull(Property_ControlID,''), isnull(Property_ViewName,''), isnull(task_name,'')
    from de_published_ui_control_association_map_vw_fn(@customername,@projectname,@ecrno)
    order by component_name, activity_name, ui_name, page_bt_synonym, section_bt_synonym, control_id               
    
	--qlik
    insert into #de_published_subscription_dataitem(component_name, activity_name, ilbocode, PageName, TaskName, Subscribed_bt_synonym, Controlid, Viewname, Qlik_dataitem)
    select component_name, activity_name, ui_name, isnull(page_bt_synonym,''), isnull(Task_Name,''), isnull(Subscribed_bt_synonym,''), isnull(subscribed_control_name,''), isnull(subscribed_view_name,''), isnull(Qlik_dataitem,'')
    from de_published_subscription_Dataitem_vw_fn(@customername,@projectname,@ecrno)
    order by component_name, activity_name, ui_name, page_bt_synonym, subscribed_control_name                              

	insert into #de_fw_des_publish_task_callout(component_name, activity_name, ui_name, task_name, CalloutName, CalloutMode)
	select LOWER(LTRIM(RTRIM(component_name))), LOWER(LTRIM(RTRIM(activity_name))), LOWER(LTRIM(RTRIM(ui_name))), 
		   LOWER(LTRIM(RTRIM(task_name))), LOWER(LTRIM(RTRIM(isnull(CalloutName,'')))), LOWER(LTRIM(RTRIM(isnull(CalloutMode,''))))
	from de_fw_des_publish_task_callout_vw_fn (@customername,@projectname,@ecrno)
	order by component_name, activity_name, ui_name, task_name, calloutname 
	
	insert into #de_fw_des_publish_task_callout_segement(component_name, activity_name, ui_name, task_name, CalloutName, SegmentName, InstanceFlag, SegmentSequence, SegmentFlowAttribute)
	select LOWER(LTRIM(RTRIM(component_name))), LOWER(LTRIM(RTRIM(activity_name))), LOWER(LTRIM(RTRIM(ui_name))),
		   LOWER(LTRIM(RTRIM(task_name))),LOWER(LTRIM(RTRIM(isnull(CalloutName,'')))), LOWER(LTRIM(RTRIM(isnull(SegmentName,'')))),
		   InstanceFlag, SegmentSequence,LOWER(LTRIM(RTRIM(SegmentFlowAttribute)))
	from de_fw_des_publish_task_callout_segement_vw_fn (@customername,@projectname,@ecrno)
	order by component_name, activity_name, ui_name, task_name, calloutname, SegmentSequence, SegmentName 
	
	insert into #de_fw_des_publish_task_callout_dataitem(component_name, activity_name, ui_name, task_name, CalloutName,
														 SegmentName, DataItemName, FlowAttribute, ControlID, ViewName)
	select LOWER(LTRIM(RTRIM(component_name))), LOWER(LTRIM(RTRIM(activity_name))), LOWER(LTRIM(RTRIM(ui_name))),
	       LOWER(LTRIM(RTRIM(task_name))), LOWER(LTRIM(RTRIM(isnull(CalloutName,'')))), LOWER(LTRIM(RTRIM(isnull(SegmentName,'')))),
		   LOWER(LTRIM(RTRIM(isnull(DataItemName,'')))), LOWER(LTRIM(RTRIM(FlowAttribute))),
		   LOWER(LTRIM(RTRIM(ControlID))), LOWER(LTRIM(RTRIM(ViewName)))
	from de_fw_des_publish_task_callout_dataitem_vw_fn (@customername,@projectname,@ecrno)
	order by component_name, activity_name, ui_name, task_name, calloutname, SegmentName, DataItemName 

	with cte as
		(
		select b.servicename,b.segmentname,
		case when count (distinct  b.flowattribute) =1 then max(b.flowattribute) 
		when count (distinct   b.flowattribute) >2 then 2
		when (count (distinct  b.flowattribute) =2 and max (b.flowattribute) <3) then 2 
		when (count (distinct  b.flowattribute) =2 and max (b.flowattribute) =3) then min(b.flowattribute)
		else  2 end 'flowattribute'
		from   	#fw_des_service_dataitem b(nolock)
		group by b.servicename,b.segmentname)
		
		update a
		set a.flowattribute = b.flowattribute
		from #fw_des_service_segment a(nolock),
			 cte                     b(nolock)
		where a.servicename = b.servicename
		and   a.segmentname = b.segmentname

	exec De_il_PublishRVWObjects_upd @componentname

	exec de_il_fw_des_iu_save_service_ecr_update @componentname,1,'PUBLISHED',@m_errorid Output
	
    EXEC de_up_create_virtualmethod  @customername,@projectname,@componentname,@ecrno	

	UPDATE #fw_des_processsection set IsUniversalPersonalization = 
		case when exists (	select	'X'
							from	de_published_up_defaulting_dtl dtl (nolock),
									#fw_task_service_map ser (nolock)
							WHERE	dtl.activity_name		= ser.activity_name COLLATE DATABASE_DEFAULT
							AND		dtl.ui_name				= ser.ui_name COLLATE DATABASE_DEFAULT
							AND		dtl.task_name			= ser.task_name COLLATE DATABASE_DEFAULT
							AND		dtl.customer_name		= @customername
							AND		dtl.project_name		= @projectname
							AND		dtl.ecrno				= @ecrno) 
							AND		sectionname like '%_up' then 'Y'				
		ELSE 'N'
		END 

	EXEC vwnetgen_Api_Tree_Form @customername,@projectname,@componentname,@ecrno	

 Set nocount off

 end  