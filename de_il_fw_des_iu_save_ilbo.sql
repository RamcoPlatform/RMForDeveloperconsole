/********************************************************************************/
/*	Modified By : Gankan G														*/
/*	Call ID		: PLF2.0_04333													*/
/*	Date		: 19-Apr-2013													*/
/*	Description : Script modified to handle service re-use within ilbo's		*/
/********************************************************************************/
/*	Modified By : Kiruthika R													*/
/*	Date		: 20-oct-2016													*/
/*	Description : Modeflag is not getting generated during codegen      		*/
/********************************************************************************/
/* Modified by : Jeya Latha K/Ganesh Prabhu S	for callid TECH-7349				*/
/* Modified on : 14-03-2017				 											*/
/* Description :  New Base Control types RSAssorted, RSPivotGrid, RSTreeGrid and New Feature Organization chart */
/* Modified By : Jeya Latha K		Date: 08-Jan-2019			Defect ID: TECH-28436 */
/***********************************************************************************/
alter proc de_il_fw_des_iu_save_ilbo (	@ILBOCode	as engg_name,
					@PublishFlag	as engg_seqno,
					@TranID		as engg_desc,
					@M_ErrorID	int	output,
					@ResultFlag	as engg_seqno = 1
				)

AS
BEGIN
SET NOCOUNT ON
	--added by deepa
	DECLARE @comname engg_name

	select	@comname = componentname
	from	#fw_req_activity ACT,#fw_req_activity_ilbo ACTILBO
	where	ACTILBO.ilbocode = @ilbocode AND 
		ACTILBO.activityid = ACT.activityid


	DECLARE	@ServiceName as engg_name
	DECLARE @SegmentName as engg_name
	DECLARE @ControlID as engg_name
	DECLARE @ModeFlagView as engg_name
	DECLARE @ViewName as engg_name
	DECLARE @BTSynonym as engg_name
	DECLARE	@TaskName as engg_name
	DECLARE @ActivityID as engg_seqno
	DECLARE @ILBOtype as engg_seqno
	DECLARE @dataitem as engg_name
	SELECT @ILBOtype = ILBOType FROM #fw_req_ilbo
	WHERE ILBOCode = @ILBOCode
 
	IF	@PublishFlag='1' 
	BEGIN
	--Process for publishing the ILBO

		/*Added For Bug SoftRB2cut1.0S_000379 */
		/*To Check if a Subscribed ILBO has a published mandatory data item mapped */
		IF ((SELECT COUNT(*) FROM  #fw_req_ilbo_linkUse where ParentILBOCode=@ILBOCode )>=1)
		BEGIN
			IF EXISTS(SELECT 1
			FROM #fw_req_ilbo_linkUse sublink,
			     #fw_req_ilbo_data_publish pubdata	
			WHERE   sublink.ParentILBOCode = @ILBOCode AND
				pubdata.ILBOCode = sublink.ChildILBOCode  AND
				pubdata.linkid = sublink.linkid AND
				pubdata.MandatoryFlag=1 AND 
				pubdata.DataItemName NOT IN 
					( SELECT subdata.DataItemName
					  FROM   #fw_req_ilbo_data_use subdata
					  WHERE  subdata.ParentILBOCode = @ILBOCode AND
	                			pubdata.ILBOCode = subdata.ChildIlboCode AND
					        pubdata.MandatoryFlag=1 AND
	         				subdata.DataItemName = pubdata.dataitemname AND
					        subdata.taskname= sublink.TaskName
					)
				)
			BEGIN
				SELECT @M_ErrorID = 2986
				RETURN 
			END
	
		END
	
		/*End of SoftRB2cut1.0S_000379*/
	
		/*	Removed as ASPGen does not use these 	
		--CheckAllGUITasksHaveEvents
		--are there any UI type tasks without marshal events ??
		IF EXISTS(	select 	T.TaskName
				From 	#fw_req_ACTIVITY_ILBO		AI,
					#fw_req_activity_ilbo_task  	IT,
					#fw_req_task			T
				where	AI.ILBOCode 	= 	@ILBOCode	AND
					AI.ActivityId	= 	IT.ActivityId	AND
					IT.TaskName	=	T.TaskName	AND
					T.TaskType	=	'UI'		AND
					IT.taskname 	not in (select 	CE.taskname 
								from 	#fw_des_ilbo_ctrl_event CE 
								where 	CE.ilbocode = IT.ilbocode 
								)
			)
		BEGIN
			--One or more GUI type tasks for the ILBO
			--do not have an associated control event
			SELECT @M_ERRORID=1222
			RETURN 
		END
		*/
	
		/*	Removed as ASPGen does not use these 
		--CheckAllServiceTasksHaveGroups
		IF EXISTS (
		select 	T.TaskName
		from 	#fw_req_ACTIVITY_ILBO		AI,
			#fw_req_activity_ilbo_task  	IT,
			#fw_req_task			T
		where	AI.ilbocode	=	@ILBOCode	AND
			AI.ActivityId	= 	IT.ActivityId	AND
			IT.TaskName	=	T.TaskName	AND
			T.TaskType	in 	('Fetch', 'Submit', 'Trans')	AND
			T.TaskName NOT IN(	select 	AGT.TASKNAME
						from 	#fw_des_ilbo_actions	A,
							#fw_des_ilbo_actiongrp_task	AGT
						WHERE 	A.ilbocode	= AI.ilbocode	AND
							ISNULL (A.ServiceName, '') != ''AND
							AGT.GroupCode	= A.GroupCode 	AND
							agt.ilbocode	= A.ilbocode 	
					)
		)
		BEGIN
			--One or more Service type tasks for the ILBO
			--are not mapped to a service action
			SELECT @M_ERRORID=1152
			RETURN 
		END
		*/
	
		/*	Removed as ASPGen does not use these 
		--CheckAllReqBRsHaveActions
		--Do i have any gui type reqbr for the ILBO without any actions 
		if EXISTS (
		SELECT 	RBR.BRNAME		
		FROM	#fw_req_BUSINESSRULE		RBR,
			#fw_req_TASK_RULE		TR,
			#fw_req_ACTIVITY_ILBO_TASK	AIT,
			#fw_req_ACTIVITY_ILBO		AI
		WHERE	AI.ILBOCODE	=	@ILBOCode	AND
			AIT.ActivityId	=	AI.ActivityId	AND
			AIT.TaskName	=	TR.TaskName	AND
			RBR.BRNAME 	= 	TR.BRNAME	AND
			RBR.BRTYPE	=	'UI'		AND
			RBR.BRNAME	NOT IN (	SELECT 	ReqBRName 
							FROM 	#fw_des_ILBO_ACTIONS	DA
							WHERE	DA.ILBOCODE	= AI.ILBOCODE
						)	
		)
		BEGIN
			--One or more GUI type REQBRs for the ILBO
			--have not resulted in actions
			SELECT @M_ERRORID=1153
			RETURN 
		END	
		*/
	
		--CheckAllServiceReqBRsHaveDesBRs
		--ALL service type REQBRs for the ILBO that have not resulted in 
		--des brs
		IF EXISTS(
		SELECT 	RBR.BRNAME		
		FROM	#fw_req_BUSINESSRULE		RBR,
			#fw_req_TASK_RULE		TR,
			#fw_req_ACTIVITY_ILBO_TASK	AIT,
			#fw_req_ACTIVITY_ILBO		AI
		WHERE	AI.ILBOCODE	=	@ILBOCode	AND
			AIT.ActivityId	=	AI.ActivityId	AND
			AIT.ILBOCode	=	AI.ILBOCode	AND
			AIT.TaskName	=	TR.TaskName	AND
			RBR.BRNAME 	= 	TR.BRNAME	AND
			RBR.BRTYPE	!=	'UI'		AND
			RBR.BRNAME	NOT IN (	SELECT 	DISTINCT ReqBRName 
							FROM 	#fw_des_REQBR_DESBR	
						)	
		)
		BEGIN
			--One or more service type REQBRs for the ILBO
			--have not resulted in des brs
			SELECT @M_ERRORID=1154
			RETURN 
		END	
	
	
		--	MODIFICATION by Madusudanan R  - 15 Mar 2000 - DesWB_2nd_Cut_Design_7_Amend_5.doc
		-- Are there any multiline segments for any of the services
		-- having 'ModeFlag' dataitem that are mapped to non-grid controls
		IF EXISTS 
		(
			--SELECT 	SVD.ILBOCode, PS.ServiceName, SS.SegmentName, SDI.DataItem, SVD.ControlID, SVD.ViewName
			SELECT 	'X'
			FROM 	#fw_des_ilbo_service_view_datamap SVD,
				#fw_des_ilbo_services PS,
			   	#fw_des_service_segment SS,
			   	#fw_des_service_dataitem SDI,
			   	#fw_req_ilbo_control RC
			/*WHERE 	SVD.ILBOCode 		= PS.ILBOCode 		AND
				SVD.ServiceName 	= PS.ServiceName 	AND
			   	SS.ServiceName 		= SDI.ServiceName    	AND 
			   	SS.SegmentName 		= SDI.SegmentName 	AND
			   	SVD.SegmentName 	= SS.SegmentName    	AND 
			   	PS.ServiceName 		= SDI.ServiceName 	AND
			   	SVD.ILBOCode 		= RC.ILBOCode    	AND 
			   	SVD.ControlID 		= RC.ControlID 		AND
				(SS.InstanceFlag 	= 1) 			AND 
			   	(PS.ILBOCode 		= @ILBOCode) 		AND 
			   	(SDI.DataItemName 	= N'ModeFlag') 		AND 
			   	(SVD.IsControl 		= 1) 			AND 
			   	
					(RC.Type 		NOT IN ( N'RSGrid',  N'VirtualGrid'))*/
			/*WHERE 	SVD.ILBOCode 		= @ILBOCode 		AND
			   	SS.ServiceName 		= SDI.ServiceName    	AND 
			   	SS.SegmentName 		= SDI.SegmentName 	AND
			   	SVD.SegmentName 	= SS.SegmentName    	AND 
			   	SVD.ServiceName 	= SDI.ServiceName 	AND
			   	SVD.ILBOCode 		= RC.ILBOCode    	AND 
			   	SVD.ControlID 		= RC.ControlID 		AND
				(SS.InstanceFlag 	= 1) 			AND 
			   	(SDI.DataItemName 	= N'ModeFlag') 		AND 
			   	(SVD.IsControl 		= 1) 			AND 
				(RC.Type 		NOT IN ( N'RSGrid',  N'VirtualGrid'))*/
	/*********************** Code for Optimization*********************************************/
			 WHERE 	SVD.ILBOCode = @ILBOCode 
	   			AND SS.ServiceName = SDI.ServiceName 
	   			AND SS.SegmentName = SDI.SegmentName 
	   			AND SVD.SegmentName = SS.SegmentName 
	   			AND SDI.SegmentName = SVD.SegmentName 
	   			AND SVD.ServiceName = SDI.ServiceName 
			/*Additional condition added for Rvw_1.2_88 Ref:Rollover Case RVW_1.1.1_967 */
				AND SVD.DataitemName 	= SDI.DataitemName	
			/* End of change for Rvw_1.2_88 Ref : Rollover Case RVW_1.1.1_967 */
	   			AND SS.ServiceName = SVD.ServiceName 
	   			AND SVD.ILBOCode = RC.ILBOCode 
	   			AND RC.ILBOCode = @ILBOCode 
	   			AND SVD.ControlID = RC.ControlID 
	   			AND SS.InstanceFlag = 1 
	   			AND SDI.DataItemName = N'ModeFlag' 
	   			AND SVD.IsControl = 1 
	   			AND SS.InstanceFlag = SVD.IsControl 
				-- ListView added for TECH-28436
	   			AND RC.Type NOT IN (N'RSGrid', N'VirtualGrid', N'RSTreeGrid', N'RSPivotGrid', 'RSListView') 
	
	/***********************End of code for optimization*************************************/
	
		)
		BEGIN
			--One or more multiline segments of one or more services of the plbo
			--having dataitem 'ModeFlag' are mapped to non multiline controls
			SELECT @M_ERRORID=1610
			RETURN 
	
		END
	
	
	-- Are there any multiline segments for any of the services with 'ModeFlag'
	-- dataitems that are already mapped to a control view....  mapping should not be done explicitly
		IF EXISTS 
		(
		SELECT 	SVD.ILBOCode, 
		   	SVD.ServiceName, 
		   	SVD.SegmentName, 
		   	SVD.DataItemName, 
		   	SVD.ControlID, 
		   	SVD.ViewName
		FROM 	#fw_req_ilbo_control RC,
		   	#fw_des_ilbo_service_view_datamap SVD,
			--Modified by Madusudanan R, 4 Jul 2000, exclude #fw_des_ilbo_services
		   	--#fw_des_ilbo_services PS,
			--Modification ENDS
		   	#fw_des_service_segment SS
			--Modified by Madusudanan R, 4 Jul 2000, exclude #fw_des_ilbo_services
/*
		WHERE 	SVD.ILBOCode 	= PS.ILBOCode		AND
		   	SVD.ServiceName = SS.ServiceName    	AND 
		   	SVD.SegmentName = SS.SegmentName	AND
		   	RC.ControlID 	= SVD.ControlID	    	AND 
		   	RC.ILBOCode 	= SVD.ILBOCode		AND
			(SS.InstanceFlag= 1) 			AND 
		   	(PS.ILBOCode 	= @ILBOCode) 		AND 
		   	(SVD.IsControl 	= 1) 			AND 
		   	(RC.Type 	= N'RSGrid') 		AND 
		   	(SVD.DataItemName = N'ModeFlag')	)
*/
		WHERE 	SVD.ILBOCode 	= @ILBOCode		AND
		   	SVD.ServiceName = SS.ServiceName    	AND 
		   	SVD.SegmentName = SS.SegmentName	AND
		   	RC.ControlID 	= SVD.ControlID	    	AND 
		   	RC.ILBOCode 	= SVD.ILBOCode		AND
			(SS.InstanceFlag= 1) 			AND 
		   	(SVD.IsControl 	= 1) 			AND 
			-- ListView added for TECH-28436
		   	(RC.Type 	in  (N'RSGrid', N'VirtualGrid', N'RSTreeGrid', N'RSPivotGrid', 'RSListView'))  		AND 
		   	(SVD.DataItemName = N'ModeFlag')	)
		BEGIN
			--One or more 'ModeFlag' dataitems of multiline segments of one or more services of the plbo
			--are mapped to control-view.
			SELECT @M_ERRORID=1611
			RETURN 
		END

		DECLARE curModeFlagViews CURSOR  LOCAL
		FOR 
				SELECT	DISTINCT SVD.ServiceName, 
				SVD.SegmentName, 
				SVD.ControlID,SVD.taskname,SVD.activityid -- Code modified for the bugID:PLF2.0_04333
			FROM 	#fw_des_service_segment SS,
				--Modified by Madusudanan R, 4 Jul 2000, exclude #fw_des_ilbo_services
				--#fw_des_ilbo_services PS,
				--Modification ENDS
				#fw_des_ilbo_service_view_datamap SVD,
				#fw_req_ilbo_control RC,
				#fw_des_service_dataitem SDI
				--Modified by Madusudanan R, 4 Jul 2000, exclude #fw_des_ilbo_services
	/*		WHERE 	SS.ServiceName 	= PS.ServiceName		AND
				SVD.ILBOCode 	= RC.ILBOCode			AND 
				SVD.ServiceName     = PS.ServiceName		AND
				SVD.ControlID 	= RC.ControlID			AND
				SS.SegmentName 	= SVD.SegmentName    		AND 
				PS.ILBOCode 	= SVD.ILBOCode			AND
				SS.ServiceName 	= SDI.ServiceName    		AND 
				SS.SegmentName 	= SDI.SegmentName		AND
				(PS.ILBOCode 	= @ILBOCode) 			AND 
				(SS.InstanceFlag= 1) 				AND 
				(RC.Type 	IN (N'RSGrid', N'VirtualGrid')) AND 
				(SVD.IsControl 	= 1) 				AND 
				(SDI.DataItemName = N'ModeFlag')*/
			WHERE 	SVD.ILBOCode 	= RC.ILBOCode			AND 
				SVD.ControlID 	= RC.ControlID			AND
				SS.SegmentName 	= SVD.SegmentName    		AND 
				SVD.ILBOCode 	= @ILBOCode			AND
				SS.ServiceName 	= SDI.ServiceName    		AND 
				SS.SegmentName 	= SDI.SegmentName		AND
				(SS.InstanceFlag= 1) 				AND 
				-- ListView added for TECH-28436
				(RC.Type 	IN (N'RSGrid', N'VirtualGrid', N'RSTreeGrid', N'RSPivotGrid', 'RSListView') ) AND 
				(SVD.IsControl 	= 1) 				AND 
				(SDI.DataItemName = N'ModeFlag')
		OPEN 	curModeFlagViews
	
		FETCH NEXT FROM curModeFlagViews INTO @ServiceName, @SegmentName, @ControlID,@TaskName, @ActivityID -- Code modified for the bugID:PLF2.0_04333
		WHILE @@FETCH_STATUS = 0
		BEGIN
	
			IF NOT EXISTS (SELECT ViewName FROM #fw_req_ilbo_view WHERE ILBOCode = @ILBOCode and Controlid = @ControlID and BTSynonym = 'ModeFlag')
			BEGIN
				--	Find the view for the 'ModeFlag' ..it is always MAXCOLS  + 2 
				SELECT 	@ModeFlagView = MAX(CONVERT(INT, ViewName)) + 2 -- 11537
				FROM	#fw_req_ILBO_VIEW
				WHERE	ILBOCode = @ILBOCode	AND
					ControlID = @ControlID	
				and  isnumeric(viewname)=1 --kiruthika modeflag issue 
	-- For tag control modeflag handliong
		if isnull(@ModeFlagView,'') = ''
				select @ModeFlagView = 2
	-- For tag control modeflag handliong
				--	Create a view for the control...			
				INSERT 	
				INTO 	#fw_req_ilbo_view (ilbocode, controlid, viewname, displayflag, displaylength, btsynonym ) 
				VALUES	(	@ILBOCode, 
						@ControlID, 
						@ModeFlagView, 
						'F', 	--DisplayFlag
						NULL, 	--Display Length
						'ModeFlag'	--BTSynonym
					)	
			END
			ELSE
			BEGIN
				SELECT 	@ModeFlagView = ViewName
				FROM	#fw_req_ilbo_view
				WHERE	ILBOCode = @ILBOCode	AND
					ControlID = @ControlID	AND
					BTSynonym = 'ModeFlag'
			END
	
			--	Now map this view to the corresponding service dataitem
			-- Code commented for the bugID:PLF2.0_04333
			--SELECT 	DISTINCT @TaskName = Taskname, @ActivityID = ActivityID 
			--FROM	#fw_des_ilbo_service_view_datamap
			--WHERE	ILBOCode = @ILBOCode		AND
			--	ServiceName = @ServiceName			
	
			--	...and insert the mapping		
			INSERT	
			INTO	#fw_des_ilbo_service_view_datamap (ILBOCode, ServiceName, ActivityId, TaskName, SegmentName, DataItemName, IsControl, ControlID, ViewName, VariableName)
			VALUES	(@ILBOCode, @ServiceName, @ActivityID, @TaskName, @SegmentName, 'ModeFlag', 1, @ControlID, @ModeFlagView, NULL)	
			
			FETCH NEXT FROM curModeFlagViews INTO @ServiceName, @SegmentName, @ControlID,@TaskName, @ActivityID		
		END
		
		CLOSE curModeFlagViews
		DEALLOCATE curModeFlagViews


		--	MODIFICATION ENDS
		--check are There Any 'TransactioniD' mapped to ILBo controls 
		IF EXISTS 
		(
			SELECT 	SVD.ILBOCode, 
				SVD.ServiceName, 
				SVD.DataItemName 
			FROM 	#fw_des_ilbo_service_view_datamap SVD,
				#fw_des_service_dataitem SS
			WHERE 	SVD.ILBOCode = @ILBOCode					
			AND     SVD.DataItemName = 'TransactionInstanceId'	
			AND	SS.DataItemName = SVD.DataItemName			
			AND	SVD.ServiceName = SS.ServiceName    		
		) 
		BEGIN
			SELECT @M_ERRORID= 2462 
			RETURN 
		END
	
		--INSERT  'TransactioniD' and mapped to ILBo controls 
		-- Code modified by Hema for FCSG-RVW_1.2_285 starts here 
		IF(@ILBOtype in(1,2,4,5))
		BEGIN
			SELECT 	@ControlID = 'TransactionInstanceId',
				@ViewName = 'TransactionInstanceId',
				@BTSynonym = 'TransactionInstanceId',
				@dataitem = 'TransactionInstanceId'
	
			IF EXISTS (SELECT 	DISTINCT @ILBOCode, SDI.ServiceName, AIT.Activityid, AIT.TaskName, 
					SDI.SegmentName, SDI.DataitemName
				FROM 	#fw_des_ilbo_services ILBOSER,
					#fw_req_activity_ilbo_task AIT,
					#fw_des_service_dataitem SDI,
					#fw_des_ilbo_service_view_datamap ILSERDATAMAP
				WHERE ILBOSER.ilbocode = @ILBOCode
				AND AIT.ilbocode = ILBOSER.ilbocode
				AND SDI.ServiceName = ILBOSER.ServiceName
				AND SDI.Dataitemname = @dataitem
				AND ILSERDATAMAP.ServiceName = SDI.ServiceName
				AND ILSERDATAMAP.Activityid = AIT.ActivityID
				AND ILSERDATAMAP.TaskName = AIT.TaskName)
			BEGIN 
				IF NOT EXISTS (SELECT ControlID FROM #fw_req_ilbo_control 
						WHERE ILBOCode = @ILBOCode 
						AND Controlid = @ControlID)
				BEGIN -- {
						--	Create  the control...			
						INSERT INTO #fw_req_ilbo_control
						(ilbocode, ControlID, Type, UpdUser, UpdTime)
						VALUES	
						(@ILBOCode, @ControlID, 'RSEditCtrl', SUSER_SNAME(), GETDATE())	
				END -- }
		
				IF NOT EXISTS (SELECT ViewName FROM #fw_req_ilbo_view 
						WHERE ILBOCode = @ILBOCode 
						AND Controlid = @ControlID
						AND ViewName = @ViewName)
				BEGIN -- {
					--	Create a view for the control...			
					INSERT INTO #fw_req_ilbo_view 
					(ilbocode, ControlID, ViewName, DisplayFlag, DisplayLength, BTSynonym, 
					 UpdUser, UpdTime)
					VALUES	
					(@ILBOCode, @ControlID, @ViewName, 'F',--DisplayFlag
					 NULL, --Display Length
					 @BTSynonym,	--BTSynonym
					 SUSER_SNAME(), GETDATE())	
				END -- }
		
				--	...and insert the mapping		
				IF NOT EXISTS(SELECT 'x' 
						FROM 	#fw_des_ilbo_service_view_datamap ILSERDATAMAP
						WHERE ILBOCode   = @ILBOCode  
						AND DataItemName  = @dataitem)
				BEGIN
					INSERT	INTO	#fw_des_ilbo_service_view_datamap
					(ILBOCode, ServiceName, ActivityId, TaskName, SegmentName, DataItemName, 
					IsControl, ControlID, ViewName, VariableName, UpdUser, UpdTime)
					SELECT 	DISTINCT @ILBOCode, SDI.ServiceName, AIT.Activityid, AIT.TaskName, 
						SDI.SegmentName, SDI.DataitemName, 1, @ControlID, @ViewName, NULL,
						SUSER_SNAME(), GETDATE()
					FROM 	#fw_des_ilbo_services ILBOSER,
						#fw_req_activity_ilbo_task AIT,
						#fw_des_service_dataitem SDI,
						#fw_des_ilbo_service_view_datamap ILSERDATAMAP
					WHERE ILBOSER.ilbocode = @ILBOCode
					AND AIT.ilbocode = ILBOSER.ilbocode
					AND SDI.ServiceName = ILBOSER.ServiceName
					AND SDI.Dataitemname = @dataitem
					AND ILSERDATAMAP.ServiceName = SDI.ServiceName
					AND ILSERDATAMAP.Activityid = AIT.ActivityID
					AND ILSERDATAMAP.TaskName = AIT.TaskName
				END
			END -- end of if dataitem "TransactionInstanceId" exists
		END -- end of IF(@ILBOtype in(1,2,4,5))
		-- Code modified by Hema for FCSG-RVW_1.2_285 ends here 
	
		/*	This validation can only be at activity level for an ILBO.  This is being done while generating ASPs
			--CheckAllDIsMapped
		--All dataitems for all services for the ILBO
		--not present in the service_view_datamap table..unmapped dataitems
		IF EXISTS (
		SELECT	SDI.DATAITEMNAME
		FROM	#fw_des_SERVICE_DATAITEM 	SDI,
			#fw_des_ILBO_SERVICES		PS
		WHERE	PS.ILBOCode	=	@ILBOCode	AND
			SDI.ServiceName	=	PS.ServiceName	AND	
			SDI.FlowAttribute !=	'3'		AND
			SDI.DataItemName NOT IN (	SELECT 	SVD.DataItemName 
							FROM 	#fw_des_ILBO_SERVICE_VIEW_DATAMAP	SVD
							WHERE	SVD.ILBOCode	= @ILBOCode		AND
								SVD.ServiceName	= SDI.ServiceName
						)
		)
		BEGIN
			--One or more dataitems for one or more services used by the ILBO
			--have not been mapped
			SELECT M_ERRORID=610509
			RETURN 
		END	
		*/

		--CheckAllILBOServicesPublished
		--are there any unpublished services for the ILBO
		IF EXISTS (
		SELECT 	S.ServiceName
		FROM	#fw_des_ILBO_SERVICES	ILS,
			#fw_des_SERVICE		S
		WHERE	ILS.ILBOCODE 	=	@ILBOCode		AND
			S.SERVICENAME	=	ILS.SERVICENAME		AND
			S.STATUSFLAG	=	0
		)
		BEGIN
			--One or more service used by the ILBO have not been published
			SELECT @M_ERRORID=1128
			RETURN 
		END	

		--CheckMultiSegmentDIsMappedtoOneControl
		--COUNT OF CONTROLS TO WHICH DI'S IN A MULTI INSTANCE SEGMENT ARE MAPPED
		IF EXISTS (
		SELECT 	COUNT(SVD.ControlID)
		--Modified by Madusudanan R, 4 Jul 2000, exclude #fw_des_ilbo_services		
		FROM 	--#fw_des_ILBO_SERVICES	ILS,
		--Modification ENDS
			#fw_des_service_segment	ss,
			#fw_des_ilbo_service_view_datamap	SVD,
			#fw_des_service_dataitem SDI
		--Modified by Madusudanan R, 4 Jul 2000, exclude #fw_des_ilbo_services
		/*	where 	ILS.ILBOCODE	=	@ILBOCode	AND
			SS.SERVICENAME	=	ILS.SERVICENAME	AND
			SS.InstanceFlag	=	'1'		AND
			SDI.ServiceName	=	SS.ServiceName	AND
			SDI.SegmentName	=	ss.SegmentName	AND
			SVD.ILBOCODE	=	ILS.ILBOCODE	AND
			SVD.ServiceName	=	SDI.ServiceName	AND
			SVD.SegmentName =	SDI.SegmentName AND
			SVD.DataItemName=	SDI.DataItemName */
		where 	SS.InstanceFlag	=	'1'		AND
			SDI.ServiceName	=	SS.ServiceName	AND
			SDI.SegmentName	=	ss.SegmentName	AND
			SVD.ILBOCODE	=	@ILBOCode	AND
			SDI.ServiceName	=	SVD.ServiceName	AND
			SDI.SegmentName =	SVD.SegmentName AND
			SDI.DataItemName=	SVD.DataItemName
		--Modification ENDS 
		
		/*--Commented to rollover the fix from rvw_1.1.1 to rvw_1.2 for
		  -- Defect No. rvw_1.2_57 Reference : rvw_1.1.1_852  
		GROUP BY SVD.ServiceName, SVD.SegmentName, SVD.DataItemName
		HAVING	COUNT(SVD.ControlID) >1	
		)*/
		/* Fix for Defect No.rvw_1.1.1_852 rolled over to Defect No.rvw_1.2_57
		 Change for RVW_1.1.1_852 - Group by .. : Dataitem removed and ActivityID added */
		GROUP BY SVD.ServiceName, SVD.SegmentName, SVD.ActivityID
		HAVING	COUNT(distinct SVD.ControlID) >1	
		)
		 -- Modification for Roll over : rvw_1.1.1_852 to rvw_1.2_57 ends
			
		BEGIN
			--One or more dataitems of multi-instance segments of
			--services used by the ILBO are mapped to different controls
			SELECT @M_ERRORID=1156
			RETURN 
		END	

--------Lakshman
		--CheckILBOforLinkPublished
		--ALL UNPUBLISHED LINKed ILBO'S FOR THE GIVEN ILBO
	/*	IF EXISTS (
			SELECT 	I.ILBOCODE
		FROM	#fw_req_ILBO	I,
			#fw_req_ILBO_LINKUSE	L,
			#fw_req_ACTIVITY_ILBO	AIL, -- modified by deepa
			#fw_req_ACTIVITY		A -- modified by deepa
			
		WHERE	L.ParentILBOCode	=	@ILBOCode	AND
			I.ILBOCode		=	L.ChildILBOCode	AND
			I.STATUSFLAG		=	0		AND
			AIL.ILBOCode		=	I.ILBOCode	AND	-- modified by deepa
			A.ActivityID		=	AIL.ActivityID	AND	-- modified by deepa
			A.ComponentName		=	@comname		-- modified by deepa
			
		)
		BEGIN
			--One or more linked ILBOs have not been published
			SELECT @M_ERRORID=1142
			RETURN 
		END	
	*/
---Lakshman


		--CheckAllBEReqErrorsMapped
		--REQ ERRORS FOR all service type brs not having corresponding
		--design error ids...
		-- Code modified by Hema for FCSG-RVW_1.2_186 starts here
		/*	IF EXISTS (
		SELECT 	RBRE.ErrorCode		
		FROM	#fw_req_BUSINESSRULE		RBR,
			#fw_req_TASK_RULE		TR,
			#fw_req_ACTIVITY_ILBO_TASK	AIT,
			#fw_req_ACTIVITY_ILBO		AI,
			#fw_req_BR_ERROR			RBRE
		WHERE	AI.ILBOCODE	=	@ILBOCode	AND
			AIT.ActivityId	=	AI.ActivityId	AND
			AIT.TaskName	=	TR.TaskName	AND
			RBR.BRNAME 	= 	TR.BRNAME	AND
			RBR.BRTYPE	!=	'UI'		AND
			RBRE.BRName	=	RBR.BRNAME	AND
			RBRE.ERRORCODE NOT IN (	SELECT 	DE.ReqError	
						FROM	#fw_des_ERROR DE
						)
		)*/
		IF EXISTS (
			SELECT REQBRERROR.ErrorCode
			FROM 	#fw_req_activity_ilbo ACTILBO,
				#fw_req_activity_ilbo_task ACTILBOTASK,
				#fw_req_task_rule TASKBR,
				#fw_req_businessrule REQBR,
				#fw_req_br_error REQBRERROR FULL OUTER JOIN 
				#fw_des_error DESERROR ON (ISNULL(DESERROR.ReqError, 0) = REQBRERROR.ErrorCode)
			WHERE ACTILBO.ilbocode = @ILBOCode
			AND ACTILBOTASK.ActivityId = ACTILBO.ActivityId
			AND TASKBR.Taskname = ACTILBOTASK.Taskname
			AND REQBR.BRName = TASKBR.BRName
			AND REQBR.BRType != 'UI'
			AND REQBRERROR.BRName = REQBR.BRName
			AND DESERROR.ReqError IS NULL	)
		-- Code modified by Hema for FCSG-RVW_1.2_186 ends here
		BEGIN
			--One or more service type requirement br errors 
			--have not been mapped to design errors
			SELECT @M_ERRORID=1133
			RETURN 
		END	
	
	
		--CheckAllFEReqErrorsMapped
		--ALL REQ ERROR IDS FOR UI TYPE TASK, FOR UI TYPE BRS
		--NOT HAVING CORRESPONDING DESIGN ERROR ID
		IF EXISTS (
		SELECT 	RBRE.ErrorCode
		FROM	#fw_req_ACTIVITY_ILBO		AI,
			#fw_req_ACTIVITY_ILBO_TASK	AIT,
			#fw_req_TASK			T,
			#fw_req_TASK_RULE		TR,
			#fw_req_BUSINESSRULE		RBR,
			#fw_req_BR_ERROR			RBRE
		WHERE	AI.ILBOCode	=	@ILBOCode	AND
			AIT.ActivityId	=	AI.ActivityId	AND
			T.TaskName	=	AIT.TaskName	AND
			T.TaskType	= 	'UI'		AND
			TR.TaskName	=	T.TaskName	AND
			RBR.BRName	=	TR.BRName	AND
			RBR.BRType	=	'IU'		AND
			RBRE.BRName	=	RBR.BRName	AND
			RBRE.ErrorCode	NOT IN (	SELECT	DE.ReqError
							FROM	#fw_des_ERROR	DE
						)
		)
		BEGIN
			--one or more error for UI type BRs for UI type
			--tasks do not have a corresponding design error
			SELECT @M_ERRORID=1134
			RETURN 
		END	

		/*	Removed as ASPGen does not use these 
		--ALL DERROR IDS FOR REQ ERROR IDS FOR UI TYPE TASK, FOR UI TYPE BRS
		--NOT HAVING CORRESPONDING ILERROR MAPPING 
		IF EXISTS(
		SELECT 	DE.ErrorID
		FROM	#fw_req_ACTIVITY_ILBO		AI,
			#fw_req_ACTIVITY_ILBO_TASK	AIT,
			#fw_req_TASK			T,
			#fw_req_TASK_RULE		TR,
			#fw_req_BUSINESSRULE		RBR,
			#fw_req_BR_ERROR			RBRE,
			#fw_des_ERROR			DE
		WHERE	AI.ILBOCode	=	@ILBOCode	AND
			AIT.ActivityId	=	AI.ActivityId	AND
			T.TaskName	=	AIT.TaskName	AND
			T.TaskType	= 	'UI'		AND
			TR.TaskName	=	T.TaskName	AND
			RBR.BRName	=	TR.BRName	AND
			RBR.BRType	=	'IU'		AND
			RBRE.BRName	=	RBR.BRName	AND
			DE.ReqError	=	RBRE.ErrorCode	AND
			DE.ErrorID	NOT IN 	(	SELECT	ILE.ErrorID
							FROM	#fw_des_ILBO_CTRL_EVENT	CE,
								#fw_des_ILERROR		ILE
							WHERE	CE.ILBOCode	=	@ILBOCode	AND
								CE.TaskName	=	AIT.TaskName	AND
								ILE.ILBOCode	=	CE.ILBOCode	AND
								ILE.ControlID	=	CE.ControlID	AND
								ILE.EventName	=	CE.EventName
						)
		)
		BEGIN
			--one or more D errors for UI type BRs for UI type
			--tasks do not have a corresponding plerror mapping
			SELECT @M_ERRORID=1135
			RETURN 
		END	
		*/
	
		--CheckAllPlaceHoldersMappedforILBO
		--ALL UNMAPPED PLACEHOLDERS FOR THE ILBO, USER METHOD ERRORS
		IF EXISTS (
		SELECT 	EP.PlaceholderName
		FROM 	#fw_des_ILERROR			ILE,
			#fw_des_ERROR_PLACEHOLDER	EP
		WHERE	ILE.ILBOCode	=	@ILBOCode	AND
			ILE.ErrorID	=	EP.ErrorID	AND
			EP.PlaceholderName	NOT IN (	
							SELECT	IP.PlaceholderName
							FROM	#fw_des_ilbo_placeholder IP
							WHERE	IP.ILBOCode	= ILE.ILBOCode	AND
								IP.ControlID	= ILE.ControlID	AND
								IP.EventName	= ILE.EventName AND
								IP.ErrorID 	= ILE.ErrorID
							)
		)
		BEGIN
			--One or more Placeholders for one or more errors
			--for user methods for the ILBO have not been mapped to control-view
			SELECT @M_ERRORID=1157
			RETURN 
		END	

		-- Check that if a task is mapped to Grid Enter Key Event, then it cannot be associated 
		-- to service having a multi instance segment
		/*	IF EXISTS(	SELECT 'X'
				FROM 	#fw_des_ilbo_service_view_datamap ISVD,
					#fw_des_ilbo_ctrl_event IEVENT,
					#fw_req_ilbo_control ICTRL,
					#fw_des_service_segment SERSEG
				WHERE ISVD.ilbocode = @ILBOCode
				AND IEVENT.ilbocode = ISVD.ilbocode
				AND IEVENT.taskname = ISVD.taskname
				AND IEVENT.EventName = 'EnterKeyPressed'
				AND ICTRL.ilbocode = IEVENT.ilbocode
				AND ICTRL.controlid = IEVENT.controlid
				AND ICTRL.Type = 'RSGrid'
				AND SERSEG.Servicename = ISVD.Servicename
				AND SERSEG.InstanceFlag = 1
			)
		*/
	
		IF EXISTS  (	SELECT 'X'
				FROM 	#fw_des_ilbo_service_view_datamap ISVD,
					#fw_req_ilbo_control ICTRL,
					#fw_des_ilbo_ctrl_event ICE,
					#fw_req_task RT,
					#fw_des_service_segment SERSEG
				WHERE ISVD.ilbocode = @ILBOCode
				AND  ICE.ILBOCode = ISVD.ILBOCode
				AND  ICE.TaskName = ISVD.TaskName
				AND  RT.TaskName = ISVD.TaskName
				AND  RT.TaskType = 'UI'
				AND ICTRL.ilbocode = ISVD.ilbocode
				AND ICTRL.controlid = ICE.controlid
				-- ListView added for TECH-28436
				AND ICTRL.Type in (N'RSGrid', N'VirtualGrid', N'RSTreeGrid', N'RSPivotGrid', 'RSListView') 
				AND SERSEG.Servicename = ISVD.Servicename
				AND SERSEG.InstanceFlag = 1
			 )	
		BEGIN
			-- One or more tasks mapped to a multiline Event of the ilbo <@ILBOCode> is 
			-- associated with a service containing a multi instance segment.
			SELECT @M_ErrorID = 3267
			RETURN
		END

		-- Check that if a task is mapped to Grid Enter Key Event, then it can be associated to only one ILBO
		-- Code modified for RVW_1.4_48 by Santosh Kumar Sinha on  24th Apr 2002
		 /*	IF EXISTS (	SELECT COUNT(DISTINCT(A.ilbocode))      
				FROM #fw_des_ilbo_service_view_datamap A ,
					 #fw_des_ilbo_ctrl_event B,
				 	#fw_req_ilbo_control C,
				 	#fw_des_service_segment D
				WHERE B.ILBOCode = @ILBOCode
				AND B.EventName = 'EnterKeyPressed'
				AND C.ilbocode = B.ilbocode 
				AND C.controlid = B.controlid
				AND C.Type = 'RSGrid'
				AND A.Taskname = B.TaskName
				AND D.Servicename = A.Servicename
				AND D.InstanceFlag = 0
				GROUP BY A.ServiceName, A.TaskName 
				HAVING COUNT(DISTINCT(A.ilbocode)) >1 )
		*/
	 	IF EXISTS (	SELECT 'X' -- COUNT(DISTINCT(A.ilbocode))      
				FROM 	#fw_des_ilbo_service_view_datamap A ,
					#fw_req_task C
				WHERE A.ILBOCode = @ILBOCode
				AND C.TaskName = A.TaskName
				AND C.TaskType = 'UI'
				GROUP BY A.ServiceName, A.TaskName 
				HAVING COUNT(DISTINCT(A.ilbocode)) >1 ) 
	 	
		-- End of Code modification for RVW_1.4_48 by Santosh Kumar Sinha on  24th Apr 2002
		BEGIN
			-- One or more tasks mapped to the ilbo <ILBOCode> is associated to more than one ilbo.
			SELECT @M_ErrorID = 3268
			RETURN
		END

	-- Added by Hema for New changes in 1.4 for Mapbts, Mouse Over Text and Hidden View Definition
		DECLARE @VisibleViewCnt INT,
			@HiddenViewCnt INT
	
		SELECT @VisibleViewCnt = COUNT(*) FROM #fw_req_ilbo_view VW
		WHERE VW.ILBOCODE = @ILBOCODE
		AND VW.DisplayFlag = 'T'
		AND (SELECT BT.Datatype FROM #fw_req_bterm BT, #fw_req_bterm_synonym BTSYN
			WHERE BTSYN.BTSynonym = ISNULL(VW.BTSynonym, '')
			AND BT.BTName = BTSYN.BTName) = 'Enumerated'
	
		SELECT @HiddenViewCnt = COUNT(*) FROM #fw_req_ilbo_view VW
		WHERE VW.ILBOCODE = @ILBOCODE
		AND VW.DisplayFlag = 'F'
		AND (SELECT BT.Datatype FROM #fw_req_bterm BT, #fw_req_bterm_synonym BTSYN
			WHERE BTSYN.BTSynonym = ISNULL(VW.BTSynonym, '')
			AND BT.BTName = BTSYN.BTName) = 'Enumerated'
		
		IF @VisibleViewCnt <> @HiddenViewCnt
		BEGIN
			-- 'One or more visible views of the UI which are mapped to Enumerated BTs do not have corresponding hidden views defined.'
			SELECT @M_ERRORID = 3299
			RETURN
		END
	-- Added by Hema for New changes in 1.4 for Mapbts, Mouse Over Text and Hidden View Definition
	
		--SaveILBOStatus
		UPDATE 	#fw_req_ILBO
		SET	STATUSFLAG	=	'1'
		WHERE 	ILBOCODE	= 	@ILBOCODE


	END
	
	ELSE
	
	BEGIN	
		--Process for UNpublishing the ILBO

		--	MODIFICATION by Madusudanan R  - 15 Mar 2000 - DesWB_2nd_Cut_Design_7_Amend_5.doc
		DECLARE curModeFlagViews CURSOR  LOCAL
		FOR 
				SELECT	DISTINCT SVD.ServiceName, 
				SVD.SegmentName, 
				SVD.ControlID
			FROM 	#fw_des_service_segment SS,
				--Modified by Madusudanan R, 4 Jul 2000, exclude #fw_des_ilbo_services
				--#fw_des_ilbo_services PS,
				--Modification ENDS
				#fw_des_ilbo_service_view_datamap SVD,
				#fw_req_ilbo_control RC,
				#fw_des_service_dataitem SDI
			--Modified by Madusudanan R, 4 Jul 2000, exclude #fw_des_ilbo_services
		/*		WHERE 	SS.ServiceName 	= PS.ServiceName		AND
				SVD.ILBOCode 	= RC.ILBOCode			AND 
				SVD.ControlID 	= RC.ControlID			AND
				SVD.ServiceName = PS.ServiceName		AND
				SS.SegmentName 	= SVD.SegmentName    		AND 
				PS.ILBOCode 	= SVD.ILBOCode			AND
				SS.ServiceName 	= SDI.ServiceName    		AND 
				SS.SegmentName 	= SDI.SegmentName		AND
				(PS.ILBOCode 	= @ILBOCode) 			AND 
				(SS.InstanceFlag= 1) 				AND 
				(RC.Type 	IN (N'RSGrid', N'VirtualGrid')) AND 
				(SVD.IsControl 	= 1) 				AND 
				(SDI.DataItemName = N'ModeFlag')*/
			WHERE 	SVD.ILBOCode 	= RC.ILBOCode			AND 
				SVD.ControlID 	= RC.ControlID			AND
				SS.SegmentName 	= SVD.SegmentName    		AND 
				SVD.ILBOCode	= @ILBOCode			AND
				SS.ServiceName 	= SDI.ServiceName    		AND 
				SS.SegmentName 	= SDI.SegmentName		AND
				(SS.InstanceFlag= 1) 				AND 
				-- ListView added for TECH-28436
				(RC.Type 	IN (N'RSGrid', N'VirtualGrid', N'RSTreeGrid', N'RSPivotGrid', 'RSListView')  ) AND 
				(SVD.IsControl 	= 1) 				AND 
				(SDI.DataItemName = N'ModeFlag')
				--Modification ENDS
		OPEN 	curModeFlagViews
	
		FETCH NEXT FROM curModeFlagViews INTO @ServiceName, @SegmentName, @ControlID
		WHILE @@FETCH_STATUS = 0
		BEGIN
			--	Delete from service data mapping
			DELETE
			FROM	#fw_des_ilbo_service_view_datamap
			WHERE	ILBOCode = @ILBOCode		AND
				ServiceName = @ServiceName	AND
				SegmentName = @SegmentName	AND
				DataItemName = 'ModeFlag'	AND
				ControlId   = @ControlID
	
			-- if that view is not mapped for any other service
			IF NOT EXISTS(  SELECT  VIEWNAME FROM #fw_des_ilbo_service_view_datamap
					WHERE 	ILBOCODE 	= @ILBOCODE 	AND 
						DataItemName 	= 'ModeFlag'	AND
						ControlId   	= @ControlID
					)
			BEGIN
	
				--	delete the view for the grid control
				DELETE	
				FROM 	#fw_req_ILBO_VIEW
				WHERE 	ILBOCode = @ILBOCode	AND
					ControlID = @ControlID	AND
					BTSynonym = 'ModeFlag'
			END
	
			FETCH NEXT FROM curModeFlagViews INTO @ServiceName, @SegmentName, @ControlID			
		END
		
		CLOSE curModeFlagViews
		DEALLOCATE curModeFlagViews

		--	MODIFICATION ENDS
		-- Code modified by Hema for FCSG-RVW_1.2_285 starts here 
		--DELETE  'TransactioniD' and mapped to ILBo controls 
		IF(@ILBOtype in(1,2,4,5))
		BEGIN
			SELECT 	@ControlID = 'TransactionInstanceId',
				@ViewName = 'TransactionInstanceId',
				@dataitem = 'TransactionInstanceId'
	
			IF EXISTS(SELECT 'x' FROM #fw_des_ilbo_service_view_datamap
				WHERE ILBOCode   = @ILBOCode  
				AND DataItemName  = @dataitem)
			BEGIN
				DELETE	#fw_des_ilbo_service_view_datamap
				WHERE ILBOCode   = @ILBOCode  
				AND DataItemName  = @dataitem
			END
					 
			IF  EXISTS (SELECT ViewName FROM #fw_req_ilbo_view 
					WHERE ILBOCode = @ILBOCode 
					AND Controlid = @ControlID
					AND ViewName = @ViewName)
			BEGIN -- {
				--	Delete a view for the control...			
				DELETE FROM #fw_req_ilbo_view
				WHERE ilbocode = @ILBOCode
				AND ControlID = @ControlID
				AND ViewName = @ViewName
			END -- }
	
			IF EXISTS (SELECT ControlID FROM #fw_req_ilbo_control 
					WHERE ILBOCode = @ILBOCode 
					AND Controlid = @ControlID)
			BEGIN -- {
				--	DELETE  the control...			
				DELETE FROM #fw_req_ilbo_control
				WHERE ilbocode = @ILBOCode 
				AND ControlID = @ControlID 
			END -- }
		END -- end of IF(@ILBOtype in(1,2,4,5))
	-- Code modified by Hema for FCSG-RVW_1.2_285 ends here 
--Lakshman begins
	/*DECLARE curDepIlbos CURSOR  LOCAL
		FOR 
		SELECT 	ParentILBOCode 
		FROM 	#fw_req_ILBO_LINKUSE	LNK,
			#fw_req_ILBO		IL
		WHERE	ChildILBOCode = @ILBOCode	AND
			ParentILBOCode !=@ILBOCode	AND
	--		IL.ILBOCODE = CHILDILBOCODE	AND
			IL.ILBOCODE = PARENTILBOCODE	AND
			STATUSFLAG = 1
	
		
		DECLARE	@DepIlbo 	engg_name
		DECLARE	@DepIlboDesc	UDD_LONG_DESC
		DECLARE	@CompName	engg_name
		DECLARE	@CompDesc	engg_desc
			
		OPEN curDepIlbos
	
		FETCH NEXT FROM curDepIlbos INTO @DepIlbo
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF NOT EXISTS ( SELECT 	IUCode FROM #fw_des_AFFECTED_IUS_TEMP 
					WHERE 	IUType ='ILBO' AND IUCODE = @DepIlbo
						AND TRANID = @TranID
					)
			BEGIN
				INSERT 	INTO 	#fw_des_AFFECTED_IUS_TEMP  
				SELECT	TOP 1 @TranID, 'ILBO', PC.ComponentName, PC.ComponentDesc, P.ILBOCODE, P.Description
				FROM 	#fw_req_ILBO			P,
					#fw_req_activity_ILBO		AP,
					#fw_req_process_component	PC,
					#fw_req_activity			A
				WHERE	AP.ILBOCODE = @DepIlbo		AND
					P.ILBOCODE  = AP.ILBOCODE	AND
					A.ActivityId=AP.ActivityId	AND
					PC.ComponentName =A.ComponentName
		
				EXEC de_il_fw_des_iu_save_ilbo @DepIlbo, @PublishFlag, @TranID, 0,0  ----- Added ResultFlag Parm value ....SWDES2CUT1.0S_000277
			END
			FETCH NEXT FROM curDepIlbos INTO @DepIlbo
		END
		CLOSE	curDepIlbos
		DEALLOCATE	curDepIlbos */
--Lakshman ends
		--Unpublish the ILBO
		UPDATE 	#fw_req_ILBO
		SET	STATUSFLAG	=	'0'
		WHERE 	ILBOCODE	= 	@ILBOCODE

		
		--Select all the affected IUs here...
		--only if this proc was called from FE...	
		IF @ResultFlag=1
		BEGIN
			SELECT 	IUType, ComponentName, ComponentDesc, IUCode, IUDesc 
			from 	#fw_des_AFFECTED_IUS_TEMP 
			where	tranid=@Tranid
			order by IUType desc
		
			DELETE 	FROM #fw_des_AFFECTED_IUS_TEMP 
			WHERE	TranID=@TranId
		END
	END
	SET NOCOUNT OFF
END







