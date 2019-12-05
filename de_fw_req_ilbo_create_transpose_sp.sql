/************************************************************************************
procedure name and id    de_fw_req_ilbo_create_transpose_sp
description
name of the author       Karthikeyan V. S
date created             19 Jan 2006
modifications history
modified by
modified date
modified purpose
*************************************************************************************/
/* modified by  : Ramachandran T                                                 */
/* date         : 05/06/2008                                               */
/* Bug ID    : PNR2.0_18144              */
/* description : Transposed View Added to Zoom ILBO Pages Title      */
/************************************************************************************/
/* modified by  : Karthikeyan V S                                             */
/* date         : 10/Aug/2009                                              */
/* Bug ID    : PNR2.0_23218              */
/* description : Generation failed due to zoom control entry missing      */
/************************************************************************************/
/* modified by  : Kiruthika R                                            */
/* date         : 7/FEB/2011                                              */
/* Bug ID    : PNR2.0_29888              */
/* description : Generation failed due to page prefix duplication      */
/************************************************************************************/
/* modified by  : Kiruthika R                                              */
/* date         : 28/FEB/2011                                              */
/* Bug ID    : PNR2.0_30361              */
/* description : Generation failed due to page prefix duplication       */
/************************************************************************************/
alter PROCEDURE de_fw_req_ilbo_create_transpose_sp(
@ActivityID  engg_seqno,
@ActivityName engg_name,
@ILBOCode  engg_name,
@ControlID  engg_control_id,
@ecrno    engg_name ,
/* Code Modified for the Case ID:PNR2.0_30361 By Kiruthika R */
@NewILBOCode  engg_name OUTPUT )--,@Platform engg_name = 'Dotnet')--Modification made by Kiruthika R for budg id:PNR2.0_29888
/* Code Modified for the Case ID:PNR2.0_30361 By Kiruthika R */
AS

BEGIN
DECLARE @NewControlID  engg_control_id
DECLARE @NewCtrl   engg_control_id
DECLARE @ViewName   engg_name
DECLARE @View    engg_name
DECLARE @ChkView   engg_name
DECLARE @HiddenView  engg_name
DECLARE @NewViewName  engg_name
DECLARE @DispLen   engg_flag
DECLARE @DispFlg   engg_flag
DECLARE @BTSynonym   engg_name
DECLARE @AssocLbl   engg_description
DECLARE @Desc    engg_description
DECLARE @PLText   engg_description
DECLARE @Enabled   engg_description
DECLARE @visible   engg_description
DECLARE @M_ErrorId   int
DECLARE @Link   engg_seqno
DECLARE @NewTaskName  engg_name
DECLARE @CtrlType   engg_name
DECLARE @DispCtrlType  engg_name
DECLARE @Seq    int

DECLARE @OnStateValue  engg_description
DECLARE @OffStateValue  engg_description

DECLARE @tmptskname  engg_name
DECLARE @tmptskdesc  engg_description
DECLARE @tmptsktype  engg_type

DECLARE @PagePrefix  engg_name
DECLARE @ControlPrefix engg_name
DECLARE @CompPrefix  engg_name


DECLARE @ilbodesc  engg_name
declare @temilbo  varchar(13) --Code Added by krishnamoorthy.S for caseid:MSRVW_1.4.3+MNT_839
declare @compName  engg_name --Code Added by krishnamoorthy.S for caseid:MSRVW_1.4.3+MNT_839
--Modification made by Kiruthika R for budg id:PNR2.0_29888 starts
declare @zoom  engg_flag

select @zoom ='n'
/* Code Modified for the Case ID:PNR2.0_30361 By Kiruthika R */
--if @Platform = 'Dotnet'
--begin
select @zoom = isnull(parametervalue,'n')
from  eng_devcon_ecrconfig(nolock)
where parametername ='zoom'
--end
--Modification made by Kiruthika R for budg id:PNR2.0_29888 ends
/* Code Modified for the Case ID:PNR2.0_30361 By kiruthika R */
SELECT  @ilbodesc = description
from #fw_req_ilbo (nolock)
where  ilbocode = @ILBOCode
--- Addition Ends here

---- Generate ilbocode for the Transpose
--select 'controlid ' + @ControlID
-- Code Added by D. Michael Antony Begins for Case Id : MSRVW_1.4.3+MNT_22
IF NOT EXISTS (SELECT  ViewName FROM  #fw_req_ilbo_view (nolock)
WHERE   ilbocode = @ILBOCode AND
controlid = @ControlID AND
BTSynonym NOT IN ('modeflag'))
BEGIN
--Select 'No records selected'
RETURN 2;
END
-- Code Added by D. Michael Antony Ends for Case Id : MSRVW_1.4.3+MNT_22
--Code Commented by krishnamoorthy.S for caseid:MSRVW_1.4.3+MNT_839
/*
SELECT
@Seq = convert(integer, ParamValue)
FROM
#fw_req_system_parameters
WHERE
ParamName = 'ZoomILBOSeqNo'
*/

--SELECT @NewILBOCode = 'ZoomILBO' + convert(nvarchar, @Seq + 1)
--End of Code Commented by krishnamoorthy.S for caseid:MSRVW_1.4.3+MNT_839
--Code Added by krishnamoorthy.S for caseid:MSRVW_1.4.3+MNT_839

--code commented for bug id : PNR2.0_23218 ***start***
/*
SELECT  @PagePrefix  = A.page_prefix ,
@ControlPrefix = B.Control_prefix,
@CompPrefix  = C.current_value
FROM de_ui_page A (NOLOCK),
de_ui_control B (NOLOCK),
es_comp_param_mst_vw c (Nolock)
WHERE  A.activity_name = @ActivityName
AND  A.ui_name    = @ILBOCode
AND   B.Component_name= A.Component_name
AND  B.activity_name = A.activity_name
AND  B.ui_name    = A.ui_name
AND  B.Control_ID = @ControlID
AND   C.Component_name= B.Component_name
and  B.page_bt_synonym= a.page_bt_synonym
AND  C.param_category= 'COMPPREFIX'
*/
--code commented for bug id : PNR2.0_23218 ***end***

--code Added for bug id : PNR2.0_23218 ***start***
SELECT @PagePrefix  = A.page_prefix ,
@ControlPrefix = B.Control_prefix,
@CompPrefix  = C.current_value
FROM de_published_ui_page_vw A (NOLOCK),
de_published_ui_control_vw B (NOLOCK),
es_comp_param_mst_vw c (Nolock)
WHERE A.activity_name = @ActivityName
AND  A.ui_name  = @ILBOCode
AND  A.ecrno   = @ecrno
AND  b.customer_name = A.customer_name
AND  b.project_name = A.project_name
AND  b.process_name = A.process_name
AND  B.Component_name= A.Component_name
AND  b.ecrno   = A.ecrno
AND  B.activity_name = A.activity_name
AND  B.ui_name  = A.ui_name
AND  B.Control_ID = @ControlID
AND  C.Component_name= B.Component_name
and  B.page_bt_synonym= a.page_bt_synonym
AND  C.param_category= 'COMPPREFIX'
--code Added for bug id : PNR2.0_23218  ***end***
--Code Modified by Kiruthika R for bug id:PNR2.0_29888 starts
/* Code Modified for the Case ID:PNR2.0_30361 By Kiruthika R starts */
--If (@Platform ='Java' or @zoom ='y')
If (@zoom ='y') or (select count(*) from de_published_ui_page_vw (nolock) 
						  where ecrno = @ecrno
						  and   page_prefix = @PagePrefix  )>1
/* Code Modified for the Case ID:PNR2.0_30361 By Kiruthika R  end*/
begin

SELECT @PagePrefix    = page_prefix
FROM   de_published_ui_page_vw(nolock)
WHERE  activity_name   = @ActivityName
AND    ui_name     = @ILBOCode
AND    ecrno        = @ecrno
AND    page_bt_synonym = '[mainscreen]'
end
--Code Modified by Kiruthika R for bug id:PNR2.0_29888 ends


set @temilbo=''
select @compName=ComponentName from  #fw_req_activity (nolock) where Activityid=@ActivityID

IF EXISTS(SELECT 'X' FROM #fw_req_ILBO_Transpose (nolock) WHERE ComponentName=@compName and ActivityName=@ActivityName and ILBOCode =@ILBOCode and ControlID=@ControlID)
BEGIN
SELECT @temilbo=ZoomName from #fw_req_ILBO_Transpose WHERE ComponentName=@compName and ActivityName=@ActivityName and ILBOCODE =@ILBOCode and ControlID=@ControlID
--SELECT @NewILBOCode = 'Zoom_' + @ILBOCode + '_' + @temilbo
--SELECT @NewILBOCode = 'Zoom_' + @CompPrefix + '_' + @PagePrefix + '_' + @ControlPrefix
SELECT @NewILBOCode = 'Z' + @CompPrefix  + @PagePrefix + @ControlPrefix
END
ELSE
BEGIN
SELECT @temilbo=max(convert(int,ZoomName)) from #fw_req_ILBO_Transpose (nolock) WHERE Version='1.4.3'
IF @temilbo is NULL
BEGIN
SET @temilbo = 1
insert into #fw_req_ILBO_Transpose
(ComponentName,ActivityName,ILBOCode,ControlID,ZoomName,Version)
values
(@compName,@ActivityName,@ILBOCode,@ControlID,@temilbo,'1.4.3')
--SELECT @NewILBOCode = 'Zoom_' + @ILBOCode + '_' + @temilbo
--SELECT @NewILBOCode = 'Zoom_' + @CompPrefix + '_' + @PagePrefix + '_' + @ControlPrefix
SELECT @NewILBOCode = 'Z' + @CompPrefix + @PagePrefix + @ControlPrefix

END
ELSE
BEGIN
SELECT @temilbo=@temilbo + 1

insert into #fw_req_ILBO_Transpose
(ComponentName,ActivityName,ILBOCode,ControlID,ZoomName,Version)
values
(@compName,@ActivityName,@ILBOCode,@ControlID,@temilbo,'1.4.3')

--   SELECT @NewILBOCode = 'Zoom_' + @ILBOCode + '_' + @temilbo
--SELECT @NewILBOCode = 'Zoom_' + @CompPrefix + '_' + @PagePrefix + '_' + @ControlPrefix
SELECT @NewILBOCode = 'Z' + @CompPrefix + @PagePrefix + @ControlPrefix
END
END
--End of Code Added by krishnamoorthy.S for caseid:MSRVW_1.4.3+MNT_839
-- Update the System parameters table with the generated sequence number

UPDATE
#fw_req_system_parameters
SET
ParamValue = convert(nvarchar, @Seq + 1)
WHERE
ParamName = 'ZoomILBOSeqNo'

SET @Seq = 0

/* INSERT THE NEW TRANSPOSE ILBO FOR THE ACTIVITY */

INSERT INTO
#fw_req_ilbo
(ILBOCode, description, StatusFlag, ILBOType, upduser, updtime)
VALUES

-- Commented & Added By Balaji R for case id :MSRVW_1.4.3+MNT_319   starts here
/*(@NewILBOCode, 'Transposed View of ' + @ControlID, 0, 9, user, getdate())*/
(@NewILBOCode, 'Transposed View of ' + @ilbodesc, 0, 9, user, getdate())
-- Commented & Added By Balaji R for case id :MSRVW_1.4.3+MNT_319   ends here


--Defect Id:RVW_1.3_76 Chaina on 24 Jan 2002
INSERT INTO #fw_req_ilbo_local_info
(Ilbocode, Langid, Description, HelpIndex, UpdUser,UpdTime)
select @NewILBOCode, Langid, Description, HelpIndex, UpdUser,UpdTime
from #fw_req_ilbo_local_info a (nolock)
where  ilbocode = @ILBOCode
and  not
exists ( select '*' from #fw_req_ilbo_local_info (nolock)
where  ilbocode  = @NewILBOCode
and  Langid  = a.Langid)

-- Fix for bug id : PNR2.0_18144 starts
Update #fw_req_ilbo_local_info
set  Description = 'Transposed View of ' + @ilbodesc
where Ilbocode = @NewILBOCode
-- Fix for bug id : PNR2.0_18144 ends

-- Commented & Added By Balaji R for case id :MSRVW_1.4.3+MNT_319   starts here
/*VALUES(@NewILBOCode, 1, 'Transposed View of ' + @ControlID, NULL, user, getDate())*/
--VALUES(@NewILBOCode, 1, 'Transposed View of ' + @ilbodesc, NULL, user, getDate())
-- Commented & Added By Balaji R for case id :MSRVW_1.4.3+MNT_319   ends here
--End of RVW_1.3_76

------------------------------
INSERT INTO
#fw_req_activity_ilbo
(ActivityId, ILBOCode, upduser, updtime)
VALUES
(@ActivityID, @NewILBOCode, user, getdate())



/* INSERT CONTROL INFO FOR THE NEW TRANSPOSE ILBO */

-- DECLARE a cursor which stores all the columns in a multiline including the hidden views
DECLARE
views_cursor
CURSOR FOR
SELECT
ViewName, DisplayFlag, DisplayLength, BTSynonym
FROM
#fw_req_ilbo_view (nolock)
WHERE
ilbocode = @ILBOCode AND
controlid = @ControlID AND
BTSynonym NOT IN ('modeflag')
ORDER BY
ControlID, convert(int, ViewName)
FOR READ ONLY

OPEN views_cursor


FETCH NEXT FROM
views_cursor
INTO
@ViewName, @DispFlg, @DispLen, @BTSynonym


-- For each multiline column do the following

WHILE @@FETCH_STATUS = 0
BEGIN
-- each multiline column becomes a header control in the transpose
-- hence get the type of the multiline column and create a control
-- of that type in the #fw_req_ilbo_control table

--Defect Id: RVW_1.3_77. Modification start... chaina on 23 Jan 2002.
-- It should check the existency of the ilbo for the specified activityid.
--and that has been taken care in Chk_if_Trans_exists_tmp procedure.

/*IF EXISTS (SELECT 'x'
FROM
#fw_req_ilbo_data_use a,
#fw_req_ilbo b
WHERE
a.parentilbocode = @ILBOCode
and a.controlid = @ControlID
and b.ilbocode = a.childilbocode
and b.ilbotype = '9')
BEGIN
RETURN
END
*/

-- Modified by Muthunagaswamy.R for RVW_1.4.2_15 on 13th August 2002
SET @CtrlType = null
-- Modification Ends for RVW_1.4.2_15

SELECT
@CtrlType = Value
FROM
#fw_req_ilbo_control_property (nolock)
WHERE
ILBOCode = @ILBOCode
AND ControlID = @ControlID
AND PropertyName = 'ColumnType'
AND ViewName = @ViewName

SET @DispCtrlType = 'NULL'

-- Frame the new controlid and ViewNames for the transpose ilbo
SELECT
@NewControlID = 'c' + @ViewName

SELECT
@NewViewName = 'v' + @ViewName

IF (LOWER(@CtrlType) = 'editbox')
BEGIN
SELECT @CtrlType = 'RSEditCtrl'
END

IF (LOWER(@CtrlType) = 'combobox')
BEGIN
SELECT @CtrlType = 'RSComboCtrl'
END

IF (LOWER(@CtrlType) = 'checkbox')
BEGIN
SELECT @CtrlType = 'RSCheck'
END

IF (LOWER(@CtrlType) = 'displayonly')
BEGIN
SELECT @CtrlType = 'RSEditCtrl'
SELECT @DispCtrlType = 'displayonly'
END

IF (@DispFlg <> 'F' )
BEGIN

-- Insert the new values got for the transpose into #fw_req_ilbo_control
INSERT INTO
#fw_req_ilbo_control
(ilbocode, ControlID, Type, UpdUser, UpdTime)
VALUES
(@NewILBOCode, @NewControlID, @CtrlType, user, getdate())

-- Insert view details for the new control into #fw_req_ilbo_view
INSERT INTO
#fw_req_ilbo_view
(ilbocode, ControlID, ViewName, DisplayFlag, DisplayLength,
BTSynonym, UpdUser, UpdTime)
VALUES
(@NewILBOCode, @NewControlID, @NewViewName, @DispFlg, @DispLen,
@BTSynonym, user, getdate())





-- Each Control in the Transpose inherits the properties from the corresponding
-- multiline columns. Hence those details should be inserted in
-- #fw_req_ilbo_control_property table

-- Insert the corresponding Labels of the new controls inserted.
-- (No labels for hidden views.)
INSERT INTO
#fw_req_ilbo_control
(ilbocode, ControlID, Type, UpdUser, UpdTime)
VALUES
(@NewILBOCode, 'lbl' + @NewControlID, 'Label', user, getdate())

-- Get the PL Text
SELECT
@PLText = Value
FROM
#fw_req_ilbo_control_property (nolock)
WHERE
ILBOCode = @ILBOCode
AND ControlID = @ControlID
AND ViewName = @ViewName
AND PropertyName = 'PL Text'

-- insert the property values obtained from the parent ilbo for the transpose ilbo
INSERT INTO
#fw_req_ilbo_control_property
(ilbocode, ControlID, ViewName, PropertyName,
Type, Value, UpdUser, UpdTime)
VALUES
(@NewILBOCode, @NewControlID, @NewViewName, 'PL Text',
'Marshal', @PLText, user, getdate())

-- insert tabindex based on view
INSERT INTO
#fw_req_ilbo_control_property
(ilbocode, ControlID, ViewName, PropertyName,
Type, Value, UpdUser, UpdTime)
VALUES
(@NewILBOCode, @NewControlID, @NewControlID, 'TabIndex',
'Marshal', @ViewName, user, getdate())

-- associate the label generated with the corresponding control by
-- populating an entry for that in control property table
SET @AssocLbl = 'lbl' + @NewControlID

INSERT INTO
#fw_req_ilbo_control_property
(ilbocode, ControlID, ViewName, PropertyName,
Type, Value, UpdUser, UpdTime)
VALUES
(@NewILBOCode, @NewControlID, @NewViewName, 'Associated Label',
'Marshal', @AssocLbl, user, getdate())

-- Code added by Charu on 17th April 2002 to handle CheckBox Properties
-- Off State and On State values

SET @OnStateValue = 'NULL'
SELECT
@OnStateValue = Value
FROM
#fw_req_ilbo_control_property (nolock)
WHERE
ILBOCode = @ILBOCode
and ControlID = @ControlID
and ViewName = @ViewName
and LOWER(PropertyName) = 'on state value'

IF (@OnStateValue <> 'NULL')
BEGIN
INSERT INTO
#fw_req_ilbo_control_property
(ilbocode, ControlID, ViewName, PropertyName,
Type, Value, UpdUser, UpdTime)
VALUES
(@NewILBOCode, @NewControlID, @NewViewName, 'On State Value',
'Marshal', @OnStateValue, user, getdate())

END

SET @OffStateValue = 'NULL'
SELECT
@OffStateValue = Value
FROM
#fw_req_ilbo_control_property (nolock)
WHERE
ILBOCode = @ILBOCode
and ControlID = @ControlID
and ViewName = @ViewName
and LOWER(PropertyName) = 'off state value'

IF (@OffStateValue <> 'NULL')
BEGIN
INSERT INTO
#fw_req_ilbo_control_property
(ilbocode, ControlID, ViewName, PropertyName,
Type, Value, UpdUser, UpdTime)
VALUES
(@NewILBOCode, @NewControlID, @NewViewName, 'Off State Value',
'Marshal', @OffStateValue, user, getdate())

END
-- End of code added by Charu on 17th April 2002 to handle CheckBox Properties

-- Properties for hidden and display only ctrls
SET @Visible = 'NULL'
SELECT
@Visible = Value
FROM
#fw_req_ilbo_control_property (nolock)
WHERE
ILBOCode = @ILBOCode
AND ControlID = @ControlID
AND PropertyName = 'Visible'

IF (@Visible <> 'NULL')
BEGIN

INSERT INTO
#fw_req_ilbo_control_property
(ilbocode, ControlID, ViewName, PropertyName,
Type, Value, UpdUser, UpdTime)
VALUES
/*  Modified by Madusudanan R, 28 Dec 2001,
Problem in generation of data based hyperlinks in snapshots.
For compatibility with ASPs generated with ASPGenerator,
these properties need to be at view level

(@NewILBOCode, @NewControlID, @NewControlID, 'Visible',
'Marshal', @Visible, user, getdate())
*/
(@NewILBOCode, @NewControlID, @NewViewName, 'Visible',
'Marshal', @Visible, user, getdate())
END

-- Display only control is an edit control with Enabled property set to false!
IF (@DispCtrlType <> 'NULL')
BEGIN
INSERT INTO
#fw_req_ilbo_control_property
(ilbocode, ControlID, ViewName, PropertyName,
Type, Value, UpdUser, UpdTime)
VALUES
/*  Modified by Madusudanan R, 28 Dec 2001,
Problem in generation of data based hyperlinks in snapshots.
For compatibility with ASPs generated with ASPGenerator,
these properties need to be at view level
(@NewILBOCode, @NewControlID, @NewControlID, 'Enabled',
'Marshal', 'false', user, getdate())
*/
(@NewILBOCode, @NewControlID, @NewViewName, 'Enabled',
'Marshal', 'false', user, getdate())
--  Modification ENDS

END

END  /* hidden view fields need no properties */
ELSE /* DisplayFlag is False which means its a hidden view */
BEGIN
-- Special case to handle hidden views in combo and normal hidden views
-- in a different manner!
IF (@CtrlType = 'RSComboCtrl') OR (@CtrlType = 'RSCheck')
BEGIN
-- get the linked combo view value to get the view name of the control
-- for which we need to add a hidden view
SET @View = 'NULL'
SET @ChkView = 'NULL'
SELECT
@View = Value
FROM
#fw_req_ilbo_control_property (nolock)
WHERE
ILBOCode = @ILBOCode
and ControlID = @ControlID
and ViewName = @ViewName
and PropertyName = 'LinkedComboView'
SELECT
@ChkView = Value
FROM
#fw_req_ilbo_control_property (nolock)
WHERE
ILBOCode = @ILBOCode
and ControlID = @ControlID
and ViewName = @ViewName
and PropertyName = 'LinkedCheckView'

--  @View = Visible viewname the other is hidden viewname
--  frame the controlid using the value
-- For LinkedComboView
IF (@View <> 'NULL')
BEGIN
SELECT
@NewCtrl = 'c' + @View
END

-- For LinkedCheckView
IF (@ChkView <> 'NULL')
BEGIN
SELECT
@NewCtrl = 'c' + @ChkView
END

-- frame to view name too!! This is the only case where
-- the controlid and the view name are different!
SELECT
@HiddenView = 'v' + @ViewName

--select ILBOCode = @NewILBOCode, Ctrl = @NewCtrl, ViewName = @HiddenView

-- Insert the new values to the view table.
-- So we are jus adding a view name for the hidden combo view
-- and not another control for that!
INSERT INTO
#fw_req_ilbo_view
(ilbocode, ControlID, ViewName, DisplayFlag, DisplayLength,
BTSynonym, UpdUser, UpdTime)
VALUES
(@NewILBOCode, @NewCtrl, @HiddenView, 'F', @DispLen,
@BTSynonym, user, getdate())

END

-- for hidden views otherthan those for combo
IF (@CtrlType = 'RSEditCtrl')
BEGIN
-- Insert the new values got for the transpose into #fw_req_ilbo_control
INSERT INTO
#fw_req_ilbo_control
(ilbocode, ControlID, Type, UpdUser, UpdTime)
VALUES
(@NewILBOCode, @NewControlID, @CtrlType, user, getdate())

-- Insert view details for the new control into #fw_req_ilbo_view
INSERT INTO
#fw_req_ilbo_view
(ilbocode, ControlID, ViewName, DisplayFlag, DisplayLength,
BTSynonym, UpdUser, UpdTime)
VALUES
(@NewILBOCode, @NewControlID, @NewViewName, @DispFlg, @DispLen,
@BTSynonym, user, getdate())
INSERT INTO
#fw_req_ilbo_control_property
(ilbocode, ControlID, ViewName, PropertyName,
Type, Value, UpdUser, UpdTime)
VALUES
/*  Modified by Madusudanan R, 28 Dec 2001,
Problem in generation of data based hyperlinks in snapshots.
For compatibility with ASPs generated with ASPGenerator,
these properties need to be at view level

(@NewILBOCode, @NewControlID, @NewControlID, 'Visible',
'Marshal', 'False', user, getdate())
*/
(@NewILBOCode, @NewControlID, @NewViewName, 'Visible',
'Marshal', 'False', user, getdate())
--  Modification ENDS
END

/* Code Added By Balaji R for case id: MSRVW_1.4.3+MNT_325  starts here */

/* Convert all the hidden views in the multiline to hidden controls in transpose ilbo */
IF (@CtrlType IS NULL)
BEGIN

-- Insert the new values got for the transpose into #fw_req_ilbo_control
INSERT INTO #fw_req_ilbo_control(ilbocode, ControlID, Type, UpdUser, UpdTime)
VALUES
(@NewILBOCode, @NewControlID, 'RSEditCtrl', user, getdate())



-- Insert view details for the new control into #fw_req_ilbo_view
INSERT INTO #fw_req_ilbo_view
(ilbocode, ControlID, ViewName, DisplayFlag, DisplayLength, BTSynonym, UpdUser, UpdTime)
VALUES

--Modified by Tilak for CaseID : RVW_JAVA143P_MNT_50

--@NewILBOCode, @NewControlID, @NewViewName, @DispFlg, @DispLen,@BTSynonym, user, getdate())

(@NewILBOCode, @NewControlID, @NewViewName, 'T', @DispLen,@BTSynonym, user, getdate())



INSERT INTO #fw_req_ilbo_control_property
(ilbocode, ControlID, ViewName, PropertyName,Type, Value, UpdUser, UpdTime)
VALUES
(@NewILBOCode, @NewControlID, @NewViewName, 'Visible','Marshal', 'False', user, getdate())

END

/* Code Added By Balaji R for case id: MSRVW_1.4.3+MNT_325  Ends here */




/* Modified by Muthunagaswamy.R to support the generation of DHL
on the zoom page */
IF EXISTS (SELECT 'x' FROM #fw_req_ilbo_data_use (nolock) WHERE
parentilbocode = @ILBOCode and
ControlID = @ControlID and
ViewName = @ViewName and
PrimaryData = 'Y')
BEGIN
INSERT INTO
#fw_req_ilbo_data_use
(parentilbocode, childilbocode, LinkID,
TaskName, DataItemName, FlowType,
IsControl,ControlID, ViewName, ControlVariableName,
RetrieveMultiple, UpdUser, UpdTime, PrimaryData)
SELECT
@NewILBOCode, childilbocode, LinkID,
TaskName, DataItemName,FlowType,Iscontrol,
@ControlID, @ViewName, ControlVariableName,
RetrieveMultiple, user, getdate(), 'Y'
FROM
#fw_req_ilbo_data_use (nolock)
WHERE
parentilbocode = @ILBOCode and
ControlID = @ControlID and
ViewName = @ViewName and
PrimaryData = 'Y'
END
/* Modification for DHL ends */

END

-- all for one set of data in the cursor...
-- now for the next set

FETCH NEXT FROM
views_cursor
INTO
@ViewName, @DispFlg, @DispLen, @BTSynonym
END

CLOSE views_cursor

/* PUBLISH NEW LINK TO ENABLE THE PARENT ILBO TO ACCESS THE TRANSPOSE ILBO */

-- Generate TaskName for the Transpose

SELECT
@Seq = convert(integer, ParamValue)
FROM
#fw_req_system_parameters (nolock)
WHERE
ParamName = 'ZoomTaskSeqNo'

--SELECT @NewTaskName = 'tskZoom' + convert(nvarchar, @Seq + 1)
SELECT @NewTaskName = 'tskZoom' + @PagePrefix + @ControlPrefix

-- Update the System parameters table with the generated sequence number

UPDATE
#fw_req_system_parameters
SET
ParamValue = convert(nvarchar, @Seq + 1)
WHERE
ParamName = 'ZoomTaskSeqNo'

SET @Seq = 0

-- create new task for the parent ilbo to enable subscribing to transpose
INSERT INTO
#fw_req_task
(TaskName, TaskType, TaskDesc,
UpdUser, UpdTime)
VALUES
(@NewTaskName, 'Zoom', 'Show Snapshot of ' + @ControlID,
user, getdate())

-- Code Added for MSRVW_1.4.3+MNT_249 by Balaji R Begins here
INSERT INTO
#fw_req_task_local_info
(TaskName, Langid, Description, HelpIndex,
UpdUser, UpdTime)
VALUES
(@NewTaskName, 1, 'Show Snapshot of ' + @ControlID, '0',
user, getdate())
-- Code Added for MSRVW_1.4.3+MNT_249 by Balaji R Ends here


-- Associate the task to the activity
SELECT
@seq = MAX(TaskSequence)+1
FROM
#fw_req_activity_task (nolock)
WHERE
activityid = @ActivityID

INSERT INTO
#fw_req_activity_task
(ActivityId, TaskName, InvocationType, TaskSequence,
UpdUser, UpdTime)
VALUES
(@ActivityID, @NewTaskName, 1, @Seq,
user, getdate())


-- Associate the task to the ilbo
--Changes for RVW_1.4_145 by Anitha Begin
/*INSERT INTO
#fw_req_activity_ilbo_task
(ActivityID, ILBOCode, TaskName,
UpdUser, UpdTime)
VALUES
(@ActivityID, @ILBOCode, @NewTaskName,
user, getdate())*/
INSERT INTO
#fw_req_activity_ilbo_task
(ActivityID, ILBOCode, TaskName,
UpdUser, UpdTime, DataSavingTask, LinkType)
VALUES
(@ActivityID, @ILBOCode, @NewTaskName,
user, getdate(), 0, 4)
--Changes for RVW_1.4_145 by Anitha End

SELECT @Desc = 'Link for ' + @NewILBOCode
-- publish a link
exec de_fw_req_ui_ilbo_Publink_ins @NewILBOCode, @Desc, '',
@ActivityName, @ActivityID, '', @M_ErrorId OUTPUT

--Check this
--select @M_ErrorId

-- Code added by D. Michael Antony begins

-- if @M_ErrorId is not null
--  return 2

-- Code added by D. Michael Antony ends

-- get the new link id
SELECT
@Link = LinkID
FROM
#fw_req_ilbo_link_publish (nolock)
WHERE
ILBOCode = @NewILBOCode
AND ActivityID = @ActivityID

--select @Link

/* PARENT ILBO TO SUBSCRIBE FOR THE LINK PUBLISHED BY THE TRANSPOSE ILBO */
-- Subscribe for the link published by the transpose ilbo
EXEC  de_fw_req_ui_ilbo_lnkuse_insupd
@ILBOCode, @NewILBOCode, @Link, @NewTaskName,
@M_ErrorID output, ''
--check this
-- Once again open views for the new link data population

OPEN views_cursor

FETCH NEXT FROM
views_cursor
INTO
@ViewName, @DispFlg, @DispLen, @BTSynonym

WHILE @@FETCH_STATUS = 0
BEGIN

SET @View = 'NULL'
SET @ChkView = 'NULL'

-- Frame the new controlid for the transpose ilbo
SELECT
@NewControlID = 'c' + @ViewName
SELECT
@NewViewName = 'v' + @ViewName

/* CREATE NEW LINK TO ENABLE THE PARENT ILBO TO ACCESS THE TRANSPOSE ILBO */

-- transpose ilbo publishes data items for the parent ilbo to use them


SELECT
@CtrlType = Value
FROM
#fw_req_ilbo_control_property (nolock)
WHERE
ILBOCode = @ILBOCode
AND ControlID = @ControlID
AND PropertyName = 'ColumnType'
AND ViewName = @ViewName

--IF ((LOWER(@CtrlType) <> 'combobox') AND (@DispFlg <> 'F')) OR (
/* If the control is a combo and it has a hidden view also then we have to manipulate the
corresponding visible and hidden views for the same*/

IF (LOWER(@CtrlType) = 'combobox') OR (LOWER(@CtrlType) = 'checkbox')
BEGIN

SELECT
@View = Value
FROM
#fw_req_ilbo_control_property (nolock)
WHERE
ILBOCode = @ILBOCode
and ControlID = @ControlID
and ViewName = @ViewName
and PropertyName = 'LinkedComboView'

SELECT
@ChkView = Value
FROM
#fw_req_ilbo_control_property (nolock)
WHERE
ILBOCode = @ILBOCode
and ControlID = @ControlID
and ViewName = @ViewName
and PropertyName = 'LinkedCheckView'


-- For Combo Controls with hidden view
IF ((@View <> 'NULL') OR (@ChkView <> 'NULL')) AND (@DispFlg = 'F')
BEGIN
-- For Linked Combo View
IF (@View <> 'NULL')
BEGIN
SELECT
@NewControlID = 'c' + @View
END

-- For LinkedCheckView
IF (@ChkView <> 'NULL')
BEGIN
SELECT
@NewControlID = 'c' + @ChkView
END

SELECT
@HiddenView = 'v' + @ViewName

--select * from #fw_req_ilbo_view where ilbocode = @NewILBOCode
--select Link = @Link, NewILBO = @NewILBOCode, DIName = 'dtm' + @NewControlID, NewCtrl = @NewControlID, ViewName = @View
IF NOT EXISTS (SELECT 'x' FROM #fw_req_ilbo_data_publish (nolock)
WHERE LinkID = @Link
and ilbocode = @NewILBOCode
and DataItemName = 'D' + @ViewName)
BEGIN
INSERT INTO
#fw_req_ilbo_data_publish
(LinkID, ilbocode, DataItemName, MandatoryFlag, FlowType,
IsControl, ControlID, ViewName, ControlVariableName,
HaveMultiple, UpdUser, UpdTime)
VALUES
(@Link, @NewILBOCode, 'D' + @ViewName, 0, 2,
1, @NewControlID, @HiddenView, null,
0, user, getdate())
END

-- parent ilbo subscribes for the dataitems published by the transpose ilbo
IF NOT EXISTS (SELECT 'x' FROM #fw_req_ilbo_data_use (nolock) WHERE
parentilbocode = @ILBOCode and
TaskName = @NewTaskName and
DataItemName = 'D' + @ViewName)
BEGIN
INSERT INTO
#fw_req_ilbo_data_use
(parentilbocode, childilbocode, LinkID,
TaskName, DataItemName, FlowType,
IsControl,ControlID, ViewName, ControlVariableName,
RetrieveMultiple, UpdUser, UpdTime, PrimaryData)
VALUES
(@ILBOCode, @NewILBOCode, @Link,
@NewTaskName, 'D' + @ViewName, 2,
1, @ControlID, @ViewName, null,
0, user, getdate(), 'N')
END
END

-- Combo without hidden views
IF ( (@DispFlg = 'T') AND
(
NOT EXISTS ( SELECT  'x'
FROM  #fw_req_ilbo_control_property (nolock)
WHERE  ilbocode = @IlboCode
AND controlid = @controlid
AND  propertyname IN ('linkedcomboview', 'linkedcheckview')
AND value = @viewName
)
)
)

BEGIN
--select Link = @Link, NewILBO = @NewILBOCode, DIName = 'dtm' + @NewControlID, NewCtrl = @NewControlID
IF NOT EXISTS (SELECT 'x' FROM #fw_req_ilbo_data_publish (nolock)
WHERE LinkID = @Link
and ilbocode = @NewILBOCode
and DataItemName = 'D' + @ViewName)
BEGIN
INSERT INTO
#fw_req_ilbo_data_publish
(LinkID, ilbocode, DataItemName, MandatoryFlag, FlowType,
IsControl, ControlID, ViewName, ControlVariableName,
HaveMultiple, UpdUser, UpdTime)
VALUES
(@Link, @NewILBOCode, 'D' + @ViewName, 0, 2,
1, @NewControlID, @NewViewName, null,
0, user, getdate())
END

-- parent ilbo subscribes for the dataitems published by the transpose ilbo

IF NOT EXISTS (SELECT 'x' FROM #fw_req_ilbo_data_use (nolock) WHERE
parentilbocode = @ILBOCode and
TaskName = @NewTaskName and
DataItemName = 'D' + @ViewName)
BEGIN
INSERT INTO
#fw_req_ilbo_data_use
(parentilbocode, childilbocode, LinkID,
TaskName, DataItemName, FlowType,
IsControl,ControlID, ViewName, ControlVariableName,
RetrieveMultiple, UpdUser, UpdTime, PrimaryData)
VALUES
(@ILBOCode, @NewILBOCode, @Link,
@NewTaskName, 'D' + @ViewName, 2,
1, @ControlID, @ViewName, null,
0, user, getdate(), 'N')
END

END

END

IF ((LOWER(@CtrlType) <> 'combobox') AND (LOWER(@CtrlType) <> 'checkbox'))
BEGIN

/* For all the controls other than combo handle it this way */

--select Link = @Link, NewILBO = @NewILBOCode, DIName = 'dtm' + @NewControlID, NewCtrl = @NewControlID
IF NOT EXISTS (SELECT 'x' FROM #fw_req_ilbo_data_publish (nolock)
WHERE LinkID = @Link
and ilbocode = @NewILBOCode
and DataItemName = 'D' + @ViewName)
BEGIN
INSERT INTO
#fw_req_ilbo_data_publish
(LinkID, ilbocode, DataItemName, MandatoryFlag, FlowType,
IsControl, ControlID, ViewName, ControlVariableName,
HaveMultiple, UpdUser, UpdTime)
VALUES
(@Link, @NewILBOCode, 'D' + @ViewName, 0, 2,
1, @NewControlID, @NewViewName, null,
0, user, getdate())
END

-- parent ilbo subscribes for the dataitems published by the transpose ilbo

IF NOT EXISTS (SELECT 'x' FROM #fw_req_ilbo_data_use (nolock) WHERE
parentilbocode = @ILBOCode and
TaskName = @NewTaskName and
DataItemName = 'D' + @ViewName)
BEGIN
INSERT INTO
#fw_req_ilbo_data_use
(parentilbocode, childilbocode, LinkID,
TaskName, DataItemName, FlowType,
IsControl,ControlID, ViewName, ControlVariableName,
RetrieveMultiple, UpdUser, UpdTime, PrimaryData)
VALUES
(@ILBOCode, @NewILBOCode, @Link,
@NewTaskName, 'D' + @ViewName, 2,
1, @ControlID, @ViewName, null,
0, user, getdate(), 'N')
END

END

--Commented By Tilak for CaseID : RVW_JAVA143P_MNT_50
/*
Code Added By Balaji R for the Case id:MSRVW_1.4.3+MNT_368 starts here



SELECT @tmptskname = NULL

SELECT @tmptskname = TaskName
FROM
#fw_req_ilbo_data_use
WHERE
parentilbocode = @ILBOCode and
ControlID = @ControlID and
ViewName = @ViewName and
PrimaryData = 'Y'

SELECT @tmptsktype = NULL,@tmptskdesc = NULL

SELECT @tmptsktype = TASKTYPE,@tmptskdesc = TASKDESC
FROM #fw_req_TASK
WHERE TASKNAME =ltrim(rtrim(@tmptskname))


--Code Added By Sainath on 14/05/2004
-- Generate TaskName for the Transpose

SELECT
@Seq = convert(integer, ParamValue)
FROM
#fw_req_system_parameters
WHERE
ParamName = 'ZoomTaskSeqNo'

SELECT @NewTaskName = 'tskZoom' + convert(nvarchar, @Seq + 1)

-- Update the System parameters table with the generated sequence number

UPDATE
#fw_req_system_parameters
SET
ParamValue = convert(nvarchar, @Seq + 1)
WHERE
ParamName = 'ZoomTaskSeqNo'

SET @Seq = 0

-- create new task for the parent ilbo to enable subscribing to transpose
INSERT INTO
#fw_req_task
(TaskName, TaskType, TaskDesc,
UpdUser, UpdTime)
VALUES
(@NewTaskName, @tmptsktype, 'Show Snapshot of ' + @ControlID,
user, getdate())

-- Code Added for MSRVW_1.4.3+MNT_249 by Balaji R Begins here
INSERT INTO
#fw_req_task_local_info
(TaskName, Langid, Description, HelpIndex,
UpdUser, UpdTime)
VALUES
(@NewTaskName, 1, 'Show Snapshot of ' + @ControlID, '0',
user, getdate())
-- Code Added for MSRVW_1.4.3+MNT_249 by Balaji R Ends here


-- Associate the task to the activity
SELECT
@seq = MAX(TaskSequence)+1
FROM
#fw_req_activity_task
WHERE
activityid = @ActivityID

INSERT INTO
#fw_req_activity_task
(ActivityId, TaskName, InvocationType, TaskSequence,
UpdUser, UpdTime)
VALUES
(@ActivityID, @NewTaskName, 1, @Seq,
user, getdate())


tmptskname = @NewTaskName
--End of chnages By Sainath on 14/05/2004




IF(  LTRIM(RTRIM(@tmptsktype)) = 'Help' ) OR ( LTRIM(RTRIM(@tmptsktype)) = 'Link' )
BEGIN

DECLARE @tmpzoomtaskname engg_name



SELECT    @Seq = convert(integer, ParamValue)
FROM      #fw_req_system_parameters
WHERE     ParamName = 'ZoomHelpSeqNo'

SELECT @tmpzoomtaskname = LTRIM(RTRIM(@tmptskname)) +  LTRIM(RTRIM(convert(nvarchar, @Seq + 1)))

-- Update the System parameters table with the generated sequence number

UPDATE     #fw_req_system_parameters
SET        ParamValue = convert(nvarchar, @Seq + 1)
WHERE      ParamName = 'ZoomHelpSeqNo'

SET @Seq = 0



INSERT INTO      #fw_req_task
(
TaskName, TaskType, TaskDesc,UpdUser, UpdTime
)
VALUES
(
@tmpzoomtaskname, @tmptsktype, @tmptskdesc,user, getdate()
)

-- Associate the task to the activity
SELECT   @seq = MAX(TaskSequence)+1
FROM     #fw_req_activity_task
WHERE    activityid = @ActivityID


INSERT INTO  #fw_req_activity_task
(
ActivityId, TaskName, InvocationType, TaskSequence,UpdUser, UpdTime)
VALUES
(
@ActivityID, @tmpzoomtaskname, 1, @Seq,user, getdate()
)


INSERT INTO #fw_req_task_local_info
(
TaskName, Langid, Description, HelpIndex,UpdUser, UpdTime)
VALUES
(
@tmpzoomtaskname, 1, @tmptskdesc, '0',  user, getdate()
)


INSERT INTO    #fw_req_activity_ilbo_task
(
ActivityId,Ilbocode,Taskname, UpdUser,UpdTime,DatasavingTask,LinkType
)
VALUES
(
@ActivityID,@NewILBOCode,@tmpzoomtaskname,user,getdate(),0,1
)


IF EXISTS ( SELECT 'X' FROM #FW_DES_ILBO_SERVICE_VIEW_DATAMAP
WHERE ILBOCODE = @ILBOCode
AND TASKNAME = @tmptskname
)
BEGIN
DECLARE @tmpservicename AS UDD_SERVICE_NAME
DECLARE @tmpisprepopulate AS UDD_TINY_NO

DECLARE @tmp_SegmentName AS UDD_SEGMENT_NAME
DECLARE @tmp_DataItemName AS engg_name
DECLARE @tmp_IsControl AS UDD_TINY_NO
DECLARE @tmp_ControlID AS engg_control_id
DECLARE @tmp_ViewName AS engg_name
DECLARE @tmp_VariableName AS engg_name


SELECT @tmpservicename = LTRIM(RTRIM(ServiceName))
FROM #FW_DES_ILBO_SERVICE_VIEW_DATAMAP
WHERE ILBOCODE = @ILBOCode
AND TASKNAME = @tmptskname


SELECT @tmpisprepopulate = LTRIM(RTRIM(IsPrepopulate))
FROM #FW_DES_ILBO_SERVICES
WHERE  ILBOCODE = @ILBOCode
AND  SERVICENAME = @tmpservicename


INSERT INTO
#FW_DES_ILBO_SERVICES
(
ILBOCode,ServiceName,IsPrepopulate,UpdUser,UpdTime
)
VALUES
(
@NewILBOCode,@tmpservicename,@tmpisprepopulate,user,getdate()
)


DECLARE datause_cursor CURSOR
FOR
SELECT SegmentName,DataItemName,IsControl,ControlID,ViewName,VariableName
FROM #FW_DES_ILBO_SERVICE_VIEW_DATAMAP
WHERE ilbocode = @ILBOCode
AND TASKNAME = @tmptskname


OPEN datause_cursor

FETCH NEXT
FROM datause_cursor
INTO @tmp_SegmentName,@tmp_DataItemName,@tmp_IsControl,@tmp_ControlID,@tmp_ViewName,@tmp_VariableName

WHILE ( @@FETCH_STATUS = 0 )
BEGIN

INSERT INTO #FW_DES_ILBO_SERVICE_VIEW_DATAMAP
(
ILBOCode,ServiceName,ActivityId,TaskName,SegmentName,DataItemName,IsControl,ControlID,ViewName,VariableName,UpdUser,UpdTime
)
VALUES
(
@NewILBOCode,@tmpservicename,@ActivityID,@tmpzoomtaskname,@tmp_SegmentName,@tmp_DataItemName,@tmp_IsControl,@tmp_ControlID,@tmp_ViewName,@tmp_VariableName,USER,GETDATE()
)

FETCH NEXT
FROM datause_cursor
INTO @tmp_SegmentName,@tmp_DataItemName,@tmp_IsControl,@tmp_ControlID,@tmp_ViewName,@tmp_VariableName
END

CLOSE  datause_cursor
DEALLOCATE datause_cursor



END


END


Code Added By Balaji R for the Case id:MSRVW_1.4.3+MNT_368 Ends here */
--End of comment : RVW_JAVA143P_MNT_50




-- all for one set of data in the cursor...
-- now for the next set

FETCH NEXT FROM
views_cursor
INTO
@ViewName, @DispFlg, @DispLen, @BTSynonym
END

CLOSE views_cursor

DEALLOCATE views_cursor

RETURN 3

END







