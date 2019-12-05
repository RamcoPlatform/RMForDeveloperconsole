/*$$File_version_number=4.0.0.0$*/
/*******************************************************************************/
/* PROCEDURE 	: 	#fw_req_ui_ilbo_Publink_ins				*/
/* DESCRIPTION	: 	To create a link for the specified ILBO		 	*/
/********************************************************************************/
/* Modified by	: Feroz Khan I 			     								*/
/* Date    	: 12/04/2005													*/
/* Remarks 	: changes the sp to create activity dll from platform                                */
/********************************************************************************/
alter PROC de_fw_req_ui_ilbo_Publink_ins(
	@ilbocode 		engg_name,
	@description 	engg_description,
	@taskcode 		engg_name,
	@ActivityName 	engg_name,
	@ActivityId 	engg_seqno,
	@UpdUser 		engg_name = '',
	@M_ErrorId 	INT OUTPUT)/*@subtaskcode UDD_TASK_CODE*/
AS
BEGIN
SET NOCOUNT ON
	SELECT @ilbocode = LTRIM(RTRIM(@ilbocode))
	SELECT @description = LTRIM(RTRIM(@description))
	SELECT @taskcode = LTRIM(RTRIM(@taskcode))
	/*SELECT @subtaskcode = LTRIM(RTRIM(@subtaskcode))*/
	SELECT @activityname = LTRIM(RTRIM(@activityname))

	DECLARE @process_name 	ENGG_NAME
	DECLARE @component_name engg_name
	
	-- Added by VR - SoftRB2cut1.0S_000264.
	IF @ilbocode ='%'
 	   SELECT @ilbocode = ''

	IF @description = '%'
	   SELECT @description = ''

	IF @taskcode = '%'
	  SELECT @taskcode = ''

	IF @activityname = '%'
           SELECT @activityname = ''

	-- Added by VR - SoftRB2cut1.0S_000264.

	IF @ilbocode = ''
	BEGIN
		SELECT @M_ERRORID = 142        /*ilbocode can not be empty*/
		RETURN
	END


	IF @description = ''
	BEGIN
		SELECT @M_ERRORID = 110     /* Description can not be empty*/
		RETURN
	END

	IF @activityname = ''
	BEGIN
		SELECT @M_ERRORID = 98   /* Activity Name is mandatory */
		RETURN
	END
	

/*	DECLARE	@ActivityId UDD_SEQUENCE_NO*/

	IF NOT EXISTS(SELECT 'x' FROM #fw_req_activity_ilbo WHERE activityid = @activityid and ilbocode = @ilbocode)
	BEGIN
		SELECT @M_ERRORID = 112 	/*Activity id does not exist for this ilbo*/
		RETURN
	END

	IF NOT EXISTS(SELECT 'x' FROM #fw_req_ilbo WHERE ilbocode =  @ilbocode)
	BEGIN
		SELECT @M_ERRORID = 146	/*ILBO not mapped to app,bo*/
		RETURN
	END
	-- Added by Vidya Rajagopalan 17/02/2000
	IF @TaskCode <> ''
	BEGIN
		-- 22/03/2000
		IF EXISTS(SELECT 'x' from #fw_req_task
			  WHERE TaskName = @TaskCode
	   		  AND UPPER(LTRIM(RTRIM(TaskType))) <> 'FETCH'
		    	  )
		BEGIN
			-- Task %1 can be of fetch type only
			SELECT @M_ErrorId = 772
			RETURN 
		END 	
		-- End of add - Vidya Rajagopalan 22/03/2000


		IF NOT EXISTS(SELECT 'x' FROM #fw_req_activity_task WHERE activityid = @ActivityId AND taskname = @taskcode)
		BEGIN
			SELECT @M_ERRORID = 1330 /*Task code is not defined for the Activity Id*/
			RETURN
		END
	END 

	/*Addition over*/
	-- Changed by Vidya Rajagopalan 17/02/2000
	DECLARE @LinkIdCount    int

	SELECT @LinkIdCount = 0	

	--IF EXISTS(SELECT 'x' FROM #fw_req_ilbo_link_publish WHERE ilbocode = @ilbocode)
	--BEGIN
		--Link ID should be unique across ILBOs.  Modified by PR on 24 Dec 1999.
		SELECT @LinkIdCount = ISNULL(MAX(LinkID), 0) FROM #fw_req_ilbo_link_publish
	--END
	-- Code for Defect No. rvw_1.2_214[FCSG][TECHRACK04] - Srini - 19-10-2001
	IF EXISTS(SELECT 'X' FROM #fw_req_ilbo_link_publish 
		  WHERE description=@description)
	BEGIN
		SELECT @M_Errorid=3083
		RETURN
	END
	-- End of Code for Defect No. rvw_1.2_214[FCSG][TECHRACK04]
        INSERT INTO #fw_req_ilbo_link_publish (ilbocode,linkid,description,taskname,ActivityId,UpdUser,UpdTime)
        VALUES(@ilbocode,@LinkIdCount+1,@description,@taskcode,@ActivityId,@UpdUser,getdate()/*@subtaskcode*/)
	

        INSERT INTO #fw_req_ilbo_link_local_info (ilbocode,linkid,langid,description,UpdUser,updtime)
        VALUES (@ilbocode,@LinkIdCount+1,1,@description,@UpdUser,getdate())

	--Link ID should be unique across ILBOs. Modified by PR on 24 Dec 1999.
       -- SELECT linkid=MAX(LinkID) FROM #fw_req_ilbo_link_publish
		SET NOCOUNT OFF
END




