/************************************************************************************
procedure name and id   vw_netgen_activityschema_sp
name of the author      Kiruthika R
date created            
query file name         vw_netgen_activityschema_sp.sql
modifications history 
 Modified By: Jeya Latha K		Modified On: 04-Oct-2019	
 rsgrid added by Jeya for supporting Gantt & Calendar in controlid & View name result set
************************************************************************************/
Create PROC  vw_netgen_activityschema_sp @customer_name ENGG_NAME, 
                                       @project_name   ENGG_NAME, 
                                       @ecrno          ENGG_NAME, 
									   @component_name ENGG_NAME,
                                       @guid           ENGG_NAME 
AS 
  BEGIN 
      SET nocount ON 

      DECLARE @ActivityID    ENGG_SEQUENCE_NO, 
              @ActivityName  ENGG_ACTIVITY_NAME, 
              @ILBOCode      ENGG_ACTIVITY_NAME,
			  @Rtstate       ENGG_FLAG 

      /*Table to hold the selected ui list for codegeneration*/ 
      CREATE TABLE #ilbolist 
        ( 
           component_name VARCHAR(60) COLLATE sql_latin1_general_cp1_ci_as, 
           activity_name  VARCHAR(60) COLLATE sql_latin1_general_cp1_ci_as, 
           ilbocode       VARCHAR(60) COLLATE sql_latin1_general_cp1_ci_as 
        ) 

      INSERT INTO #ilbolist  (component_name,activity_name,ilbocode)
	    SELECT  distinct LOWER(LTRIM(RTRIM(a.componentname))),LOWER(LTRIM(RTRIM(b.activityname))),LOWER(LTRIM(RTRIM(b.ilbocode))) 
		FROM	engg_gen_deliverables   a(nolock), 
				de_fw_req_publish_activity_ilbo_vw_fn (@customer_name, @project_name, @ECRNo)  b
		WHERE  a.Guid           = @guid 
		AND    a.CustomerName   = @customer_name 
		AND    a.ProjectName    = @project_name 
		AND    a.ecrno          = @ECRNo 
		AND   isnull(a.ActivityChk,0) = 1 
		AND    a.ActivityName   = b.activityname  

		 SELECT  @Rtstate = 'n'

		 SELECT  @Rtstate = isnull(Rtstate,'n')
		 FROM   engg_devcon_codegen_comp_metadata(nolock)
		 WHERE  componentname = @component_name

		 


      /*haslegacystate*/
      UPDATE ilbo 
      SET    ilbo.haslegacystate = CASE WHEN @Rtstate = 'y' THEN null ELSE 'y' END,
	         ilbo.hasrtstate     = CASE WHEN @Rtstate = 'y' THEN 'y' ELSE null END
      FROM   #fw_req_ilbo			ilbo (nolock), 
             de_published_ui_state state (nolock), 
             #ilbolist				temp (nolock) 
      WHERE state.customer_name = @customer_name 
        AND state.project_name  = @project_name 
        AND state.ecrno			= @ecrno 
        AND state.ui_name		= ilbo.ilbocode COLLATE database_default 
        AND ilbo.ilbocode		= temp.ilbocode 



      /*hasrtstate*/
      UPDATE ilbo 
      SET    ilbo.hasrtstate = 'y' 
      FROM   #fw_req_ilbo			   ilbo (nolock), 
             fw_req_ilbo_rule_template irule(nolock), 
             #ilbolist				   temp (nolock) 
      WHERE ilbo.ilbocode = irule.ilbocode COLLATE database_default 
        AND ilbo.ilbocode = temp.ilbocode 

      /*hastree*/
      UPDATE ilbo 
      SET    ilbo.hastree = 'y' 
      FROM   #fw_req_ilbo					  ilbo (nolock), 
             de_published_service_tree_map_vw tree (nolock), 
             #ilbolist						  temp (nolock) 
      WHERE tree.customername	= @customer_name 
        AND tree.projectname	= @project_name 
        AND tree.ecrno			= @ecrno 
        AND tree.ui_name		= ilbo.ilbocode COLLATE database_default 
        AND ilbo.ilbocode		= temp.ilbocode 

      /*haschart*/ 
      UPDATE ilbo 
      SET    ilbo.haschart = 'y' 
      FROM   #fw_req_ilbo					ilbo (nolock), 
             de_published_chart_task_map_vw chart(nolock), 
             #ilbolist						temp (nolock) 
      WHERE chart.customername	= @customer_name 
        AND chart.projectname	= @project_name 
        AND chart.ecrno			= @ecrno 
        AND chart.ui_name		= ilbo.ilbocode COLLATE database_default 
        AND ilbo.ilbocode		= temp.ilbocode 

      /*hasrichcontrol*/ 
      UPDATE ilbo 
      SET    ilbo.hasrichcontrol = 'y' 
      FROM   #fw_req_ilbo			ilbo(nolock), 
             #fw_extjs_control_dtl	richctrl(nolock), 
             #ilbolist				temp (nolock) 
      WHERE ilbo.ilbocode = richctrl.uiname 
        AND ilbo.ilbocode = temp.ilbocode 

      /*hascontextdataitem*/ 
      UPDATE ilbo 
      SET    ilbo.hascontextdataitem = 'y' 
      FROM   #fw_req_ilbo				ilbo (nolock), 
             #fw_des_ilbo_services		ilboservice(nolock), 
             #fw_des_service_dataitem	dataitem (nolock), 
             #ilbolist					temp (nolock) 
      WHERE ilbo.ilbocode			= ilboservice.ilbocode 
        AND ilbo.ilbocode			= temp.ilbocode 
        AND ilboservice.servicename = dataitem.servicename 
        AND dataitem.dataitemname IN (	'rvwrt_cctxt_pcomponent', 'rvwrt_cctxt_component', 'rvwrt_cctxt_pactivity', 
										'rvwrt_cctxt_activity',  'rvwrt_cctxt_pilbo', 'rvwrt_cctxt_ilbo' ) 

      /*hasdatadriventask*/ 
      UPDATE ilbo 
      SET    ilbo.hasdatadriventask = 'y' 
      FROM   #fw_req_ilbo				ilbo(nolock), 
             #fw_req_activity_ilbo_task ddt (nolock), 
             #ilbolist					temp (nolock) 
      WHERE ilbo.ilbocode				= ddt.ilbocode 
        AND ilbo.ilbocode				= temp.ilbocode 
        AND Isnull(ddt_control_id, '')	<> '' 
        AND Isnull(ddt_view_name, '')	<> '' 

      /*hasezeeview*/ 
      UPDATE ilbo 
      SET    ilbo.hasezeeview = 'y' 
      FROM   #fw_req_ilbo	 ilbo(nolock), 
             #fw_ezeeview_sp ezee(nolock), 
             #ilbolist		 temp (nolock) 
      WHERE ilbo.ilbocode = ezee.ui_name 
        AND ilbo.ilbocode = temp.ilbocode 

      /*hasdynamicilbotitle*/ 
      UPDATE ilbo 
      SET    ilbo.hasdynamicilbotitle = 'y' 
      FROM   #fw_req_ilbo			ilbo(nolock), 
             #fw_req_ilbo_control	ctrl(nolock), 
             #ilbolist				temp(nolock) 
      WHERE ilbo.ilbocode	= ctrl.ilbocode 
       AND	ctrl.controlid	= 'txtvw_rt_ilbo_title' 
       AND	ilbo.ilbocode	= temp.ilbocode 

      /*hasdatasavingtask*/   
      UPDATE ilbo 
      SET    ilbo.hasdatasavingtask = 'y' 
      FROM   #fw_req_ilbo				ilbo(nolock), 
             #fw_req_activity_ilbo_task dst (nolock), 
             #ilbolist					temp(nolock) 
      WHERE ilbo.ilbocode		= dst.ilbocode 
       AND	ilbo.ilbocode		= temp.ilbocode 
       AND	dst.datasavingtask	= 1 

      /*haspretaskcallout*/ 
      UPDATE ilbo 
      SET    ilbo.haspretaskcallout = 'y' 
      FROM   #fw_req_ilbo					 ilbo(nolock), 
             #de_fw_des_publish_task_callout callout(nolock), 
             #ilbolist						 temp (nolock) 
      WHERE ilbo.ilbocode		= callout.ui_name 
       AND	ilbo.ilbocode		= temp.ilbocode 
       AND	callout.calloutmode = 'pre' 

      /*hasposttaskcallout*/ 
      UPDATE ilbo 
      SET    ilbo.hasposttaskcallout = 'y' 
      FROM   #fw_req_ilbo					 ilbo(nolock), 
             #de_fw_des_publish_task_callout callout(nolock), 
             #ilbolist						 temp (nolock) 
      WHERE ilbo.ilbocode		= callout.ui_name 
        AND ilbo.ilbocode		= temp.ilbocode 
        AND callout.calloutmode = 'post' 

      /*hasbasecallout*/ 
      UPDATE ilbo 
      SET    ilbo.hasbasecallout = 'y' 
      FROM   #fw_req_ilbo	 ilbo (nolock), 
             de_published_ui callout (nolock), 
             #ilbolist		 temp (nolock) 
      WHERE callout.customer_name = @customer_name 
       AND	callout.project_name  = @project_name 
       AND	callout.ecrno		  = @ecrno 
       AND	callout.ui_name		  = ilbo.ilbocode COLLATE database_default 
       AND	ilbo.ilbocode		  = temp.ilbocode 
       AND	callout.callout_type IN ( 'web', 'both' ) 

      /*haspivot*/ 
      UPDATE ilbo 
      SET    ilbo.haspivot = 'y' 
      FROM   #fw_req_ilbo		  ilbo(nolock), 
             #fw_req_ilbo_control ctrl(nolock), 
             #ilbolist			  temp (nolock) 
      WHERE ilbo.ilbocode = ctrl.ilbocode 
       AND	ilbo.ilbocode = temp.ilbocode 
  AND	ctrl.type	  = 'rspivotgrid' 

      /*hasmessagelookup*/ 
      UPDATE ilbo 
      SET    ilbo.hasmessagelookup = 'y' 
      FROM   #fw_req_ilbo					   ilbo (nolock), 
             de_fw_des_publish_error_lookup_vw errlookup (nolock), 
             #ilbolist						   temp (nolock) 
      WHERE errlookup.customer_name	= @customer_name 
        AND errlookup.project_name  = @project_name 
        AND errlookup.ecrno			= @ecrno 
        AND errlookup.ui_name		= ilbo.ilbocode COLLATE database_default 
        AND ilbo.ilbocode			= temp.ilbocode 

      /*hasmessagelookuppub*/ 
      UPDATE ilbo 
      SET    ilbo.hasmessagelookuppub = 'y' 
      FROM   #fw_req_ilbo			   ilbo (nolock), 
             de_fw_des_error_lookup_vw errlookup (nolock), 
             #ilbolist				   temp (nolock) 
      WHERE errlookup.customer_name		= @customer_name 
        AND errlookup.project_name		= @project_name 
        AND errlookup.published_ui_name = ilbo.ilbocode COLLATE database_default 
        AND ilbo.ilbocode				= temp.ilbocode 

      /*hasilbopublished*/ 
      UPDATE ilbo 
      SET    ilbo.hasilbopublished = 'y' 
      FROM   #fw_req_ilbo			   ilbo(nolock), 
             #fw_req_ilbo_link_publish pub(nolock), 
             #ilbolist				   temp (nolock) 
      WHERE  ilbo.ilbocode = pub.ilbocode 
        AND  ilbo.ilbocode = temp.ilbocode 

	 /*hasilbopublished*/ 

	  UPDATE ilbo 
      SET    ilbo.hasqlik = 'y' 
      FROM   #fw_req_ilbo							  ilbo(nolock), 
             #de_published_ui_control_association_map qlik(nolock), 
             #ilbolist								  temp(nolock) 
      WHERE ilbo.ilbocode = qlik.ilbocode 
        AND ilbo.ilbocode = temp.ilbocode 

	 /*hascontrolextension*/ 

	  UPDATE ilbo 
      SET    ilbo.hascontrolextension = 'y' 
      FROM   #fw_req_ilbo					 ilbo(nolock), 
             de_published_control_extensions cext(nolock), 
             #ilbolist						 temp (nolock) 
      WHERE cext.customer_name = @customer_name 
        AND cext.project_name  = @project_name 
        AND cext.ecrno		   = @ecrno 
        AND cext.ui_name	   = ilbo.ilbocode COLLATE database_default 
        AND ilbo.ilbocode	   = temp.ilbocode 


      /*Zoom ILBO Cursor*/ 
      DECLARE ilbocurs insensitive CURSOR 
	  FOR 
	  SELECT ai.activityid,ai.activityname,ai.ilbocode 
      FROM   #fw_req_activity_ilbo ai (nolock), 
             #fw_req_ilbo			i (nolock), 
             #ilbolist			   temp(nolock) 
      WHERE  ai.activityname = temp.activity_name 
        AND	 i.ilbocode	     = ai.ilbocode 
        AND	 i.ilbotype	     <> 9 

      OPEN ilbocurs 

      WHILE ( 2 = 2 ) 
        BEGIN 
            FETCH next FROM ilbocurs INTO @activityid, @activityname, @ilbocode 

            IF @@fetch_status <> 0 
              BREAK 
			 
            EXEC De_fw_req_ilbo_remove_transpose_sp @activityid,@ilbocode 
		
            EXEC De_fw_req_activity_transpose_sp @activityid,@activityname,@ilbocode,@ecrno,'2' 
		
            UPDATE zoom 
            SET    zoom.statusflag = 1 
            FROM   #fw_req_ilbo_control			 ic (nolock), 
                   #fw_req_ilbo					 i (nolock), 
                   #fw_req_ilbo_control_property cp (nolock), 
                   #fw_req_ilbo_data_use		 datause (nolock), 
                   #fw_req_task					 task (nolock), 
                   #fw_req_ilbo					 zoom (nolock) 
            WHERE  i.ilbocode			  = @ilbocode 
            AND	   ic.ilbocode			  = i.ilbocode 
            AND    i.ilbotype			  <> 9 
            AND    ic.type				  = 'rsgrid' 
            AND	   cp.ilbocode			  = ic.ilbocode 
            AND    cp.controlid			  = ic.controlid 
            AND    cp.propertyname		  = 'zoom' 
            AND    cp.value				  = 'true' 
            AND    datause.parentilbocode = ic.ilbocode 
            AND    datause.controlid	  = ic.controlid 
            AND    zoom.ilbocode		  = datause.childilbocode 
           AND    zoom.ilbotype		  = '9' 
            AND    task.taskname		  = datause.taskname 
            AND    task.tasktype		  = 'zoom' 
        END 

      CLOSE ilbocurs 

      DEALLOCATE ilbocurs 

	   /*Ilbos involved in codegen*/
	  INSERT INTO #ilbolist (component_name,activity_name,ilbocode) 
	  SELECT distinct LOWER(LTRIM(RTRIM(temp.component_name))),LOWER(LTRIM(RTRIM(ai.activityname))),LOWER(LTRIM(RTRIM(i.ilbocode)))
      FROM	#fw_req_ilbo		  i(nolock), 
			#fw_req_activity_ilbo ai(nolock), 
			#ilbolist             temp(nolock), 
			#fw_req_ilbo_data_use zoom (nolock) 
      WHERE ai.ilbocode			= temp.ilbocode 
      AND   zoom.parentilbocode = temp.ilbocode 
      AND   zoom.childilbocode	= i.ilbocode 
	  AND   i.ilbotype			= 9 

      /*Activity Details*/ 
      SELECT Distinct a.activityid, 
             LOWER(LTRIM(RTRIM(a.activityname))) 'activityname', 
             a.activitydesc 
      FROM   #fw_req_activity a(nolock), 
             #ilbolist temp (nolock) 
      WHERE  a.activityname = temp.activity_name 

      /*Ilbo properties*/ 
      SELECT 
			temp.activity_name 'activityname',
			temp.ilbocode,
			ilbotype,
			description  'ilbodesc', 
             isnull(haslegacystate,'') as haslegacystate,
			 isnull(hasrtstate,'') as hasrtstate,
			 isnull(hastree,'') as hastree,
			 isnull(haschart,'') as haschart,
			 isnull(hasrichcontrol,'') as hasrichcontrol,
			 isnull(hascontextdataitem,'') as hascontextdataitem,
			 isnull(hasdatadriventask,'') as hasdatadriventask, 
			 isnull(hasezeeview,'') as hasezeeview,
			 isnull(hasdynamicilbotitle,'') as hasdynamicilbotitle,
			 isnull(hasdatasavingtask,'') as hasdatasavingtask,
			 isnull(haspretaskcallout,'') as haspretaskcallout,
			 isnull(hasposttaskcallout,'') as hasposttaskcallout,
			 isnull(hasbasecallout,'') as hasbasecallout, 
			 isnull(haspivot,'') as haspivot,
			 isnull(hasmessagelookup,'') as hasmessagelookup,
			 isnull(hasmessagelookuppub,'') as hasmessagelookuppub,
			 isnull(hasilbopublished,'') as hasilbopublished,
			 isnull(hascontrolextension,'') as hascontrolextension,
			 isnull(hasdynamiclink,'') as hasdynamiclink,
			 isnull(hasqlik,'') as hasqlik,
			 isnull(sensitive,'') as hassensitivedata 
      FROM   #fw_req_ilbo          i(nolock), 
             #fw_req_activity_ilbo ai(nolock), 
             #ilbolist             temp(nolock) 
      WHERE  i.ilbocode = ai.ilbocode 
       AND	 i.ilbocode = temp.ilbocode 
	   AND   i.ilbotype <> 9 

      UNION 

      SELECT temp.activity_name 'activityname' ,
	  LOWER(LTRIM(RTRIM(i.ilbocode)))'ilbocode',
	  i.ilbotype'ilbotype',
	  i.description 'ilbodesc',
	  isnull(haslegacystate,'') as haslegacystate,
	  isnull(hasrtstate,'') as hasrtstate,
	  isnull(hastree,'') as hastree,
	  isnull(haschart,'') as haschart,
	  isnull(hasrichcontrol,'') as hasrichcontrol,
	  isnull(hascontextdataitem,'') as hascontextdataitem,
	  isnull(hasdatadriventask,'') as hasdatadriventask,
	  isnull(hasezeeview,'') as hasezeeview,
	  isnull(hasdynamicilbotitle,'') as hasdynamicilbotitle,
	  isnull(hasdatasavingtask,'') as hasdatasavingtask,
	  isnull(haspretaskcallout,'') as haspretaskcallout,
	  isnull(hasposttaskcallout,'') as hasposttaskcallout,
	  isnull(hasbasecallout,'') as hasbasecallout,
	  isnull(haspivot,'') as haspivot,
	  isnull(hasmessagelookup,'') as hasmessagelookup,
	  isnull(hasmessagelookuppub,'') as hasmessagelookuppub,
	  isnull(hasilbopublished,'') as hasilbopublished,
	  isnull(hascontrolextension,'') as hascontrolextension,
	  isnull(hasdynamiclink,'') as hasdynamiclink,
	  isnull(hasqlik,'') as hasqlik ,
	  isnull(sensitive,'') as hassensitivedata 
      FROM #fw_req_ilbo			 i(nolock), 
           #fw_req_activity_ilbo ai(nolock), 
           #ilbolist			 temp(nolock), 
           #fw_req_ilbo_data_use zoom (nolock) 
      WHERE  ai.ilbocode		 = temp.ilbocode 
      AND    zoom.parentilbocode = temp.ilbocode 
      AND    zoom.childilbocode  = i.ilbocode 
      AND    i.ilbotype			 = 9 



      /*Tab properties*/ 
      SELECT temp.ilbocode					'ilbocode', 
             LOWER(LTRIM(RTRIM(a.tabname)))	'tabname', 
             a.value                        'sequence' 
      FROM   #fw_req_ilbo_tab_properties a(nolock), 
             #ilbolist					 temp (nolock) 
      WHERE a.ilbocode     = temp.ilbocode 
        AND a.propertyname = 'SequenceNo' 
        
      UNION 
      SELECT temp.ilbocode					   'ilbocode', 
             'mainpage'                        'tabname', 
             ''								   'sequence'
      FROM   #fw_req_ilbo ilbo(nolock), 
             #ilbolist    temp(nolock) 
      WHERE  ilbo.ilbocode = temp.ilbocode 
      ORDER  BY 1,2 

           /*Get the controls and layout controls along with associated views,properties*/ 
	  SELECT * FROM 
      (SELECT DISTINCT 
      ilbocode		= temp.ilbocode, 
	  btsynonym     = LOWER(LTRIM(RTRIM(v.btsynonym))),
      tabname		= CASE Isnull(c.tabname, '') 
						WHEN '' THEN 'mainpage' 
						ELSE LOWER(LTRIM(RTRIM(c.tabname))) 
					  END, 
      controlid		= LOWER(LTRIM(RTRIM(c.controlid))), 
      viewname		= LOWER(LTRIM(RTRIM(v.viewname))), 
		type		= CASE 
						WHEN ( Isnumeric(v.viewname) = 1 OR  displayflag = 'f' or c.type ='rslistedit' 
							  or c.type='rstreegrid' or c.type = 'rsslider' or c.type = 'rsstackedlinks' or c.type = 'rsgrid') THEN 'view' -- rsgrid added by Jeya for supporting Gantt & Calendar
						WHEN ( Isnumeric(v.viewname) = 0 AND displayflag = 't' ) THEN 'control' 
					  END, 
      controltype	= LOWER(LTRIM(RTRIM(c.type))), 
      displayflag	= LOWER(LTRIM(RTRIM(v.displayflag))), 
      datatype		= b.datatype,  ---------enumerated value is available in this datatype 
      precision		= CASE b.datatype WHEN 'numeric' THEN Isnull(b.precisiontype, '') ELSE '' END, 
      listedit_req	= isnull(c.listedit,''), 
      layoutcontrol	='n', 
      length        = b.length ,
	  associatedcontrol = LOWER(LTRIM(RTRIM(isnull(listedit.controlid,''))))
      FROM   #fw_req_ilbo_view		v (nolock), 
             #fw_req_bterm_synonym bs (nolock), 
             #fw_req_bterm			b (nolock), 
             #fw_req_ilbo			i (nolock), 
             #ilbolist				temp(nolock),
			 #fw_req_ilbo_control	c(nolock)  left join
			 #de_listedit_view_datamap listedit(nolock)
	  ON    c.ilbocode  = listedit.ilbocode
	  AND	c.controlid = listedit.listedit
	  
      WHERE i.ilbocode		= temp.ilbocode 
        AND c.ilbocode		= i.ilbocode 
        AND v.ilbocode		= c.ilbocode 
        AND v.controlid		= c.controlid 
        AND v.btsynonym		<> 'modeflag' 
        AND bs.btsynonym	= v.btsynonym 
        AND b.btname		= bs.btname 
        AND c.type NOT		IN ( 'Label', 'UserControl', '' ) 

      UNION 

      SELECT temp.ilbocode					'ilbocode', 
			 controlid						 'btsynonym',
             tabname						'tabname', 
             controlid						'controlid', 
             ''                                'viewname', 
             ''                                'type', 
             type								'controltype', 
             ''                                'displayflag', 
             ''                                'datatype', 
             ''                                'precision', 
             ''                               'listedit_req', 
             'y'                               'layoutcontrol', 
             0                                 'length' ,
			 ''								   'associatedcontrol'
      FROM   #fw_req_ilbo_layout_control ilbo(nolock), 
             #ilbolist temp(nolock) 
      WHERE  ilbo.ilbocode = temp.ilbocode ) ctrllist
      ORDER  BY ilbocode,layoutcontrol,(CASE WHEN layoutcontrol = 'y' THEN controltype END ),
				(CASE WHEN layoutcontrol = 'y' THEN tabname END ), controlid,viewname 

	  /*enumerated option*/
      SELECT DISTINCT ilbocode   = temp.ilbocode, 
                      controlid  = LOWER(LTRIM(RTRIM(v.controlid))), 
                      viewname   = LOWER(LTRIM(RTRIM(v.viewname))), 
                      sequenceno = en.sequenceno, 
                      optioncode = en.optioncode, 
                      optiondesc = en.optiondesc, 
                      languageid = en.langid 
      FROM   #fw_req_ilbo_view				 v (nolock), 
             #fw_req_bterm_synonym			 bs (nolock), 
             #fw_req_bterm					 b (nolock), 
             #fw_req_ilbo					 i (nolock), 
             #fw_req_bterm_enumerated_option en (nolock), 
             #ilbolist						 temp(nolock) 
      WHERE i.ilbocode   = temp.ilbocode 
		AND v.ilbocode	 = i.ilbocode 
		AND v.btsynonym <> 'modeflag' 
		AND bs.btsynonym = v.btsynonym 
		AND b.btname     = bs.btname 
		AND b.datatype   = 'enumerated' 
		AND en.btname    = b.btname 
		AND en.langid    = 1

      /*Control view Properties*/
      SELECT DISTINCT 
		temp.ilbocode   'ilbocode', 
        LOWER(LTRIM(RTRIM(controlid)))       'controlid', 
        LOWER(LTRIM(RTRIM(viewname)))        'viewname', 
        LOWER(propertyname)    'propertyname', 
        CASE propertyname 
        WHEN 'default value' THEN Ltrim(Rtrim(Isnull(value,'NULL'))) 
        ELSE Ltrim(Rtrim(Isnull(value, 'null'))) 
        END                               'propertyvalue' 
      FROM   #fw_req_ilbo_control_property ilbo (nolock), 
             #ilbolist temp(nolock) 
      WHERE  ilbo.ilbocode = temp.ilbocode 

      /*Task service details*/
	  SELECT * FROM 
      (SELECT DISTINCT 
		ilbocode				= temp.ilbocode, 
		servicename				= ds.servicename, 
		servicetype				= ds.servicetype, 
		taskname				= isvd.taskname, 
		taskdesc				= t.taskdesc, 
		tasktype				= t.tasktype, 
		servicecomponentname	= ds.componentname, 
		sessionvariable			= '', 
		resultantasp			= '', 
		datasavingtask			= CASE WHEN t.tasktype in ('help', 'link' ) THEN 0 ELSE Isnull(ait.datasavingtask, 0) END, 
		iszipped				= Isnull(iszipped, 0), 
		iscached				= Isnull(iscached, 0), 
		clearkey_pattern		= Isnull(clearkey_pattern, ''), 
		setkey_pattern			= Isnull(setkey_pattern, ''),
		primarycontrol			= CASE WHEN t.tasktype in ('help', 'link' ) THEN act.primary_control_bts ELSE '' END,
		ordering				= CASE WHEN t.tasktype in ('help', 'link' ) THEN 2 ELSE 1 END 
					  
      FROM   #fw_des_service					ds  (nolock), 
             #fw_req_task						t   (nolock), 
             #fw_des_ilbo_service_view_datamap  isvd(nolock), 
             #ilbolist							temp(nolock) , 
             #fw_req_activity_ilbo_task			ait (nolock) left outer join
			 #de_published_action			  act (nolock) 
	  ON     ait.ilbocode = act.ui_name 
      AND	 ait.taskname = act.task_name
      WHERE isvd.ilbocode = temp.ilbocode 
        AND isvd.servicename = ds.servicename 
        AND isvd.taskname = t.taskname 
        AND isvd.ilbocode = ait.ilbocode 
        AND isvd.taskname = ait.taskname 
        --AND t.tasktype not in ('help', 'link') 
        AND NOT EXISTS (SELECT 'x' 
                        FROM   #fw_req_activity_ilbo_task_extension_map aitem (nolock) 
                        WHERE  aitem.ilbocode = ait.ilbocode 
                        AND	aitem.taskname = ait.taskname) 
	  UNION
      SELECT DISTINCT 
      ilbocode			   = temp.ilbocode, 
      servicename		   = ds.servicename , 
      servicetype		   = ds.servicetype, 
      taskname			   = isvd.taskname, 
      taskdesc			   = t.taskdesc, 
      tasktype			   = t.tasktype, 
      servicecomponentname = ds.componentname, 
      sessionvariable	   = aitem.sessionvariable, 
      resultantasp		   = aitem.resultantaspname, 
      datasavingtask	   = Isnull(ait.datasavingtask, 0), 
      iszipped			   = Isnull(iszipped, 0), 
     iscached			   = Isnull(iscached, 0), 
      clearkey_pattern	   = Isnull(clearkey_pattern, ''), 
      setkey_pattern	   = Isnull(setkey_pattern, '') ,
	  primarycontrol	   = '',
	  ordering            =1
    FROM   #fw_des_service							ds   (nolock), 
             #fw_req_task								t    (nolock), 
             #fw_des_ilbo_service_view_datamap			isvd (nolock), 
             #fw_req_activity_ilbo_task					ait  (nolock), 
             #fw_req_activity_ilbo_task_extension_map aitem  (nolock), 
             #ilbolist temp(nolock) 
      WHERE isvd.ilbocode = temp.ilbocode 
        AND isvd.servicename = ds.servicename 
        AND isvd.taskname = t.taskname 
        AND isvd.ilbocode = ait.ilbocode 
        AND isvd.taskname = ait.taskname 
        AND aitem.ilbocode = ait.ilbocode 
        AND aitem.taskname = ait.taskname 
        AND t.tasktype IN ( 'submit', 'trans', 'ui' ) 
      UNION 
      SELECT DISTINCT 
		ilbocode			= temp.ilbocode, 
		servicename			= '', 
		servicetype			= '', 
		taskname			= LOWER(LTRIM(RTRIM(t.taskname))), 
		taskdesc			= t.taskdesc, 
		tasktype			= LOWER(LTRIM(RTRIM(t.tasktype))), 
		servicecomponentname = '', 
		sessionvariable		='', 
		resultantasp		= '', 
		datasavingtask		= 0, 
		iszipped			= 0, 
		iscached			= 0, 
		clearkey_pattern	= '', 
		setkey_pattern		= ''  ,
		primarycontrol		= LOWER(LTRIM(RTRIM(act.primary_control_bts))),
		ordering            =2
      FROM   #fw_req_task				t (nolock), 
             #ilbolist					temp(nolock),
			 #fw_req_activity_ilbo_task ait (nolock) left outer join
			 #de_published_action		act (nolock) 
	  ON    ait.ilbocode = act.ui_name 
        AND ait.taskname = act.task_name 
      WHERE ait.ilbocode = temp.ilbocode 
        AND ait.taskname = t.taskname 
        AND t.tasktype IN ( 'help', 'link', 'zoom' ) 
        AND NOT EXISTS (SELECT 'x' 
                        FROM   #fw_des_ilbo_service_view_datamap isvd (nolock) 
                        WHERE ait.ilbocode = isvd.ilbocode 
                          AND ait.taskname = isvd.taskname) ) task
		order by ilbocode ,ordering,(CASE WHEN ordering =  1 THEN servicename WHEN ordering = 2 THEN taskname END)

         /*Report information*/ 
      SELECT DISTINCT temp.ilbocode 'ilbocode', 
                      taskname      'taskname', 
                      pagename      'tabname', 
                      processingtype'processingtype', 
                      contextname   'contextname', 
                      reporttype    'reporttype' 
      FROM   #fw_req_ilbo_task_rpt ilbo (nolock), 
             #ilbolist temp(nolock) 
      WHERE  ilbo.ilbocode = temp.ilbocode 

      /*ezeeview details*/ 
      SELECT sp.ui_name       'ui_name', 
             sp.taskname      'taskname', 
             sp.target_spname 'target_spname', 
             parametername    'parametername', 
             mapped_control   'mapped_control', 
             controlid        'controlid', 
             viewname         'viewname', 
             datatype         'datatype', 
             length 
      FROM   #fw_req_bterm_synonym b(nolock), 
             #fw_req_bterm		   c(nolock), 
             #ilbolist			   temp(nolock), 
             #fw_ezeeview_sp	   sp LEFT OUTER JOIN 
			 #fw_ezeeview_spparamlist a 
        ON	a.ui_name		= sp.ui_name 
        AND a.taskname		= sp.taskname 
        AND a.target_spname = sp.target_spname 
      WHERE temp.ilbocode	= sp.ui_name 
        AND b.btsynonym		= a.mapped_control 
        AND c.btname		= b.btname 

      /*Tree Details*/ 
      SELECT LOWER(LTRIM(RTRIM(ui_name)))     'ui_name', 
             CASE page_name 
               WHEN '[mainscreen]' THEN 'mainpage' 
               ELSE LOWER(LTRIM(RTRIM(page_name))) 
             END                               'tabname', 
             LOWER(LTRIM(RTRIM(section_name)))'treecontrol', 
             LOWER(LTRIM(RTRIM(taskname)))    'taskname', 
        LOWER(LTRIM(RTRIM(servicename))) 'servicename', 
             clear_tree_before_population     'clear_flag' 
      FROM   de_published_service_tree_map_vw a(nolock), 
             #ilbolist						  temp(nolock) 
      WHERE a.customername = @Customer_Name 
        AND a.projectname  = @Project_Name 
        AND a.ecrno		   = @EcrNo 
        AND a.ui_name      = temp.ilbocode COLLATE database_default 
      ORDER  BY ui_name, servicename,treecontrol 

      SELECT DISTINCT 
	  LOWER(LTRIM(RTRIM(ui_name)))																  AS 'ui_name', 
	  LOWER(LTRIM(RTRIM(Isnull(section_bt_synonym, ''))))										  AS 'section_bt_synonym', 
	  LOWER(LTRIM(RTRIM(Isnull(node_type, ''))))    											  AS 'node_type', 
	  Isnull(node_description, '')				  									              AS 'node_description', 
		'../Themes/Treecontrol/Images/' + Isnull(Lower(open_img_name), 'folderopen.gif')		  AS 'vwt_openimage', 
		'../Themes/Treecontrol/Images/' + Isnull(Lower(not_exp_img_name), 'notexpandable.gif') 	  AS 'vwt_notexpandedimage', 
		'../Themes/Treecontrol/Images/' + Isnull(Lower(expendable_img_name), 'notexpandable.gif') AS 'vwt_expandableimage', 
		'../Themes/Treecontrol/Images/' + Isnull(Lower(expended_img_name), 'expanded.gif') 		  AS 'vwt_expandedimage', 
		'../Themes/Treecontrol/Images/' + Isnull(Lower(close_img_name), 'folder.gif') 			  AS 'vwt_closeimage', 
		'../Themes/Treecontrol/Images/' + Isnull(Lower(chkbox_chk_img), 'folder.gif') 			  AS 'vwt_checkimage', 
		'../Themes/Treecontrol/Images/' + Isnull(Lower(chkbox_unchk_img), 'unchecked.gif') 		  AS 'vwt_uncheckimage', 
		'../Themes/Treecontrol/Images/' + Isnull(Lower(chkbox_parial_chkimg), 'partchecked.gif')  AS 'chkbox_parial_chkimg' 
      FROM   de_published_tree_dtl a(nolock), 
             #ilbolist			   temp(nolock) 
      WHERE a.customer_name = @Customer_Name 
        AND a.project_name  = @Project_Name 
        AND a.ecrno			= @EcrNo 
        AND a.ui_name		= temp.ilbocode COLLATE database_default 
      ORDER  BY ui_name,section_bt_synonym,node_type 

      /*chart details*/ 
      SELECT DISTINCT 
	    LOWER(LTRIM(RTRIM(ui_name)))      AS 'ui_name', 
        CASE page_name 
        WHEN '[mainscreen]' THEN 'mainpage' 
        ELSE LOWER(LTRIM(RTRIM(page_name))) 
        END                               AS 'tabname', 
        LOWER(LTRIM(RTRIM(section_name))) 'chartcontrol', 
        LOWER(LTRIM(RTRIM(taskname)))     'taskname', 
        LOWER(LTRIM(RTRIM(servicename)))  'servicename' 
      FROM   de_published_chart_task_map_vw a(nolock), 
             #ilbolist					    temp(nolock) 
      WHERE a.customername = @Customer_Name 
        AND a.projectname  = @Project_Name 
        AND a.ecrno		   = @EcrNo 
        AND a.ui_name	   = temp.ilbocode COLLATE database_default 
      ORDER  BY ui_name,tabname,chartcontrol,servicename 

     /*Publication Details*/ 

	 SELECT  ilbocode     = temp.ilbocode, 
             linkid		  = ilp.linkid, 
             dataitemname = LOWER(LTRIM(RTRIM(ilp.dataitemname))), 
             controlid	  = LOWER(LTRIM(RTRIM(ilp.controlid))), 
             viewname     = LOWER(LTRIM(RTRIM(ilp.viewname))), 
             controltype  = LOWER(LTRIM(RTRIM(c.type))), 
             flowtype     = ilp.flowtype 
      FROM   #fw_req_ilbo_data_publish ilp (nolock), 
             #fw_req_activity_ilbo		ai (nolock), 
             #fw_req_ilbo_control		c (nolock), 
             #ilbolist				   temp(nolock) 
      WHERE ai.ilbocode   = temp.ilbocode 
		AND ilp.ilbocode  = ai.ilbocode 
		AND ilp.ilbocode  = c.ilbocode 
		AND ilp.controlid = c.controlid 
      UNION 
      SELECT ilbocode	  = temp.ilbocode, 
             linkid		  = ilp.linkid, 
             dataitemname = LOWER(LTRIM(RTRIM(ilp.dataitemname))), 
             controlid	  = LOWER(LTRIM(RTRIM(ilp.controlvariablename))), 
             viewname	  = LOWER(LTRIM(RTRIM(ilp.controlvariablename))), 
             controltype  = 'rseditctrl', 
             flowtype     = ilp.flowtype 
      FROM   #fw_req_ilbo_data_publish ilp (nolock), 
             #fw_req_activity_ilbo     ai (nolock), 
             #ilbolist                 temp(nolock) 
     WHERE  ai.ilbocode  = temp.ilbocode 
        AND ilp.ilbocode  = ai.ilbocode 
        AND ilp.iscontrol = 0 
      ORDER  BY ilp.linkid 
      
      /*Traversal details*/ 
      SELECT DISTINCT 
	    ilbocode         = temp.ilbocode COLLATE database_default, 
        taskname         = LOWER(LTRIM(RTRIM(u.taskname))) COLLATE database_default, 
        componentname    = LOWER(LTRIM(RTRIM(a.componentname))) COLLATE database_default, 
        childactivity    = LOWER(LTRIM(RTRIM(a.activityname)))  COLLATE database_default, 
        childilbo        = LOWER(LTRIM(RTRIM(u.childilbocode))) COLLATE database_default, 
        posttask		 = isnull(LOWER(LTRIM(RTRIM(Isnull(u.posttask, u.post_linktask)))) COLLATE database_default,''), 
        childactivitytype= activitytype 
      FROM   #fw_req_ilbo_linkuse     u (nolock), 
             #fw_req_activity	      a (nolock), 
             #fw_req_activity_ilbo    ai (nolock), 
             #fw_req_ilbo_link_publish c (nolock), 
             #ilbolist				  temp(nolock) 
      WHERE temp.ilbocode= parentilbocode 
		AND ai.ilbocode  = u.childilbocode 
		AND a.activityid = ai.activityid 
		AND c.linkid     = u.linkid 
		AND c.ilbocode   = u.childilbocode 
		AND c.activityid = ai.activityid 
      UNION 
      SELECT DISTINCT 
	    ilbocode		 = temp.ilbocode, 
        taskname		 = b.task_name, 
        componentname	 = LOWER(LTRIM(RTRIM(a.linked_component))), 
        childactivity	 = LOWER(LTRIM(RTRIM(a.linked_activity))), 
        childilbo		 = LOWER(LTRIM(RTRIM(a.linked_ui))), 
        posttask		 ='', 
        childactivitytype= 0 
      FROM   de_published_ui_traversal a(nolock), 
             #de_published_action	   b(nolock), 
             #ilbolist				   temp(nolock) 
      WHERE a.customer_name								   = @customer_name 
		AND a.project_name								   = @project_name 
		AND a.ecrno										   = @ecrno 
		AND a.ui_name                                      = temp.ilbocode COLLATE database_default 
		AND a.link_type									   = 'Lnk' 
		AND b.component_name COLLATE database_default	   = a.component_name 
		AND b.activity_name COLLATE database_default	   = a.activity_name 
		AND b.ui_name COLLATE database_default			   = a.ui_name 
		AND b.page_bt_synonym COLLATE database_default	   = a.page_bt_synonym 
		AND b.primary_control_bts COLLATE database_default = a.control_bt_synonym 
		AND Isnull(a.linked_component, '')				   <> '' 
		AND Isnull(a.linked_activity, '')				   <> '' 
		AND Isnull(a.linked_ui, '')						   <> '' 
		AND NOT EXISTS (SELECT 'x' 
						FROM   #fw_req_ilbo_linkuse u (nolock) 
						WHERE  u.parentilbocode = b.ui_name 
						AND    u.taskname	    = b.task_name) 

      /*Subscription Dataitem*/ 
      SELECT ilbocode		 = temp.ilbocode, 
             taskname		 = LOWER(LTRIM(RTRIM(taskname))), 
             dataitemname	 = LOWER(LTRIM(RTRIM(dataitemname))), 
             controlid		 = LOWER(LTRIM(RTRIM(Isnull(controlid, controlvariablename)))), 
             viewname		 = LOWER(LTRIM(RTRIM(Isnull(viewname, controlvariablename)))), 
             retrievemultiple= retrievemultiple, 
             flowattribute   = CASE flowtype 
							   WHEN 0 THEN 1 
							   WHEN 1 THEN 0 
							   ELSE 2 
							   END , 
             linkid			= linkid 
      FROM   #fw_req_ilbo_data_use    (nolock), 
             #ilbolist			  temp(nolock) 
      WHERE  parentilbocode = temp.ilbocode 
      ORDER  BY dataitemname 

 /*segment details*/ 
      SELECT DISTINCT 
		temp.ilbocode					  'ilbocode',
		a.servicename					  'servicename', 
        a.segmentname					  'segmentname', 
        a.segmentsequence                 'segmentsequence', 
        a.instanceflag                    'segmentinstance', 
        a.flowattribute                   'flowdirection', 
        CASE b.combofill 
        WHEN 1 THEN 'true' 
        ELSE 'false' 
		END								  'combofilling' 
      FROM   #fw_des_ilbo_services ilbo (nolock) , 
             #ilbolist temp(nolock)  ,
			 #fw_des_service_segment a(nolock) LEFT OUTER JOIN 
			 #fw_des_task_segment_attribs b(nolock) 
       ON   a.servicename    = b.servicename 
       AND  a.segmentname    = b.segmentname 
	  WHERE temp.ilbocode    = ilbo.ilbocode
	    AND ilbo.servicename = a.servicename

      /*service dataitem details (Execute Service)*/   
      SELECT ilbocode = sv.ilbocode, 
             servicename = sv.servicename, 
             segmentname = sv.segmentname, 
             dataitemname = sv.dataitemname, 
             controlid = sv.controlid, 
             viewname = sv.viewname, 
             flowattribute = sd.flowattribute, 
             propertytype = sv.propertytype, 
             propertyname = sv.propertyname, 
             ditype = 'property' 
      FROM   #fw_des_publish_ilbo_service_view_attributemap sv  (nolock), 
             #fw_des_service_dataitem						sd  (nolock), 
             #ilbolist                                      temp(nolock) 
      WHERE  sv.ilbocode = temp.ilbocode 
        AND sv.servicename = sd.servicename 
        AND sv.segmentname = sd.segmentname 
        AND sv.dataitemname = sd.dataitemname 
        AND NOT EXISTS (SELECT 'x' 
                        FROM   #fw_des_ilbo_service_view_datamap il (nolock) 
                        WHERE  sv.activityid   = il.activityid 
                        AND	   sv.servicename  = il.servicename 
                        AND	   sv.taskname	   = il.taskname 
                        AND    sv.ilbocode	   = il.ilbocode 
                        AND    sv.servicename  = il.servicename 
                        AND    sv.segmentname  = il.segmentname 
                        AND    sv.dataitemname = il.dataitemname) 
      UNION 
      SELECT ilbocode	  = sv.ilbocode, 
             servicename  = sv.servicename, 
             segmentname  = sv.segmentname, 
             dataitemname = LOWER(LTRIM(RTRIM(sv.dataitemname))), 
             controlid    = CASE WHEN exists (SELECT 'x' FROM #de_listedit_view_datamap listedit(nolock) 
											  WHERE sv.ilbocode  = listedit.ilbocode 
											  AND   sv.controlid = listedit.listedit) 

								 THEN          (SELECT LOWER(LTRIM(RTRIM(listedit.controlid)))  
											   FROM #de_listedit_view_datamap listedit(nolock) 
											   WHERE sv.ilbocode  = listedit.ilbocode 
											   AND   sv.controlid = listedit.listedit)
							     ELSE sv.controlid END,
			
             viewname      = LOWER(LTRIM(RTRIM(sv.viewname))), 
             flowattribute = sd.flowattribute, 
             propertytype  = '', 
             propertyname  = '', 
             ditype        = 'data' 
      FROM   #fw_des_service_dataitem		   sd (nolock), 
             #ilbolist						   temp(nolock),
			 #fw_des_ilbo_service_view_datamap sv (nolock)       

      WHERE sv.ilbocode		= temp.ilbocode 
        AND sv.servicename  = sd.servicename 
        AND sv.segmentname  = sd.segmentname 
        AND sv.dataitemname = sd.dataitemname 

	  UNION 
      SELECT ilbocode	   = sv.ilbocode, 
             servicename   = sd.servicename, 
             segmentname   = sd.segmentname, 
             dataitemname  = sd.dataitemname, 
             controlid	   = '_con'+sd.dataitemname,
             viewname	   = sd.dataitemname, 
             flowattribute = sd.flowattribute, 
             propertytype  = '', 
             propertyname  = '', 
             ditype		   = 'data' 
      FROM   #fw_des_service_dataitem		   sd (nolock), 
             #ilbolist						   temp(nolock),
			 #fw_des_ilbo_service_view_datamap sv (nolock)       
      WHERE sv.ilbocode		= temp.ilbocode 
        AND sv.servicename  = sd.servicename 
        AND sd.dataitemname IN (	'rvwrt_cctxt_pcomponent', 'rvwrt_cctxt_component', 'rvwrt_cctxt_pactivity', 
								'rvwrt_cctxt_activity',  'rvwrt_cctxt_pilbo', 'rvwrt_cctxt_ilbo' ) 
			
      ORDER  BY 2,3,4

       /*Gettaskdata details*/ 
      SELECT DISTINCT
	    LOWER(LTRIM(RTRIM(a.ilbocode)))  'ilbocode', 
		LOWER(LTRIM(RTRIM(a.taskname)))  'taskname', 
		LOWER(LTRIM(RTRIM(a.tabname)))   'tabname', 
		LOWER(LTRIM(RTRIM(a.controlid))) 'controlid', 
        Max(a.filling)                   'filling' 
      FROM   
	  (SELECT   vdm.ilbocode 'ilbocode',vdm.taskname 'taskname',
				( CASE WHEN Isnull(ic.tabname, '') = '' THEN 'mainpage' ELSE ic.tabname END )'tabname', 
				vdm.controlid 'controlid',seg.instanceflag 'Filling' 
		FROM    #fw_des_ilbo_service_view_datamap vdm (nolock), 
				#fw_des_service_segment			  seg (nolock), 
				#fw_des_service_dataitem		  di  (nolock), 
				#fw_req_ilbo_control			  ic  (nolock), 
				#ilbolist						  temp(nolock) 
		WHERE vdm.ilbocode	= temp.ilbocode 
		AND seg.servicename = vdm.servicename 
		AND seg.segmentname = vdm.segmentname 
		AND di.servicename	= seg.servicename 
		AND di.segmentname	= seg.segmentname 
		AND di.dataitemname = vdm.dataitemname 
		AND di.flowattribute IN( 1, 2 ) 
		AND ic.ilbocode		= vdm.ilbocode 
		AND ic.controlid	= vdm.controlid 
		AND ic.type			<> 'rslistedit' 
		UNION 
		SELECT datause.parentilbocode 'ilbocode',datause.taskname 'taskname',
			   ( CASE WHEN Isnull(ilbocontrol.tabname, '') = '' THEN 'mainpage' ELSE ilbocontrol.tabname END )'tabname',
			   datause.controlid 'controlid','0' 'Filling' 
		FROM   #fw_req_ilbo_data_use datause (nolock), 
			   #fw_req_ilbo_control	 ilbocontrol (nolock), 
			   #fw_req_task			 task (nolock), 
			   #ilbolist			 temp(nolock) 
		WHERE  datause.parentilbocode = temp.ilbocode 
		AND ilbocontrol.ilbocode	  = datause.parentilbocode 
		AND ilbocontrol.controlid	  = datause.controlid 
		AND datause.flowtype		  IN ( 0, 2 ) 
		AND ilbocontrol.type		  <> 'rslistedit' 
		AND datause.taskname		  =  task.taskname 
		AND task.tasktype			  IN ( 'help', 'link' ) 
		UNION 
		SELECT b.parentilbocode 'ilbocode',b.taskname 'taskname',
			   ( CASE WHEN Isnull(ic.tabname, '') = '' THEN 'mainpage' ELSE ic.tabname END ) 'tabname', 
			   vdm.controlid 'controlid',seg.instanceflag  'Filling' 
		FROM    #fw_des_ilbo_service_view_datamap vdm (nolock), 
				#fw_des_service_segment			  seg (nolock), 
				#fw_des_service_dataitem		  di (nolock), 
				#fw_req_ilbo_control			  ic(nolock), 
				#fw_req_ilbo_linkuse			  b(nolock), 
				#fw_req_task					  task (nolock), 
				#ilbolist						  temp(nolock) 
		WHERE  b.parentilbocode = temp.ilbocode 
		AND vdm.ilbocode		= b.parentilbocode 
		AND ( b.posttask IS NOT NULL OR b.post_linktask IS NOT NULL ) 
		AND vdm.taskname		= Isnull(b.posttask, b.post_linktask) 
		AND seg.servicename		= vdm.servicename 
		AND seg.segmentname		= vdm.segmentname 
		AND di.servicename		= seg.servicename 
		AND di.segmentname		= seg.segmentname 
		AND di.dataitemname		= vdm.dataitemname 
		AND di.flowattribute	IN( 1, 2 ) 
		AND ic.ilbocode			= vdm.ilbocode 
		AND ic.controlid		= vdm.controlid 
		AND ic.type				<> 'rslistedit' 
		AND b.taskname			= task.taskname 
		AND task.tasktype		IN ( 'help', 'link' ) 
		UNION 
		SELECT DISTINCT 
		adm.ilbocode 'ilbocode',adm.taskname 'taskname',
		( CASE WHEN adm.page_bt_synonym = '[mainscreen]' THEN 'mainpage' ELSE adm.page_bt_synonym END )'tabname', 
		adm.controlid 'controlid',seg.instanceflag 'Filling' 
		FROM   #fw_des_publish_ilbo_service_view_attributemap adm (nolock), 
			   #fw_des_service_segment seg (nolock), 
			   #fw_des_service_dataitem di (nolock), 
			   #ilbolist temp(nolock) 
		WHERE  adm.ilbocode = temp.ilbocode 
		AND seg.servicename = adm.servicename 
		AND seg.segmentname = adm.segmentname 
		AND di.servicename  = seg.servicename 
		AND di.segmentname  = seg.segmentname 
		AND di.dataitemname = adm.dataitemname) a 
      GROUP  BY a.ilbocode,a.taskname,a.tabname,a.controlid 
      ORDER  BY 1,2,3,5,4 


      /*Pivotfields*/ 
      SELECT 
				a.ilbocode , 
				pagename, 
				controlid, 
				viewname, 
				rowlabel, 
				columnlabel, 
				fieldvalue, 
				rowlabelseq, 
				columnlabelseq, 
				valueseq, 
				UPPER(LEFT(valuefunction,1))+LOWER(SUBSTRING(valuefunction,2,LEN(valuefunction))) 'valuefunction'
      FROM   #fw_req_ilbo_pivot_fields a(nolock), 
             #ilbolist temp(nolock) 
      WHERE  a.ilbocode = temp.ilbocode 

	  /*Rich Extjs Controls*/
      SELECT 
			  a.uiname, 
			  a.taskname, 
			  a.servicename, 
			  a.segmentname, 
			  a.sectiontype, 
			  a.controlid    
      FROM    #fw_extjs_control_dtl a   (nolock), 
             #ilbolist			   temp(nolock) 
      WHERE  a.uiname = temp.ilbocode 

      /*zoom task details*/ 
      SELECT DISTINCT 
		LOWER(LTRIM(RTRIM(a.parentilbocode)))'parentilbocode', 
        LOWER(LTRIM(RTRIM(a.childilbocode))) 'childilbocode', 
        LOWER(LTRIM(RTRIM(a.taskname)))      'taskname', 
        LOWER(LTRIM(RTRIM(a.controlid)))     'controlid' 
      FROM   #fw_req_ilbo_data_use a(nolock), 
             #fw_req_ilbo		   b(nolock), 
             #ilbolist			   temp(nolock) 
      WHERE a.parentilbocode = temp.ilbocode 
        AND a.childilbocode  = b.ilbocode 
        AND b.ilbotype		 = 9 

      /*zoom ilbo combo controls*/ 
      SELECT DISTINCT 
	    parentilbocode	 = LOWER(LTRIM(RTRIM(du.parentilbocode))), 
        childilbocode	 = LOWER(LTRIM(RTRIM(du.childilbocode))), 
        parentcontrolid  = LOWER(LTRIM(RTRIM(du.controlid))), 
		parentviewname	 = LOWER(LTRIM(RTRIM(du.viewname))), 
        childcontrolid	 = LOWER(LTRIM(RTRIM(c.controlid))), 
        childviewname	 = LOWER(LTRIM(RTRIM(v.viewname))), 
        childdisplayflag = LOWER(LTRIM(RTRIM(v.displayflag))), 
        childcontroltype = LOWER(LTRIM(RTRIM(c.type))) 
      FROM   #fw_req_ilbo_data_use			du (nolock), 
             #fw_req_ilbo_data_publish		dp (nolock), 
             #fw_req_ilbo_control			c  (nolock), 
             #fw_req_ilbo_view				v  (nolock), 
             #fw_req_ilbo					i  (nolock), 
             #fw_req_ilbo_control_property icp (nolock), 
             #ilbolist					   temp(nolock) 
	  WHERE du.parentilbocode = temp.ilbocode 
        AND du.childilbocode  = i.ilbocode 
        AND i.ilbotype		  = 9 
        AND du.childilbocode  = dp.ilbocode 
        AND du.dataitemname   = dp.dataitemname 
        AND c.ilbocode        = du.childilbocode 
        AND c.controlid		  = dp.controlid 
        AND c.type			  = 'rscomboctrl' 
        AND c.ilbocode		  = v.ilbocode 
        AND c.controlid		  = v.controlid 
        AND icp.ilbocode      = du.parentilbocode 
        AND icp.controlid	  = du.controlid 
        AND icp.propertyname  = 'columntype' 
        AND icp.value		  = 'combobox' 

	/*Task Callout*/
	SELECT distinct 
	a.component_name'componentname', 
	a.activity_name'activityname', 
	a.ui_name'uiname', 
	task_name'taskname', 
	calloutname,
	calloutmode 
	FROM    #de_fw_des_publish_task_callout a(nolock), 
			#ilbolist					    temp(nolock) 
	WHERE  a.component_name = temp.component_name
	AND    a.activity_name  = temp.activity_name
	AND    a.ui_name		= temp.ilbocode 

	SELECT distinct 
	a.component_name 'componentname', 
	a.activity_name 'activityname', 
	a.ui_name 'uiname', 
	task_name 'taskname', 
	calloutname, 
	a.segmentname, 
	instanceflag, 
	segmentsequence,
	segmentflowattribute ,
	CASE b.combofill WHEN 1 THEN 'true' ELSE 'false' END 'combofilling' 
	FROM  #ilbolist								   temp(nolock) ,
		  #de_fw_des_publish_task_callout_segement a(nolock) left outer join
		  #fw_des_task_segment_attribs		       b(nolock)
	ON     a.ui_name		= b.ilbocode 
	AND	   a.task_name		= b.taskname
	AND	   a.segmentname	= b.segmentname
	WHERE  a.component_name = temp.component_name
	AND    a.activity_name  = temp.activity_name
	AND    a.ui_name		= temp.ilbocode 

	SELECT distinct 
	a.component_name 'componentname', 
	a.activity_name 'activityname',
	a.ui_name'uiname', 
	task_name'taskname', 
	calloutname, 
	segmentname, 
	dataitemname, 
	flowattribute,
	controlid,
	viewname 
	FROM  #de_fw_des_publish_task_callout_dataitem a(nolock), 
		  #ilbolist								   temp(nolock) 
	WHERE  a.component_name = temp.component_name
	AND    a.activity_name  = temp.activity_name
	AND    a.ui_name		= temp.ilbocode 

	/*Sync view*/
	SELECT 
	LOWER(LTRIM(RTRIM(a.activity_name)))'activity_name',
	LOWER(LTRIM(RTRIM(a.ui_name)))'ui_name',
	LOWER(LTRIM(RTRIM(a.syncview_controlid))) 'filter_controlid',
	LOWER(LTRIM(RTRIM(a.filter_viewname))) 'filter_viewname',
	LOWER(LTRIM(RTRIM(a.le_viewname))) 'list_viewname' 
	FROM de_published_sync_view_fn  ( @customer_name,@project_name,@ecrno) a, 
		 #ilbolist temp(nolock) 
	WHERE  a.activity_name  = temp.activity_name COLLATE database_default
	AND    a.ui_name		= temp.ilbocode COLLATE database_default
	order by seqno

			
      SET nocount OFF 
  END 











