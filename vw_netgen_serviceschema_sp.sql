CREATE PROCEDURE vw_netgen_serviceschema_sp
@Guid	engg_name,
@EcrNo	engg_name
AS
BEGIN

		

		--update method's loopcausingsegment
		update a
		set  a.loopcausingsegment = d.segmentname 
		from #fw_des_processsection_br_is a(nolock),
			 #fw_des_di_parameter         b(nolock),
			 #fw_des_br_logical_parameter c(nolock),
			 #fw_des_service_segment      d(nolock)
		where a.servicename		= b.servicename
		and   a.methodid		= b.methodid
		and   b.methodid		= c.methodid
		and   b.parametername	= c.logicalparametername
		and   b.servicename		= d.servicename
		and   b.segmentname     = d.segmentname
		and   isnull(a.methodid,'') <> ''
		and   c.FlowDirection   in ('0','2')
		and   d.InstanceFlag    in ('1')


		update a
		set  a.loopcausingsegment = d.segmentname 
		from #fw_des_processsection_br_is a(nolock),
			 #fw_des_integ_serv_map       b(nolock),
			 #fw_des_service_dataitem     c(nolock),
			 #fw_des_service_segment      d(nolock)
		where a.servicename				= b.callingservicename
		and   a.integservicename		= b.integservicename
		and   b.integservicename		= c.servicename
		and   b.integsegment			= c.segmentname
		and   b.integdataitem			= c.dataitemname
		and   b.callingservicename		= d.servicename
		and   b.callingsegment			= d.segmentname
		and   isnull(a.methodid,'')		= ''
		and   c.flowattribute			in ('0','2')
		and   d.instanceflag			in ('1')

		----service list
		--SELECT	distinct 
		--	a.servicename									as name,				
		--	ISNULL(cast(a.servicetype as varchar),'')		as type,
		--	ISNULL(cast(a.isintegser as varchar),'')		as isintegser,
		--	ISNULL(a.iszipped,0)							as iszipped ,
		--	ISNULL(a.iscached,0)							as iscached,
		--	a.componentname								    as componentname,
		--	b.IsSelected									as isselected				
		--from	#fw_des_service a(nolock)
		--join	engg_gen_deliverables_service b(nolock)
		--on		a.servicename 		=	b.servicename  
		--where	Guid				=	@Guid
		--and		EcrNo				=   @EcrNo
		--Order By name
		
		--service list
		SELECT	distinct 
			a.servicename									as name,				
			ISNULL(cast(a.servicetype as varchar),'')		as type,
			ISNULL(cast(a.isintegser as varchar),'')		as isintegser,
			ISNULL(a.iszipped,0)							as iszipped ,
			ISNULL(a.iscached,0)							as iscached,
			a.componentname								    as componentname,
			'1'									as isselected				
		from	#fw_des_service a(nolock)
		--join	engg_gen_deliverables_service b(nolock)
		--on		a.servicename 		=	b.servicename  
		--where	Guid				=	@Guid
		--and		EcrNo				=   @EcrNo
		Order By name
		
		--service segment
		SELECT	distinct 
			segmentname											  as name,
			ISNULL(cast(segmentsequence as varchar),'')			  as sequence,
			ISNULL(cast(instanceflag as varchar),'')			  as instanceflag,
			ISNULL(cast(mandatoryflag as varchar),'')			  as mandatoryflag,
			servicename											  as servicename,
			process_selrows 									  as process_selrows,
			process_updrows 									  as process_updrows,
			process_selupdrows									  as process_selupdrows,
			flowattribute										  as flowattribute
		FROM	#fw_des_service_segment(Nolock) 
		Order By servicename, sequence,name 
		
		--DataItem		
        SELECT	Distinct 
			di.dataitemname								    as name,
			ISNULL(bt.datatype,'')							as type,
			ISNULL(cast(bt.length as varchar),'')			as datalength,
			ISNULL(cast(di.ispartofkey as varchar),'')		as ispartofkey, 
			ISNULL(cast(di.flowattribute as varchar),'')	as flowattribute,
			ISNULL(cast(di.mandatoryflag as varchar),'')	as mandatoryflag,
			ISNULL(cast(di.defaultvalue as varchar),'')		as defaultvalue,
			di.servicename								    as servicename,
			di.segmentname								    as segmentname
        FROM    #fw_des_service_dataitem di (Nolock),
				#fw_req_bterm			 bt (Nolock),
				#fw_req_bterm_synonym    sy (Nolock)
        Where	sy.BTSynonym    = di.DataItemName
        and		sy.btname       = bt.btname
        order by servicename, segmentname, name
        
        --OUT DataItems(Build out segment)
        SELECT  Distinct 
			di.dataitemname								    as name,
			ISNULL(bt.datatype,'')							as type, 
			ISNULL(cast(bt.length as varchar),'')			as datalength,
			ISNULL(cast(di.ispartofkey as varchar),'')		as ispartofkey, 
			ISNULL(cast(di.flowattribute as varchar),'')	as flowattribute,
			ISNULL(cast(di.mandatoryflag as varchar),'')	as mandatoryflag,
			ISNULL(cast(di.defaultvalue as varchar),'')		as defaultvalue,
			di.servicename									as servicename, 
			di.segmentname									as segmentname
		FROM    #fw_des_service_dataitem di (Nolock),
				#fw_req_bterm			 bt (Nolock),
				#fw_req_bterm_synonym	 sy (Nolock)
		Where   sy.btsynonym	 = di.dataitemname
		and     sy.btname        = bt.btname
		and     di.flowattribute in (1,2)
		and exists (   Select '*'
					   From		#fw_des_di_parameter		 dp (Nolock),
								#fw_des_br_logical_parameter br(Nolock)
                       Where   di.servicename		   = dp.servicename
                       and     di.segmentname          = dp.segmentname
                       and     di.dataitemname         = dp.dataitemname
                       and	   br.methodid			   = dp.methodid
                       and	   br.logicalparametername = dp.parametername
                       and	   br.flowdirection        in (1,2)
					   union
					   Select  '*'
                       From    #fw_des_integ_serv_map imap (nolock)
                       where   di.servicename          = imap.callingservicename
                       and     di.segmentname          = imap.callingsegment
                       and     di.dataitemname         = imap.callingdataitem)
       order by servicename, segmentname, name
       
		--Process Section
		SELECT	distinct 
				sectionname								    as name,
				ISNULL(cast(sectiontype  as varchar),'')	as type,
				ISNULL(cast(sequenceno as varchar),'')		as seqno,
				ISNULL(controlexpression,'')				as controlexpression,
				ISNULL(cast(processingtype as varchar),'')	as loopingstyle,
				servicename								    as servicename
		FROM	#fw_des_processsection(Nolock)
				
		
		--Process Section BR Details 		
		SELECT	distinct 
				ISNULL(cast(br.methodid as varchar),'0')			  as id,
				ISNULL(br.methodname,'')							  as name,	
				ISNULL(cast(ps.sequenceno as varchar),'')			  as seqno,
				ISNULL(cast(ps.isbr as varchar),'')					  as ismethod,
				ISNULL(sp.spname,'')							      as spname,							
				ps.servicename										  as servicename,
				ISNULL(ps.integservicename,'')						  as integservicename,
				ISNULL(ps.controlexpression,'')						  as controlexpression,
				ps.sectionname										  as sectionname,
				ISNULL(cast(br.accessesdatabase as varchar),'')		  as accessesdatabase,
				ISNULL(cast(br.operationtype as varchar),'')		  as operationtype,--not used
				ISNULL(cast(br.systemgenerated as varchar),'')		  as systemgenerated,
				ISNULL(cast(sp.sperrorprotocol as varchar),'')		  as sperrorprotocol,
				ISNULL(ps.loopcausingsegment,'')					  as loopcausingsegment,
				ISNULL(br.method_exec_cont,'')						  as method_exec_cont --TECH-XXXX
		FROM	#fw_des_processsection_br_is ps(Nolock)
		LEFT JOIN				
				#fw_des_businessrule br(Nolock)
		ON		ps.methodid		=	br.methodid 						
		LEFT JOIN
				#fw_des_sp sp(Nolock)
		ON		br.methodid		=	sp.methodid 
		order by servicename, seqno
		
		--Integration service
		SELECT	distinct
				ISNULL(integ.integsegment ,'')					as issegname,		
				ISNULL(integ.integdataitem ,'')					as isdiname,
				ISNULL(Integ.CallingSegment,'')					as callersegname,
				ISNULL(Integ.CallingDataItem ,'')				as callerdiname ,
				ISNULL(Integ.IntegServiceName ,'')				as integservicename,
				ISNULL(cast(ISdi.FlowAttribute as varchar),'0') as flowattribute,
				ISNULL(cast(ISdi.DefaultValue as varchar),'')	as defaultvalue,
				ISNULL(cast(Isdi.IsPartOfKey as varchar),'')	as ispartofkey,
				ISNULL(Integ.CallingServiceName ,'')			as callingservicename,
				ISNULL(ISdi.ServiceName,'')						as servicename,
				ISNULL(Iser.ComponentName,'')					as icomponentname,
				ISNULL(Integ.SectionName,'')					as sectionname,-----------not used
				ISNULL(cast(Integ.SequenceNo as varchar),'')	as seqno,
				ISNULL(cast(Cseg.InstanceFlag as varchar),'0')	as callsegmentinst,
				ISNULL(cast(CSdi.FlowAttribute as varchar),'0') as calldiflow,
				ISNULL(cast(Iseg.InstanceFlag as varchar),'0')	as issegmentinst,
				ISNULL(cast(Iser.ProcessingType as varchar),'') as iser_pr_type,--------not used
				ISNULL(cast(Iser.ServiceType as varchar),'')	as is_servicetype,
				ISNULL(cast(Iser.IsIntegSer as varchar),'')		as is_isintegser--not used

				FROM	    #fw_des_integ_serv_map Integ(Nolock)
				left join   #fw_des_service_segment Iseg(Nolock)
				on		Integ.IntegServiceName		= Iseg.ServiceName	  
				AND		Integ.IntegSegment			= Iseg.SegmentName	

				left join	#fw_des_service_dataitem ISdi(Nolock)
				on      Integ.IntegServiceName		=	ISdi.ServiceName
				AND		Integ.IntegSegment 			=	ISdi.SegmentName	
				AND		Integ.IntegDataItem  		=	ISdi.DataItemName
				left join	#fw_des_service Iser(Nolock)
				on      Integ.IntegServiceName      =   Iser.ServiceName
				left join	#fw_des_service_segment Cseg(Nolock)
				on		Integ.CallingServiceName	=	Cseg.ServiceName  
				AND		Integ.CallingSegment		=	Cseg.SegmentName
				left join	#fw_des_service_dataitem CSdi(Nolock)
				on      Integ.CallingServiceName	=	CSdi.ServiceName
				AND		Integ.CallingSegment 		=	CSdi.SegmentName
				AND		Integ.CallingDataItem  		=	CSdi.DataItemName
				left join	#fw_des_service Cser(Nolock)
				on		Integ.CallingServiceName	=	Cser.ServiceName
				

		--order by CallerSegName, CallerDIName, ISSegName, ISDIName 
        
        --Physical parameters        
		Select	distinct  
				LParam.LogicalParameterName									as physicalparametername,
				ISNULL(LParam.RecordSetName,'')								as recordsetname,
				cast(LParam.LogicalParamSeqNo as varchar)					as seqno,
				cast(LParam.FlowDirection as varchar)						as flowdirection,
				diparam.SegmentName											as datasegmentname,
				diparam.DataItemName										as dataitemname,
				cast(LParam.MethodID as varchar)							as methodid,
				cast(diparam.SequenceNo as varchar)							as sequenceno,
				diparam.ServiceName											as servicename,
				diparam.SectionName											as sectionname,
				ISNULL(bterm.DataType,'')									as brparamtype,
				ISNULL(cast(bterm.length as varchar),'')					as length,
				ISNULL(LParam.SPParameterType,'')							as paramtype, 
				ISNULL(cast(prec.DecimalLength as varchar),'')				as decimallength
		FROM    #fw_des_di_parameter		 diparam(Nolock),
				#fw_des_br_logical_parameter lParam (Nolock),
				#fw_req_bterm				 bterm  (Nolock)
		LEFT 
		OUTER 
		JOIN	#fw_req_precision prec(nolock) 
		ON		bterm.precisiontype   = prec.precisiontype
		WHERE	LParam.Methodid		  = diparam.Methodid 
		AND		diparam.ParameterName = lParam.LogicalParameterName   
		AND		bterm.BTName          = lparam.BTName
		ORDER BY servicename, DataSegmentName, seqno
		

	    --DI Property Mappings
       select DISTINCT servicename, segmentname, dataitemname
	   from #fw_des_publish_ilbo_service_view_attributemap (nolock)
	   
	   
	   --Unused dataitems (Fillunmapped Dataitems)
		SELECT	di.servicename as servicename,di.segmentname as segmentname, 
				cast(Seg.InstanceFlag as varchar) as instanceflag,di.Dataitemname as dataitemname,
				cast(di.DefaultValue as varchar) defaultvalue
		FROM   	#fw_des_service_dataitem di (nolock),
				#fw_des_service_segment Seg (nolock)
		WHERE  	di.servicename 		= 	Seg.servicename
		AND    	di.segmentname 		= 	Seg.segmentname
		AND    	di.flowAttribute 	in 	('0','2')
		AND    	di.MandatoryFlag 	= 	'0'
		AND  NOT EXISTS(SELECT  'x'
						FROM   	#fw_des_ilbo_service_view_datamap sv (nolock)
						WHERE  	sv.ServiceName	= 	di.servicename
						AND    	sv.SegmentName 	= 	di.SegmentName
						AND     sv.DataItemName =   di.DataitemName
						)
		AND		di.DataitemName NOT IN ('ModeFlag')
		ORDER BY di.servicename,Seg.InstanceFlag, di.segmentname	
END





