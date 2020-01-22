CREATE PROCEDURE vwnetgen_Api_Tree_Form
@CustomerName		ENGG_NAME,
@ProjectName		ENGG_NAME,
@CompONentName		ENGG_NAME,
@DocNo				ENGG_NAME
AS
BEGIN
	SET NOCOUNT ON

	IF NOT EXISTS (SELECT 1 FROM SYSOBJECTS WHERE ID = OBJECT_ID('fw_des_api_tree_form'))
	BEGIN
		CREATE TABLE [fw_des_api_tree_form] (  
			[CustomerName]			ENGG_NAME			NOT NULL,
			[ProjectName]			ENGG_NAME			NOT NULL,
			[DocNo]					ENGG_NAME			NOT NULL,
			[ComponentName]			ENGG_NAME			NOT NULL,
			[ServiceName]			ENGG_NAME			NOT NULL,
			[SectionName]			ENGG_SEGMENT_NAME	NOT NULL,
			[SequenceNo]			ENGG_TINY_NO		NOT NULL,
			[SpecID]				ENGG_SPEC_ID		NOT NULL,
			[SpecName]				ENGG_SPEC_NAME		NOT NULL,
			[Version]				ENGG_SPEC_VERSION	NOT NULL,
			[Path]					ENGG_PATH			NOT NULL,
			[OperationVerb]			ENGG_FLAG			NOT NULL,
			[MediaType]				ENGG_NAME			NOT NULL,
			[ApiType]				ENGG_NAME			NOT NULL,
			[Level]					ENGG_NAME			NOT NULL,
			[ParentSchemaName]		ENGG_SCHEMA_NAME	NOT NULL,
			[SchemaName]			ENGG_SCHEMA_NAME	NOT NULL,
			[SchemaCategory]		ENGG_FLAG			NULL,
			[SegmentName]			ENGG_NAME			NULL,
			[DataItemName]			ENGG_NAME			NULL,
			[Identifier]			ENGG_TYPE			NULL,
			[Type]					ENGG_SCHEMA_NAME	NULL,
			[SchemaType]			ENGG_SCHEMA_NAME	NULL,
			[IsPrimitiveType]		ENGG_SCHEMA_NAME	NULL,
			[Enum]					ENGG_SCHEMA_NAME	NULL,
			[DisplayName]			ENGG_NVARCHAR_MAX	NULL,
			[NodeID]				ENGG_NVARCHAR_MAX	NULL,
			[ParentNodeID]			ENGG_NVARCHAR_MAX	NULL,
			[ResponseCode]			ENGG_FLAG			NULL
		) ON [PRIMARY]
	END 
		
		DECLARE @tmp_ServiceName	ENGG_NAME,
				@tmp_SectiONName	ENGG_NAME,
				@tmp_SequenceNO		ENGG_NAME,
				@tmp_SpecID			ENGG_NAME,
				@tmp_SpecVersiON	ENGG_NAME,
				@tmp_Path			ENGG_NAME,
				@tmp_OperatiONVerb	ENGG_NAME,
				@tmp_apischemaname	ENGG_NAME,
				@tmp_type			ENGG_NAME,
				@tmp_specName		ENGG_NAME,
				@tmp_mediaType		ENGG_NAME,
				@initialize_count	INT



		SET	@initialize_count	= '1'

		DECLARE @Api_Tree_Form TABLE 
				(	RowNo INT NOT NULL IDENTITY (1,1) PRIMARY KEY CLUSTERED,	
					CustomerName VARCHAR(60),		ProjectName VARCHAR(60),				DocNo  VARCHAR(20),
					ServiceName VARCHAR(60),		SectiONName VARCHAR(60),				SeqNo VARCHAR(10),
					SpecID VARCHAR(5),				SpecVersiON VARCHAR(5),					Path VARCHAR(120),
					OperatiONVerb VARCHAR(120),		MediaType VARCHAR(120),					Type VARCHAR(20),
					SpecName VARCHAR(120)		)

		INSERT INTO @Api_Tree_Form 
						(	CustomerName,			ProjectName,			DocNo,				ServiceName,
							SectiONName,			SeqNo,					SpecID,				SpecVersiON,
							Path,					OperatiONVerb,			MediaType,			Type,
							SpecName	)
				SELECT DISTINCT 
							CustomerName,			ProjectName,			DocNo,				ServiceName,
							SectiONName,			SequenceNo,				SpecID,				VersiON,
							Path,					OperatiONVerb,			MediaType,			'Request',
							SpecName
					FROM	fw_des_publish_api_request_serv_map (NOLOCK)
					WHERE	CustomerName		=	@CustomerName
					AND		ProjectName			=	@ProjectName			
					AND		CompONentName		=	@CompONentName
					AND		DocNo				=	@DocNo
				UNION
				SELECT DISTINCT 
							CustomerName,			ProjectName,			DocNo,				ServiceName,
							SectiONName,			SequenceNo,				SpecID,				VersiON,
							Path,					OperatiONVerb,			MediaType,			'Response',
							SpecName	
					FROM	fw_des_publish_api_respONse_serv_map (NOLOCK)
					WHERE	CustomerName		=	@CustomerName
					AND		ProjectName			=	@ProjectName			
					AND		CompONentName		=	@CompONentName
					AND		DocNo				=	@DocNo

		WHILE @initialize_count <= ISNULL((SELECT COUNT(RowNo) FROM @Api_Tree_Form), 0)
		BEGIN
			
			SELECT	@tmp_ServiceName		=	ServiceName,
					@tmp_SectiONName		=	SectiONName,
					@tmp_SequenceNO			=	SeqNo,
					@tmp_SpecID				=	SpecID,
					@tmp_SpecVersiON		=	SpecVersiON,
					@tmp_Path				=	Path,
					@tmp_OperatiONVerb		=	OperatiONVerb,
					@tmp_type				=	Type,
					@tmp_specName			=	SpecName,
					@tmp_mediaType			=	mediaType
			FROM	@Api_Tree_Form
			WHERE	RowNo					=	@initialize_count

			IF @tmp_type = 'Request'
			BEGIN

				SELECT	@tmp_apischemaname		=	schemaname
				FROM	api_inf_fw_apispec_pathoperatiONrequestmediatype_vw (NOLOCK)
				WHERE	SpecID			=	@tmp_SpecID
				and		VersiON			=	@tmp_SpecVersiON
				and		path			=	@tmp_Path
				and		OperatiONVerb	=	@tmp_OperatiONVerb
			END

			IF @tmp_type = 'Response'
			BEGIN

				SELECT	@tmp_apischemaname		=	schemaname
				FROM	api_inf_fw_apispec_pathoperatiONrespONsemediatype_vw (NOLOCK)
				WHERE	SpecID			=	@tmp_SpecID
				and		VersiON			=	@tmp_SpecVersiON
				and		path			=	@tmp_Path
				and		OperatiONVerb	=	@tmp_OperatiONVerb

			END

			--SELECT @tmp_ServiceName '@tmp_ServiceName', @tmp_SectiONName '@tmp_SectiONName', @tmp_SequenceNO '@tmp_SequenceNO',
			--	@tmp_SpecID '@tmp_SpecID', @tmp_SpecVersiON '@tmp_SpecVersiON', @tmp_Path '@tmp_Path', @tmp_OperatiONVerb '@tmp_OperatiONVerb',
			--	@tmp_apischemaname	'@tmp_apischemaname',@tmp_type '@tmp_type'


	;WITH cte_pop_obj_1 (	CustomerName,		ProjectName,	CompONentName,		DocNO,		
							LEVEL, specid, parentschemaname, SchemaName, Identifier, Type, SchemaType, IsPrimitiveType, Enum,pnodeid,nodeid,DisplayText)
	AS
	(
		SELECT	@CustomerName,		@ProjectName,		@CompONentName,		@DocNo,
				1, a.specid,a.parentschemaname,a.SchemaName,a.Identifier,a.Type,a.SchemaType,a.IsPrimitiveType,a.Enum,
				REPLACE(CAST(a.parentschemaname AS VARCHAR(MAX)),'-','p') + '__' + CAST(a.SchemaName AS VARCHAR(MAX)),
				REPLACE(CAST(a.parentschemaname AS VARCHAR(MAX)),'-','p') + '__' + CAST(a.SchemaName AS VARCHAR(MAX)),
				CAST (schemaname AS VARCHAR(MAX) )
		FROM api_inf_fw_apispec_schema_vw a(nolock)
		WHERE	a.SchemaName		=	@tmp_apischemaname
		AND		a.specid			=	@tmp_specid
		AND		a.ParentSchemaName	=	'-'
		UNION ALL
		SELECT @CustomerName,		@ProjectName,		@CompONentName,		@DocNo,
				level+1,a.specid,a.parentschemaname,a.SchemaName,a.Identifier,a.Type,a.SchemaType,a.IsPrimitiveType,a.Enum,
				b.nodeid,
				REPLACE(CAST(a.parentschemaname AS VARCHAR(MAX)),'-','p') + '__' + CAST(a.SchemaName AS VARCHAR(MAX)),
				CASE	WHEN a.type  = 'array' THEN	b.DisplayText + '.' + a.schemaname	+ '{}' 
						WHEN a.type  = 'object' THEN	b.DisplayText + '.' + a.schemaname	ELSE b.DisplayText + '.' + a.schemaname END
		FROM	api_inf_fw_apispec_schema_vw a(nolock)  inner join 
				cte_pop_obj_1 b 
				ON	a.ParentSchemaName		=	 b.Schemaname	
				AND	a.specid				=		b.specid
				
				AND	a.ParentSchemaName		=	@tmp_apischemaname		)

	SELECT * into cte_pop_obj_1_1 FROM cte_pop_obj_1

	;WITH cte_pop_obj_2 (	CustomerName,		ProjectName,	CompONentName,		DocNO,	
							LEVEL, specid, parentschemaname, SchemaName, Identifier, Type, SchemaType, IsPrimitiveType, Enum,pnodeid,nodeid,DisplayText)
	AS
	(
		SELECT @CustomerName,		@ProjectName,		@CompONentName,		@DocNo,
				b.level+1,a.specid,a.parentschemaname,a.SchemaName,a.Identifier,a.Type,a.SchemaType,a.IsPrimitiveType,a.Enum,
				b.nodeid,
				REPLACE(CAST(a.parentschemaname AS VARCHAR(MAX)),'-','p') + '__' + CAST(a.SchemaName AS VARCHAR(MAX)),
				CASE	WHEN a.type  = 'array' THEN	b.DisplayText + '.' + a.schemaname	+ '{}' 
						WHEN a.type  = 'object' THEN	b.DisplayText + '.' + a.schemaname	ELSE b.DisplayText + '.' + a.schemaname END
		FROM api_inf_fw_apispec_schema_vw a(nolock)  inner join 
				cte_pop_obj_1_1 b 
				ON	a.SchemaName		=	b.SchemaType	
				AND	a.specid			=	b.specid	
				and	a.type					in ('integer','string','number','date')	)

	SELECT * into cte_pop_obj_2_2 FROM cte_pop_obj_2

	;WITH cte_pop_obj_3 (	CustomerName,		ProjectName,	CompONentName,		DocNO,	
							LEVEL, specid, parentschemaname, SchemaName, Identifier, Type, SchemaType, IsPrimitiveType, Enum,pnodeid,nodeid,DisplayText)
	AS
	(
		SELECT @CustomerName,		@ProjectName,		@CompONentName,		@DocNo,
				b.level+1,	a.specid,a.parentschemaname,a.SchemaName,a.Identifier,a.Type,a.SchemaType,a.IsPrimitiveType,a.Enum,
				b.nodeid,
				REPLACE(CAST(a.parentschemaname AS VARCHAR(MAX)),'-','p') + '__' + CAST(a.SchemaName AS VARCHAR(MAX)),
				CASE WHEN a.type  = 'array' THEN	b.DisplayText + '.' + a.schemaname	+ '{}' 
					WHEN a.type  = 'object' THEN	b.DisplayText + '.' + a.schemaname	ELSE b.DisplayText + '.' + a.schemaname END
		FROM api_inf_fw_apispec_schema_vw a(nolock)  inner join 
				cte_pop_obj_1_1 b 
				ON	a.ParentSchemaName		=	b.SchemaType		
				AND	a.specid				=	b.specid
		UNION ALL
		SELECT @CustomerName,		@ProjectName,		@CompONentName,		@DocNo,
				b.level+1,	a.specid,a.parentschemaname,a.SchemaName,a.Identifier,a.Type,a.SchemaType,a.IsPrimitiveType,a.Enum,
				b.nodeid,
				REPLACE(CAST(a.parentschemaname AS VARCHAR(MAX)),'-','p') + '__' + CAST(a.SchemaName AS VARCHAR(MAX)),
				CASE WHEN a.type  = 'array' THEN	b.DisplayText + '.' + a.schemaname	+ '{}' 
					WHEN a.type  = 'object' THEN	b.DisplayText + '.' + a.schemaname	ELSE b.DisplayText + '.' + a.schemaname END
		FROM api_inf_fw_apispec_schema_vw a(nolock)  inner join 
				cte_pop_obj_3 b 
				ON	a.ParentSchemaName		=	b.SchemaType		
				AND	a.specid				=	b.specid
			)


	SELECT * INTO cte_pop_obj_3_3 FROM cte_pop_obj_3

		INSERT INTO fw_des_api_tree_form 
						(	CustomerName,				ProjectName,				DocNo,					CompONentName,
							ServiceName,				SectiONName,				SequenceNo,				Level,
							SpecID,						SpecName,					VersiON,				Path,
							OperatiONVerb,				MediaType,					ApiType,				ParentSchemaName,		
							SchemaName,					SegmentName,				DataItemName,
							Identifier,					Type,						IsPrimitiveType,		enum,
							NodeID,						ParentNodeID,				DisplayName,			SchemaType	)
					SELECT	
							CustomerName,				ProjectName,				DocNO,					CompONentName,
							@tmp_ServiceName,			@tmp_SectiONName,			@tmp_SequenceNO,		Level,
							@tmp_SpecID,				@tmp_SpecName,				@tmp_SpecVersiON,		@tmp_Path,
							@tmp_OperatiONVerb,			@tmp_mediaType,				@tmp_type,				ParentSchemaName,
							schemaname,					'',							'',
							identifier,					type,						IsPrimitiveType,		Enum,
							NodeID,						pnodeid,					DisplayText,			SchemaType	
					FROM	cte_pop_obj_1_1 (NOLOCK)	
					UNION
					SELECT	
							CustomerName,				ProjectName,				DocNO,					CompONentName,
							@tmp_ServiceName,			@tmp_SectiONName,			@tmp_SequenceNO,		Level,
							@tmp_SpecID,				@tmp_SpecName,				@tmp_SpecVersiON,		@tmp_Path,
							@tmp_OperatiONVerb,			@tmp_mediaType,				@tmp_type,				ParentSchemaName,
							schemaname,					'',							'',
							identifier,					type,						IsPrimitiveType,		Enum,
							NodeID,						pnodeid,					DisplayText,			SchemaType	
					FROM	cte_pop_obj_2_2 (NOLOCK)	
					UNION
					SELECT	
							CustomerName,				ProjectName,				DocNO,					CompONentName,
							@tmp_ServiceName,			@tmp_SectiONName,			@tmp_SequenceNO,		Level,
							@tmp_SpecID,				@tmp_SpecName,				@tmp_SpecVersiON,		@tmp_Path,
							@tmp_OperatiONVerb,			@tmp_mediaType,				@tmp_type,				ParentSchemaName,
							schemaname,					'',							'',
							identifier,					type,						IsPrimitiveType,		Enum,
							NodeID,						pnodeid,					DisplayText,			SchemaType	
					FROM	cte_pop_obj_3_3 (NOLOCK)						


	--SELECT * FROM fw_des_api_tree_form (nolock)	order by level

	UPDATE	fw_des_api_tree_form	
	SET		NodeID		=	CAST (level AS varchar(10)) +	'_' + nodeid
	WHERE	SpecID			=	@tmp_SpecID
	AND		VersiON			=	@tmp_SpecVersiON
	AND		path			=	@tmp_Path
	AND		OperatiONVerb	=	@tmp_OperatiONVerb
	AND		Type IN ('integer', 'string', 'number','date')


	UPDATE	fw_des_api_tree_form	
	SET		ParentNodeID		=	'Root'
	WHERE	SpecID				=	@tmp_SpecID
	AND		VersiON				=	@tmp_SpecVersiON
	AND		path				=	@tmp_Path
	AND		OperatiONVerb		=	@tmp_OperatiONVerb
	AND		Level				=	'1'


	UPDATE	a
	SET		a.segmentname		=	b.SegmentName,
			a.dataitemname		=	b.DataItemName
	FROM	fw_des_api_tree_form a(NOLOCK),
			fw_des_publish_api_request_serv_map b (NOLOCK)
	WHERE	a.CustomerName			=	@CustomerName
	AND		a.projectName			=	@projectname
	AND		a.componentName			=	@ComponentName
	AND		a.docNo					=	@docno

	AND		a.SpecID				=	@tmp_SpecID
	AND		a.VersiON				=	@tmp_SpecVersiON
	AND		a.path					=	@tmp_Path
	AND		a.OperatiONVerb			=	@tmp_OperatiONVerb

	AND		a.customername			=	b.CustomerName
	AND		a.projectName			=	b.ProjectName
	AND		a.componentName			=	b.ComponentName
	AND		a.docNo					=	b.DocNo
	AND		a.ServiceName			=	b.ServiceName
	AND		a.sectionName			=	b.SectionName
	AND		a.SequenceNo			=	b.SequenceNo
	AND		a.specID				=	b.SpecID
	AND		a.specName				=	b.SpecName
	AND		a.Version				=	b.Version
	AND		a.path					=	b.Path
	AND		a.operationverb			=	b.OperationVerb
	AND		a.mediaType				=	b.MediaType
	AND		a.schemaname			=	b.SchemaName
	AND		a.parentschemaname		=	b.ParentSchemaName
	AND		a.apitype				=	'request'

	UPDATE	a
	SET		a.segmentname		=	b.SegmentName,
			a.dataitemname		=	b.DataItemName,
			a.ResponseCode		=	b.ResponseCode
	FROM	fw_des_api_tree_form a(NOLOCK),
			fw_des_publish_api_response_serv_map b (NOLOCK)
	WHERE	a.CustomerName			=	@CustomerName
	AND		a.projectName			=	@projectname
	AND		a.componentName			=	@ComponentName
	AND		a.docNo					=	@docno

	AND		a.SpecID				=	@tmp_SpecID
	AND		a.VersiON				=	@tmp_SpecVersiON
	AND		a.path					=	@tmp_Path
	AND		a.OperatiONVerb			=	@tmp_OperatiONVerb

	AND		a.customername			=	b.CustomerName
	AND		a.projectName			=	b.ProjectName
	AND		a.componentName			=	b.ComponentName
	AND		a.docNo					=	b.DocNo
	AND		a.ServiceName			=	b.ServiceName
	AND		a.sectionName			=	b.SectionName
	AND		a.SequenceNo			=	b.SequenceNo
	AND		a.specID				=	b.SpecID
	AND		a.specName				=	b.SpecName
	AND		a.Version				=	b.Version
	AND		a.path					=	b.Path
	AND		a.operationverb			=	b.OperationVerb
	AND		a.mediaType				=	b.MediaType
	AND		a.schemaname			=	b.SchemaName
	AND		a.parentschemaname		=	b.ParentSchemaName
	AND		a.apitype				=	'response'


	drop table cte_pop_obj_1_1

	drop table cte_pop_obj_2_2

	drop table cte_pop_obj_3_3


		SET @initialize_count = @initialize_count + 1

	END

	INSERT INTO #fw_des_publish_api_request_serv_map 
							(	ServiceName,			SectionName,			SequenceNo,			SpecID,			SpecName,
								Version,				Path,					OperationVerb,		MediaType,		ParentSchemaName,
								SchemaName,				SchemaCategory,			SegmentName,		DataItemName,	NodeID,	
								ParentNodeID,			Identifier,				Type,				DisplayName,	SchemaType		)
					SELECT		
								ServiceName,			SectionName,			SequenceNo,			SpecID,			SpecName,
								Version,				Path,					OperationVerb,		MediaType,		ParentSchemaName,
								SchemaName,				SchemaCategory,			SegmentName,		DataItemName,	NodeID,	
								ParentNodeID,			Identifier,				Type,				DisplayName,	SchemaType	
						FROM	fw_des_api_tree_form (NOLOCK)
						WHERE	apitype				=	'request'
						ORDER BY ServiceName,SectionName,SequenceNo,SpecID,Version,Path,OperationVerb,MediaType,level

	INSERT INTO #fw_des_publish_api_response_serv_map 
							(	ServiceName,				SectionName,			SequenceNo,			SpecID,			SpecName, 
								Version,					Path,					OperationVerb,		MediaType,		ResponseCode, 
								ParentSchemaName,			SchemaName,				SchemaCategory,		SegmentName,	DataItemName, 
								NodeID,						ParentNodeID,			Identifier,			Type,			DisplayName,
								SchemaType		)
						SELECT	
								ServiceName,				SectionName,			SequenceNo,			SpecID,			SpecName, 
								Version,					Path,					OperationVerb,		MediaType,		ResponseCode, 
								ParentSchemaName,			SchemaName,				SchemaCategory,		SegmentName,	DataItemName, 
								NodeID,						ParentNodeID,			Identifier,			Type,			DisplayName,
								SchemaType	
						FROM	fw_des_api_tree_form (NOLOCK)
						WHERE	apitype				=	'response'
						ORDER BY ServiceName,SectionName,SequenceNo,SpecID,Version,Path,OperationVerb,MediaType,level	

	INSERT INTO #fw_des_publish_api_pathparameter_serv_map 
							(	ServiceName,		SectionName,			SequenceNo,			SpecID,			SpecName, 
								Version,			Path,					ParameterName,		SegmentName,	DataItemName,
								[In])	
						SELECT	a.ServiceName,		a.SectionName,			a.SequenceNo,		a.SpecID,		a.SpecName, 
								a.Version,			a.Path,					a.ParameterName,	a.SegmentName,	a.DataItemName,
								b.[In]
						FROM	fw_des_publish_api_pathparameter_serv_map_vw_fn (@customername,@projectname,@docno) a,
								api_inf_fw_apispec_pathparameter_vw b
						where	a.specid		=	b.specid
						and		a.Version		=	b.Version
						and		a.path			=	b.path
						and		a.ParameterName	=	b.ParameterName								
						ORDER BY a.componentname, a.servicename, a.SectionName, a.SequenceNo

		INSERT INTO #fw_des_publish_api_pathoperationparameter_serv_map 
							(	ServiceName,		SectionName,			SequenceNo,			SpecID,			SpecName, 
								Version,			Path,					ParameterName,		SegmentName,	DataItemName,
								OperationVerb,		[In]	)
						SELECT	a.ServiceName,		a.SectionName,			a.SequenceNo,		a.SpecID,		a.SpecName, 
								a.Version,			a.Path,					a.ParameterName,	a.SegmentName,	a.DataItemName,
								a.OperationVerb,	b.[In]
						FROM	fw_des_publish_api_pathoperationparameter_serv_map_vw_fn (@customername,@projectname,@docno) a,
								api_inf_fw_apispec_pathoperationparameter_vw b
						where	a.specid		=	b.specid
						and		a.Version		=	b.Version
						and		a.path			=	b.path
						and		a.OperationVerb	=	b.OperationVerb
						and		a.ParameterName	=	b.ParameterName
						ORDER BY a.componentname, a.servicename, a.SectionName, a.SequenceNo
	DELETE FROM fw_des_api_tree_form

	SET NOCOUNT OFF
END





