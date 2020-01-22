CREATE PROCEDURE vw_netgen_errorschema_sp
	@componentname	varchar(60),
	@langid			varchar(2)
AS
BEGIN

	--SERVICE LIST
	SELECT 	DISTINCT
			servicename 
	FROM 	#fw_des_service(NOLOCK) 
	WHERE 	componentname	=	@componentname 
	AND 	statusflag		=	1 
	order by servicename
	
	--METHOD ERROR MAPPING
	SELECT	DISTINCT
			ser.servicename																							  'servicename',
			cast(pb.methodid as varchar)																			  'methodid',
			cast(bre.SPErrorCode as varchar)																		  'sperrorcode' ,
			cast(bre.ErrorID as varchar)																			  'brerrorid', 								
			replace(isnull(isnull(eli.errormessage, err.errormessage), ''),CHAR(10),'')								  'errormessage', 
			replace(isnull(isnull(corr.correctiveaction, err.defaultcorrectiveaction),''),CHAR(10),'')				  'correctiveaction',
			cast(isnull(ctxt.SeverityID ,err.defaultseverity) as varchar)											  'severityid',
			isnull(fctrl.SegmentName,'')																			  'focussegment',
			isnull(fctrl.FocusDataItem,'')																			  'focusdataitem' 
	FROM 	#fw_des_service ser (NOLOCK)
	INNER
	JOIN	#fw_des_processsection_br_is pb (NOLOCK)
	ON		ser.servicename		=	pb.servicename
	AND		ser.componentname	=	@componentname
	AND 	pb.isbr				=	1 	
	INNER
	JOIN	#fw_des_brerror bre (NOLOCK)
	ON		pb.methodid			=	bre.methodid 
	INNER
	JOIN	#fw_des_error err (NOLOCK)
	ON		bre.errorid			=	err.errorid 
	LEFT
	JOIN	#fw_des_context ctxt (NOLOCK)
	ON		err.errorid			=	ctxt.errorid 
	AND		ser.servicename		=	ctxt.errorcontext
	LEFT
	JOIN	#fw_des_corr_action_local_info corr (NOLOCK)
	ON		err.errorid			=	corr.errorid
	AND     corr.[langid]		=	@langid
	LEFT
	JOIN	#fw_des_err_det_local_info eli (NOLOCK)
	ON		err.errorid			=	eli.errorid
	AND		eli.[langid]		=	@langid
	LEFT
	JOIN	#fw_des_focus_control fctrl (NOLOCK) 
	ON		err.errorid			=	fctrl.errorid 
	AND 	ser.servicename		=	fctrl.errorContext  		
	
	ORDER BY ServiceName, methodid, SPErrorCode
	
					
	--ERROR - PLACEHOLDER TEXT
	select	distinct 
			cast(bre.Methodid as varchar)				 'methodid',
			cast(bre.errorid as varchar)				 'errorid',
			cast(bre.Sperrorcode as varchar)			 'sperrorcode',
			diph.servicename							 'servicename',
			cast(diph.SequenceNo as varchar)			 'brseqno',
			diph.Placeholdername						 'placeholdername',
			diph.segmentname							 'segmentname',
			diph.dataitemname							 'dataitemname',
			cast(ps.SequenceNo as varchar)				 'psseqno' , 
			isnull(DIPL.ShortPLText,'')					 'shortpltext' 
	from 	#fw_des_error_placeholder ph (nolock), 				
			#fw_des_brerror bre (nolock), 
			#fw_des_processsection ps (nolock),
			#fw_req_lang_bterm_synonym DIPL (nolock),
			#fw_des_di_placeholder diph (nolock)
	
	Where 	ph.Placeholdername		=	diph.Placeholdername 
	and     ph.Errorid				=	diph.Errorid
	and 	diph.Errorid			=	bre.Errorid 
	and 	diph.Methodid			=	bre.Methodid 
	and 	ps.sectionname			=	diph.sectionname 
	and 	ps.ServiceName			=	diph.ServiceName 
	and     DIPL.BTSynonym			=	diph.dataitemname  
	and 	dipl.[langid]			=	@langid		
	UNION		
	SELECT 	distinct 
			cast(bre.Methodid as varchar)				 'methodid',
			cast(bre.errorid as varchar)				 'errorid',
			cast(bre.Sperrorcode as varchar)			 'sperrorcode',
			di.servicename								 'servicename',
			cast(di.SequenceNo as varchar)				 'brseqno',
			ph.Placeholdername							 'placeholdername',
			di.segmentname								 'segmentname',
			di.dataitemname								 'dataitemname',
			cast(ps.SequenceNo as varchar)				 'psseqno', 
			isnull(DIPL.ShortPLText,'')					 'shortpltext'
	FROM 	#fw_des_error_placeholder ph (NOLOCK),
			#fw_des_be_placeholder beph (NOLOCK), 				
			#fw_des_brerror bre (NOLOCK), 
			#fw_des_processsection ps (NOLOCK),
			#fw_req_lang_bterm_synonym DIPL (NOLOCK), 
			#fw_des_di_parameter di (NOLOCK)
			
	WHERE 	ph.Placeholdername = beph.Placeholdername 
	AND 	ph.Errorid		   = beph.Errorid 
	AND 	beph.Methodid      = bre.Methodid 
	AND 	beph.Errorid    = bre.Errorid 
	AND 	di.Methodid        = beph.methodid 
	AND 	di.ParameterName   = beph.ParameterName 
	AND 	ps.sectionname     = di.sectionname 
	AND 	ps.ServiceName     = di.ServiceName 
	AND     DIPL.BTSynonym	   = di.dataitemname
	AND 	dipl.langid        = @langid 
	ORDER 	BY		 4,1,2
END