/************************************************************************************************/
/* procedure		de_up_create_virtualmethod													*/
/* description		SP to create a virtual method for universal personalization					*/
/************************************************************************************************/
/* project		Universal Personalization														*/
/* version																						*/
/************************************************************************************************/
/* referenced																					*/
/* tables																						*/
/************************************************************************************************/
/* development history																			*/
/************************************************************************************************/
/* author		Jeya Latha K																	*/
/* date			05/Sep/2019																		*/
/************************************************************************************************/
CREATE procedure de_up_create_virtualmethod
 @customername			ENGG_NAME,  
 @projectname			ENGG_NAME,  
 @componentname			ENGG_NAME,  
 @ecrno					ENGG_NAME
 as
 begin
 Set nocount on

 DECLARE	@ispartofkey		engg_seqno,
			@mandatoryflag		engg_seqno,
			@tmp_processname	engg_name,
			@tmp_actname		engg_name,
			@tmp_uiname			engg_name,
			@tmp_pagename		engg_name,
			@tmp_sectionname	engg_name,
			@tmp_coumnbt		engg_name,
			@tmp_taskname		engg_name,
			@tmp_nexttask		engg_name,
			@tmp_controlbt		engg_name,
			@tmp_paramname		engg_name,
			@tmp_flowdir		engg_flag,
			@tmp_controlid		engg_name,
			@tmp_viewname		engg_name,
			@tmp_primarycontrol	engg_name,
			@tmp_Segmentname	engg_name,
			@tmp_controlprefix	engg_name,
			@tmp_servicename	engg_name,
			@tmp_btname			engg_name,
			@tmp_displayflag	engg_flag,
			@tmp_visiblelength	engg_length,
			@tmp_paramseqno		engg_seqno,
			@tmp_methodname		engg_name,
			@tmp_spparamtype	engg_name,
			@tmp_bocode			engg_name,
			@tmp_methodid		engg_Seqno,
			@tbl_methodid		engg_Seqno,
			@tmp_spname			engg_name,
			@tmp_datatype		engg_name,
			@tmp_sectionbt		engg_name,
			@tmp_compprefix		engg_name,
			@tmp_Activityid		engg_Seqno,
			@tmp_pageprefix		engg_name,
			@tmp_seqno			engg_Seqno,
			@contextseg			engg_name	
		
	set		@tmp_methodid = 0
	select	@tmp_nexttask = ''
	SET		@contextseg		= 'fw_context'

	SELECT	@tmp_processname		= process_name
	FROM	de_ui_ico (nolock)
	WHERE	customer_name		=	@customername
	AND		project_name		=	@projectname
	AND		component_name		=	@componentname
	AND		ico_no				=	@ecrno

	Declare methodcur insensitive cursor  for   
	select	DISTINCT 
			upd.activity_name,			upd.ui_name,			upd.page_bt_synonym,		upd.section_bt_synonym,
			upd.task_name,				upd.control_bt_synonym,	upd.parameter_name,			upd.flow_direction,			
			upd.control_i
d,				upd.view_name,			act.primary_control_bts
	from	de_published_up_defaulting_dtl upd (nolock),
			de_published_action act (nolock)
	WHERE	upd.customer_name		=	@customername
	AND		upd.project_name		=	@projectname
	AND		upd.component_name		=	@componentname
	AND		upd.ecrno				=	@ecrno

	AND		upd.customer_name		=	act.customer_name
	AND		upd.project_name		=	act.project_name
	AND		upd.process_name		=	act.process_name
	AND		upd.component_name		=	act.component_name
	AND	
	upd.activity_name		=	act.activity_name
	AND		upd.ui_name				=	act.ui_name
	AND		upd.page_bt_synonym		=	act.page_bt_synonym
	AND		upd.task_name			=	act.task_name
	ORDER BY upd.activity_name, upd.ui_name, upd.page_bt_synonym, upd.section_bt_synonym, upd.ta
sk_name, upd.parameter_name

	open methodcur
	Fetch Next from methodcur into	
					@tmp_actname,		@tmp_uiname,		@tmp_pagename,		@tmp_sectionbt,			@tmp_taskname,	
					@tmp_controlbt,		@tmp_paramname,		@tmp_flowdir,		@tmp_controlid,			@tmp_viewname,			
					@tmp_primarycontrol
			
	WHILE @@FETCH_STATUS = 0   
	BEGIN 		

		select	@tmp_compprefix		=	current_value
		from	es_comp_param_mst (nolock)
		WHERE	customer_name		=	@customername
		AND		project_name		=	@projectname
		AND		process_name		=	@tmp_processname
		AND		component_name		=	@componentname
		AND		param_category		=	'COMPPREFIX'

		SELECT	@tmp_Activityid		= Activityid
		FROM	de_fw_req_activity (nolock)
		WHERE	customer_name		=	@customername
		AND		project_name		=	@projectname
		AND		process_name		=	@tmp_processname
		AND		componentname		=	@componentname
		AND		activityname		=	@tmp_actname
		 
		SELECT	@tmp_pageprefix		= Page_prefix
		FROM	de_ui_page (nolock)
		WHERE	customer_name		=	@customername
		AND		project_name		=	@projectname
		AND		process_name		=	@tmp_processname
		AND		component_name		=	@componentname
		AND		activity_name		=	@tmp_actname
		AND		ui_name				=	@tmp_uiname
		AND		page_bt_synonym		=	@tmp_
pagename

		SELECT	@tmp_controlprefix	=	Control_prefix,
				@tmp_processname	=	process_name,
				@tmp_visiblelength	=	visisble_length
		FROM	de_ui_control (nolock)
		WHERE	customer_name		=	@customername
		AND		project_name		=	@projectname
		AND		process_name		=	@tmp_processname
		AND		component_name		=	@componentname
		AND		activity_name		=	@tmp_actname
		AND		ui_name				=	@tmp_uiname
		AND		page_bt_synonym		=	@tmp_
pagename
		AND		Control_bt_synonym	=	@tmp_primarycontrol


		SET		@tmp_displayflag	=	'T'
		SELECT	@tmp_methodname	= ISNULL(@tmp_compprefix,'') + ISNULL(@tmp_pageprefix,'') + ISNULL(@tmp_controlprefix,'') + 'MtVirMet'
		SELECT	@tmp_methodname	= Lower(@tmp_methodname	)

		set @tmp_spname = ''

		SELECT	@tmp_spname			=	[object_name]
		FROM	de_up_defaulting_hdr (nolock)
		WHERE	customer_name		=	@customername
		AND		project_name		=	@projectname
		AND		process_name		=	@tmp_processname
		AND		component_name		=	@componentname
		AND		activity_name		=	@tmp_actname
		AND		ui_name				=	@tmp_uiname
		AND		page_bt_synonym		=	@tmp_
pagename
		AND		task_name			=	@tmp_taskname
		AND		object_type			=	'SP'

		select	@tmp_datatype		=	data_type
		FROM	de_glossary (nolock)
		WHERE	customer_name		=	@customername
		AND		project_name		=	@projectname
		AND		process_name		=	@tmp_processname
		AND		component_name		=	@componentname
		AND		bt_synonym_name		=	@tmp_controlbt

		
		SELECT	@tmp_spparamtype	=	spparametertype
		FROM	de_fw_des_br_logical_parameter (nolock)
		WHERE	customer_name		=	@customername
		AND		project_name		=	@projectname
		AND		process_name		=	@tmp_processname
		AND		component_name		=	@componentname
		--AND		activity_name		=	@tmp_actname
		--AND		ui_name				=	@tmp_uiname
		--AND		page_bt_synonym		=
	@tmp_pagename
		AND		logicalparametername=	@tmp_paramname

	
		SELECT	@tmp_servicename	=	lower(service_name)
		FROM	de_task_service_map (nolock)
		WHERE	customer_name		=	@customername
		AND		project_name		=	@projectname
		AND		process_name		=	@tmp_processname
		AND		component_name		=	@componentname
		AND		activity_name		=	@tmp_actname
		AND		ui_name				=	@tmp_uiname		
		AND		task_name			=	@tmp_tas
kname
		
			
		SELECT	@tmp_btname			=	bt_name
		FROM	de_glossary (nolock)
		WHERE	customer_name		=	@customername
		AND		project_name		=	@projectname
		AND		process_name		=	@tmp_processname
		AND		component_name		=	@componentname
		AND		BT_Synonym_name		=	@tmp_controlbt

		select  Top 1 @tmp_bocode	=	bocode 
		from	de_fw_des_publish_businessrule (nolock)
		WHERE	customername		=	@customername
		AND		projectname			=	@projectname
		AND		processname			=	@tmp_processname
		AND		componentname		=	@componentname

		IF isnull(@tmp_nexttask,'')  <> isnull(@tmp_taskname,'')
		BEGIN
			select  @tbl_methodid		=	ISNULL(Max(methodid),0) + 1
			from	de_fw_des_publish_businessrule (nolock)
			WHERE	customername		=	@customername
			AND		projectname			=	@projectname
			AND		processname			=	@tmp_processname
			AND		componentname		=	@componentname

			IF isnull(@tmp_methodid,0) = 0 
				select @tmp_methodid = 	@tbl_methodid
			Else
				select @tmp_methodid = @tmp_methodid + 1

			--SELECT	@tmp_Sectionname	=	ISNULL(@tmp_compprefix,'') + 'ps' + ISNULL(@tmp_controlprefix,'') + '_Vir'
			SELECT	@tmp_Sectionname	=	ISNULL(@tmp_compprefix,'') + 'ps' + ISNULL(@tmp_controlprefix,'') + '_UP' 
			SELECT	@tmp_Sectionname	=	Lower(@tmp_Sectionname)
		END

		set @tmp_nexttask = @tmp_taskname

		SELECT		@tmp_Segmentname	 = '_UPHSeg'
		
		--insert into #fw_req_ilbo_view 
		--			(btsynonym,			controlid,			displayflag,			displaylength, 
		--			ilbocode,			viewname,			isItkCtrl,				UpdUser, 
		--			Updtime ) 
		--select		@tmp_controlbt,		@tmp_controlid,		@tmp_displayflag,		@tmp_visiblelength,
		--			@tmp_uiname,		@tmp_viewname,		'n',					host_name(), 
		--			getdate()
		--select 'tt', * from #fw_req_ilbo_view order by updtime desc

		IF NOT EXISTS (SELECT 'X'
		FROM	#fw_des_service_dataitem
		WHERE	servicename		= @tmp_servicename
		and		segmentname		= @contextseg		
		)
		BEGIN
			insert into #fw_des_service_dataitem  
						(dataitemname,		defaultvalue,		flowattribute ,				segmentname,
						servicename,		itk_dataitem,		UpdUser,					UpdTime,
						ispartofkey ,		mandatoryflag ,		controlid	)
			select  'Language',				-915,				0,							@contextseg,
					@tmp_servicename,		'n'	,				 'dbo',						getdate(),
					0,						0,					''
			UNION	
			select  'OUInstance',			-915,				0,							@contextseg,
					@tmp_servicename,		'n'	,				 'dbo',						getdate(),
					0,						0,					''
			UNION
			select  'Service',				'~#~',				0,							@contextseg,
					@tmp_servicename,		'n'	,				 'dbo',						getdate(),
					0,						0,					''
			UNION
			select  'User',					'~#~',				0,							@contextseg,
					@tmp_servicename,		'n'	,				 'dbo',						getdate(),
					0,						0,					''
		END

		
		IF NOT EXISTS ( SELECT 'X'
		FROM	#fw_des_service_segment
		WHERE	servicename		= @tmp_servicename
		and		segmentname		= @tmp_Segmentname
		)
			insert  into #fw_des_service_segment 
					( bocode,			bosegmentname,			instanceflag,			mandatoryflag, 
					parentsegmentname,	segmentname,			SegmentSequence,		servicename ,
					process_selrows,	process_updrows,		process_selupdrows,		flowattribute)
			select  @tmp_bocode,		@tmp_Segmentname,		0,						0, 
					NULL,				LOWER(LTRIM(RTRIM(@tmp_Segmentname))), 1,		LOWER(LTRIM(RTRIM(@tmp_servicename))), 
					'N',				'N',					'N',					2

		IF NOT EXISTS (SELECT 'X'
		FROM	#fw_des_service_dataitem
		WHERE	servicename		= @tmp_servicename
		and		segmentname		= @tmp_Segmentname
		and		dataitemname	= @tmp_paramname
		)
			insert into #fw_des_service_dataitem  
						(dataitemname,		defaultvalue,		flowattribute ,				segmentname,
						servicename,		itk_dataitem,		UpdUser,					UpdTime,
						ispartofkey ,		mandatoryflag ,		controlid	)
			select  LOWER(@tmp_paramname) ,
					case upper(@tmp_datatype)
						when 'CHAR'  then '~#~'
						when 'DATE'  then '01/01/1900'
						when 'DATE-TIME' then '01/01/1900'
						when 'TIME'  then '01/01/1900'
						when 'DATETIME' then '01/01/1900'
						when 'DOUBLE' then '-915'
						when 'INTEGER' then '-915'
						when 'NUMERIC' then '-915'
						when 'ENUMERATED' then ''
						else ''
					end   'defaultvalue',
					CASE	@tmp_flowdir
						when 'IN'		then 0
						when 'OUT'		then 1
						when 'INOUT'	then 2
					END	'flowattribute' ,				
					@tmp_Segmentname , @tmp_servicename, 'N', 'dbo', getdate() ,
					0,			0,		''

		IF NOT EXISTS (SELECT 'X'
		FROM	#fw_des_businessrule
		WHERE	methodname		= @tmp_methodname)

			insert  into #fw_des_businessrule 
							( accessesdatabase,		bocode,				broname,			dispid,   
							isintegbr,				methodid,			methodname,			operationtype, 
							statusflag,				systemgenerated )
			select			1,						@tmp_bocode,		@componentname+'001',  '',   
							0,						@tmp_methodid,		@tmp_methodname,	1, 
							0,						1
	
		select	@tmp_seqno			=	ISNULL(Max(sequenceno),0) + 1
		FROM	de_fw_des_processsection (nolock)
		WHERE	customer_name		=	@customername
		AND		project_name		=	@projectname
		AND		process_name		=	@tmp_processname
		AND		component_name		=	@componentname
		AND		servicename			=	@tmp_servicename

		IF NOT EXISTS (SELECT 'X'
		FROM	#fw_des_processsection
		WHERE	servicename		= @tmp_servicename
		and		sectionname		= @tmp_Sectionname
		)
			insert  into #fw_des_processsection 
						(controlexpression,			processingtype,		sectionname,		sectiontype, 
						sequenceno,					servicename )
			select		NULL,						0,					@tmp_Sectionname,		0, 
						@tmp_seqno,					@tmp_servicename


		IF NOT EXISTS (SELECT 'X'
		FROM	#fw_des_processsection_br_is
		WHERE	servicename		= @tmp_servicename
		and		sectionname		= @tmp_Sectionname	
		)

			insert  into #fw_des_processsection_br_is 
						(connectivityflag,			controlexpression,	executionflag,		integservicename, 
						isbr,						methodid,		    sectionname,		sequenceno, 
						servicename,				Method_Ext,			methodid_ref,		methodname_ref, 
						sequenceno_ref,				sectionname_ref,	ps_sequenceno_ref)
			select		1,							'',					1,					'', 
						1,							@tmp_methodid, 		@tmp_sectionname,	1, 
						@tmp_servicename,			'',					'',					'', 
				'',							'',					''


		IF NOT EXISTS (SELECT 'X'
		FROM	#fw_des_sp
		WHERE	spname		= @tmp_spname	
		)
			insert  into #fw_des_sp 
						( methodid,					sperrorprotocol,	spname )
			select		@tmp_methodid,				0,					@tmp_spname


		IF NOT EXISTS (SELECT 'X'
		FROM	#fw_des_br_logical_parameter
		WHERE	methodid		= @tmp_methodid
		and		logicalparametername		= 'ctxt_OUInstance'		
		)
		BEGIN
			insert  into #fw_des_br_logical_parameter 
							( btname,			flowdirection,				logicalparametername,				logicalparamseqno, 
							methodid, 			recordsetname,				rssequenceno,					spparametertype )
			select			'ctxt_OUInstance',		0,							'ctxt_OUInstance',				1, 
								@tmp_methodid, 		'',							'',									'int'
			UNION
			select			'ctxt_User',		0,							'ctxt_User',				2, 
								@tmp_methodid, 		'',							'',									'char'
			UNION
			select			'ctxt_Language',		0,							'ctxt_Language',				3, 
								@tmp_methodid, 		'',							'',									'int'
			UNION
			select			'ctxt_Service',		0,							'ctxt_Service',				4, 
								@tmp_methodid, 		'',							'',									'char'


			Insert  into #fw_des_di_parameter 
						(dataitemname,				methodid,			parametername,		sectionname, 
						segmentname,				sequenceno,			servicename )
			select		'OUInstance',			@tmp_methodid,		'ctxt_OUInstance',		LOWER(LTRIM(RTRIM(@tmp_Sectionname))),
						@contextseg,			1,					@tmp_servicename
			UNION
			select		'User',			@tmp_methodid,		'ctxt_User',		LOWER(LTRIM(RTRIM(@tmp_Sectionname))),
						@contextseg,			1,					@tmp_servicename
			UNION
			select		'Language',			@tmp_methodid,		'ctxt_Language',		LOWER(LTRIM(RTRIM(@tmp_Sectionname))),
						@contextseg,			1,					@tmp_servicename
			UNION
			select		'Service',			@tmp_methodid,		'ctxt_Service',		LOWER(LTRIM(RTRIM(@tmp_Sectionname))),
						@contextseg,			1,					@tmp_servicename

		END

		SELECT	@tmp_paramseqno		=	ISNULL(Max(logicalparamseqno),0) + 1
		FROM	#fw_des_br_logical_parameter (nolock)
		WHERE	methodid			= @tmp_methodid		

		
		IF NOT EXISTS ( SELECT 'X'
		FROM	#fw_des_br_logical_parameter 
		WHERE	methodid				= @tmp_methodid
		and		logicalparametername	= @tmp_paramname
		)
		begin
	
			insert  into #fw_des_br_logical_parameter 
							( btname,			flowdirection,				logicalparametername,				logicalparamseqno, 
							methodid, 			recordsetname,				rssequenceno,						spparametertype )
			select			@tmp_btname,		
						CASE	@tmp_flowdir
							when 'IN'		then 0
							when 'OUT'		then 1
							when 'INOUT'	then 2
						END	'flowdirection' ,			LOWER(@tmp_paramname),				@tmp_paramseqno, 
							@tmp_methodid, 		'',							'',									@tmp_datatype
		end


		insert into #fw_req_bterm_synonym (btname, btsynonym, UpdUser, Updtime)
		select btname, btsynonym, host_name(), getdate() 
		from de_fw_req_publish_bterm_synonym_vw_fn (@customername, @projectname, @ecrno) 


		IF NOT EXISTS (SELECT 'X'
		FROM	#fw_des_di_parameter
		WHERE	servicename			= @tmp_servicename
		and		parametername		= @tmp_paramname
		and		dataitemname		= @tmp_paramname
		and		methodid			= @tmp_methodid
		)
			insert  into #fw_des_di_parameter 
						(dataitemname,				methodid,			parametername,		sectionname, 
						segmentname,				sequenceno,			servicename )
			select		@tmp_paramname,				@tmp_methodid,		@tmp_paramname,		LOWER(LTRIM(RTRIM(@tmp_Sectionname))),
						@tmp_Segmentname,			1,					@tmp_servicename


		IF NOT EXISTS ( SELECT 'X'
		FROM	#fw_des_ilbo_service_view_datamap 
		WHERE	servicename		= @tmp_servicename
		and		segmentname		= @tmp_Segmentname
		and		dataitemname	= @tmp_paramname
		)
			insert into #fw_des_ilbo_service_view_datamap 
						(activityid,		controlid,			dataitemname,			ilbocode, 
						iscontrol,			segmentname,		servicename,			taskname,
						variablename,		viewname,			page_bt_synonym,		UpdUser, 
						Updtime) 
			select			
						@tmp_Activityid,	@tmp_controlid,		@tmp_paramname,			@tmp_uiname, 
						1,					@tmp_Segmentname,	@tmp_servicename,		@tmp_taskname,
						null,				@tmp_viewname,		@tmp_pagename,			host_name(), 
						getdate() 
	
	Fetch Next from methodcur into	
					@tmp_actname,		@tmp_uiname,		@tmp_pagename,		@tmp_sectionbt,			@tmp_taskname,	
					@tmp_controlbt,		@tmp_paramname,		@tmp_flowdir,		@tmp_controlid,			@tmp_viewname,			
					@tmp_primarycontrol

	END
	CLOSE methodcur
	DEALLOCATE methodcur

SET NOCOUNT OFF

END


