--compile this in mailer backend alone
create procedure vw_netgen_insert_mailer_record
@Guid						engg_guid,
@Request_ID					engg_name,
@CustomerName				engg_name,
@ProjectName				engg_name,
@ComponentName				engg_name,
@Ecrno						engg_name,
@CodeGenClient				engg_name,
@CodegenPath				engg_desc,
@sharePath					engg_desc,
@Requeststart_datetime		engg_datetime,
@Requested_user				engg_user,
@Remarks					engg_description,
@CodeGenStartTime			engg_datetime,
@CodeGenEndTime				engg_datetime,
@CodeGenStatus				engg_name,
@MailTo						engg_documentation,
@MailCC						engg_documentation,
@MailBCC					engg_documentation,
@MailStatus					engg_flag,
@RequestStatus				engg_name,
@EcrStatus					engg_name,
@ModelServer				engg_name,
@ModelDatabase				engg_name
as
begin
	delete 
	from	engg_devcon_codegen_Admin_status
	where	Guid				=	@Guid
	and		Request_ID			=	@Request_ID
	and		ModelServer			=	@ModelServer
	and		ModelDatabase		=	@ModelDatabase
	and		CustomerName		=	@CustomerName
	and		ProjectName			=	@ProjectName
	and		Ecrno				=	@Ecrno


	insert into engg_devcon_codegen_Admin_status
	(
		Guid,
		Request_ID,
		CustomerName,
		ProjectName,
		ComponentName,
		Ecrno,
		CodeGenClient,
		CodegenPath,
		sharePath,
		Requeststart_datetime,
		Requested_user,
		Remarks,
		CodeGenStartTime,
		CodeGenEndTime,
		CodeGenStatus,
		MailTo,
		MailCC,
		MailBCC,
		MailStatus,
		RequestStatus,
		EcrStatus,
		ModelServer,
		ModelDatabase
	)
	values
	(
		@Guid,
		@Request_ID,
		@CustomerName,
		@ProjectName,
		@ComponentName,
		@Ecrno,
		@CodeGenClient,
		@CodegenPath,
		@sharePath,
		@Requeststart_datetime,
		@Requested_user,
		@Remarks,
		@CodeGenStartTime,
		@CodeGenEndTime,
		@CodeGenStatus,
		@MailTo,
		@MailCC,
		@MailBCC,
		@MailStatus,
		@RequestStatus,
		@EcrStatus,
		@ModelServer,
		@ModelDatabase
	)
end

