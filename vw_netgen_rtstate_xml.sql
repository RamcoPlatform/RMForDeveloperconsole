
CREATE procedure vw_netgen_rtstate_xml
	@customer	varchar(60),  
	@project	varchar(60),  
	@process	varchar(60),  
	@component varchar(60),  
	@ecrno		varchar(60),
	@act		varchar(60),
	@ui			varchar(60)  
as  
begin  
	set nocount on 
  
	Declare @basecount int
	--state details for controls  
	--PLF2.0_15017 code change for including control type **starts**
	select distinct  
			sc.activity_name,  sc.ui_name,  state_id,  'Control'  as [type], ct.base_ctrl_type as control_type,   
			control_id,  lower(visible) as visible,  lower([enable]) as [enable]  
	from	de_published_ui_state_control sc(nolock)  
	inner 
	join  	de_published_ui_control c(nolock)    -- PLF2.0_16546
	on		c.customer_name		=	sc.customer_name  
	and		c.project_name		=	sc.project_name
	and		c.ecrno					=	sc.ecrno  
	and		c.process_name		=	sc.process_name  
	and		c.component_name	=	sc.component_name  
	and		c.activity_name		=	sc.activity_name  
	and		c.ui_name			=	sc.ui_name
	and		c.page_bt_synonym		=	  sc.page_bt_synonym
	and		c.section_bt_synonym		=	  sc.section_bt_synonym
	and		c.control_bt_synonym=	sc.control_bt_synonym  
	inner 
	join	es_comp_ctrl_type_mst ct(nolock)
	on		ct.customer_name	=	c.customer_name
	and		ct.project_name		=	c.project_name
	and		ct.process_name		=	c.process_name
	and		ct.component_name	=	c.component_name
	and		ct.ctrl_type_name	=	c.control_type
	where	sc.customer_name	= @customer  
	and		sc.project_name		= @project  
	and		sc.process_name		= @process  
	and		sc.component_name	= @component  
	and		sc.ecrno			= @ecrno  
	and		sc.activity_name	= @act
	and		sc.ui_name			= @ui
	--group 	by		sc.state_id, c.control_id,ct.base_ctrl_type, sc.visible, sc.[enable], sc.activity_name, sc.ui_name  
	--PLF2.0_15017 code change for including control type **ends**

	--PLF2.0_15017 code change to fetch enable property starts
	--state details for grid columns  
	select	sc.activity_name,  sc.ui_name,  sc.state_id,  'Column'  as [type], gc.control_id,  gc.view_name,  
			sc.visible , sc.enable 
	from	de_published_ui_state_column sc(nolock) inner join  
			de_published_ui_grid gc(nolock)  
	on		sc.customer_name	=  gc.customer_name  
	and		sc.project_name		=  gc.project_name
	and		sc.ecr_no				=  gc.ecrno
	and		sc.process_name		=  gc.process_name  
	and		sc.component_name	=  gc.component_name  
	and		sc.activity_name	=  gc.activity_name  
	and		sc.ui_name			=  gc.ui_name
	and		sc.page_bt_synonym			=  gc.page_bt_synonym
	and		sc.section_bt_synonym			=  gc.section_bt_synonym  
	and		sc.control_bt_synonym =  gc.control_bt_synonym  
	and		sc.column_bt_synonym =  gc.column_bt_synonym      
	where	sc.customer_name	= @customer  
	and		sc.project_name		= @project  
	and		sc.ecr_no			= @ecrno  
	and		sc.process_name		= @process  
	and		sc.component_name	= @component  
	and		sc.activity_name	= @act
	and		sc.ui_name			= @ui
	order by  sc.activity_name, sc.ui_name,  sc.state_id, gc.control_id,  gc.view_name  
	--PLF2.0_15017 code change to fetch enable property ends

	--Code added for tabcontrol addition in xml 

	select @basecount = count(page_bt_synonym) 
	from   de_published_ui_page(nolock)  
	where	customer_name	= @customer  
	and		project_name	= @project  
	and		ecrno			= @ecrno   
	and		process_name	= @process  
	and		component_name	= @component  
	and		activity_name	= @act
	and		ui_name			= @ui
	and		page_bt_synonym <> '[mainscreen]'
	

	select activity_name,  ui_name,  state_id, count(page_bt_synonym) as 'statecount'
    into #de_published_ui_state_page_count
	from   de_published_ui_state_page(nolock)  
	where	customer_name	= @customer  
	and		project_name	= @project  
	and		ecr_no			= @ecrno  
	and		process_name	= @process  
	and		component_name	= @component  
	and		activity_name	= @act
	and		ui_name			= @ui
	and 	visible  		=  'N'
	group by activity_name,  ui_name,  state_id 
	
	select activity_name,  ui_name,  state_id, count(page_bt_synonym) as 'statecount'
    into #de_published_ui_state_page_count_yes
	from   de_published_ui_state_page(nolock)  
	where	customer_name	= @customer  
	and		project_name	= @project  
	and		ecr_no			= @ecrno   
	and		process_name	= @process  
	and		component_name	= @component  
	and		activity_name	= @act
	and		ui_name			= @ui
	and 	visible  		=  'Y'
	group by activity_name,  ui_name,  state_id 	

	--state details for sections  
	select	activity_name, ui_name,  state_id,  'Control' as [type],  section_bt_synonym,  visible,  [enable],  
			collapse  
	from	de_published_ui_state_section(nolock)  
	where	customer_name	= @customer  
	and		project_name	= @project  
	and		ecrno			= @ecrno  
	and		process_name	= @process  
	and		component_name	= @component  
	and		activity_name	= @act
	and		ui_name			= @ui
	union
	select distinct  a.activity_name,  a.ui_name,  a.state_id,  'Control' as [type],  'tabcontrol',  'n',  
		'n',  'n'    
	from   de_published_ui_state_page		 a(nolock) , 
		   #de_published_ui_state_page_count b(nolock)
	where	a.customer_name		= @customer  
	and		a.project_name		= @project  
	and		a.ecr_no			= @ecrno   
	and		a.process_name		= @process  
	and		a.component_name	= @component  
	and		a.activity_name		= @act
	and		a.ui_name			=  @ui 
	and     a.activity_name		=  b.activity_name  
	and		a.ui_name			=  b.ui_name  
	and		a.state_id			=  b.state_id
	and		b.statecount		=	@basecount
	
	union
	select distinct  a.activity_name,  a.ui_name,  a.state_id,  'Control' as [type],  'tabcontrol',  'y',  
		'y',  'n'    
	from   de_published_ui_state_page a(nolock),  
		   #de_published_ui_state_page_count_yes b (nolock)
	where	a.customer_name	= @customer  
	and		a.project_name	= @project  
	and		a.ecr_no		= @ecrno  
	and		a.process_name	= @process  
	and		a.component_name= @component  
	and		a.activity_name	= @act
	and		a.ui_name		= @ui 
	and 	a.activity_name	=  b.activity_name  
	and		a.ui_name		=  b.ui_name  
	and		a.state_id		=  b.state_id
	
		

    
  --state details for page

	select  activity_name,  ui_name,  state_id,  'Control' as [type],  page_bt_synonym,  visible,  
		[enable],  focus    
	from   de_published_ui_state_page a (nolock)  
	where	customer_name	= @customer  
	and		project_name	= @project  
	and		ecr_no			= @ecrno  
	and		process_name	= @process  
	and		component_name	= @component  
	and		activity_name	= @act
	and		ui_name			= @ui 
	and not exists (select 'K' from #de_published_ui_state_page_count b (nolock) 
				where 	a.activity_name		=  b.activity_name  
				and		a.ui_name			=  b.ui_name  
				and		a.state_id			=  b.state_id
				and		b.statecount		=	@basecount )
	order by 	case when visible = 	'Y'  then 1 else 2 end 


drop table #de_published_ui_state_page_count

	
end 




