create procedure vw_netgen_update_codegen_status
@RequestID			engg_name,
@Status				engg_name,
@CodegenPath		engg_desc,
@SharePath			engg_desc,
@CodegenClient		engg_name,
@TableKeyword		engg_name,
@StartOrEnd			engg_name
as
	begin
		declare @guid engg_guid
		If UPPER(@TableKeyword) = 'SCHEDULE' 
			begin
				select	@guid			=	guid,
						@CodegenPath	=	case when isnull(@CodegenPath,'')='' then codegenpath else @CodegenPath end,
						@SharePath		=	case when isnull(@SharePath,'')='' then sharePath else @SharePath end,
						@CodegenClient	=	CodeGenClient
				from	engg_devcon_codegen_schedule_dtls	
				where	Request_ID		=	@RequestID
				
				update	engg_devcon_codegen_options
				set		generationpath	=	@CodegenPath
				where	guid			=	@guid
				
				update	engg_devcon_codegen_schedule_dtls
				set		RequestStatus	=	@Status,
						CodegenPath		=	@CodegenPath,
						sharePath		=	@SharePath,
						CodeGenClient	=	@CodegenClient
				where	Request_ID		=	@RequestID
			end
		else
			begin				
				If UPPER(@StartOrEnd) = 'END'
					begin
						update	engg_devcon_codegen_status_dtls
						set		CodeGenStatus	=	@Status,
								EcrStatus		=	@Status,
								CodeGenEndTime	=	getdate()
						where	Request_ID		=	@RequestID

						select	isnull(Guid,'')									'Guid',
								isnull(Request_ID,'')							'Request_ID',
								isnull(CustomerName,'')							'CustomerName',
								isnull(ProjectName,'')							'ProjectName',
								isnull(ComponentName,'')						'ComponentName',
								isnull(Ecrno,'')								'Ecrno',
								isnull(CodeGenClient,'')						'CodeGenClient',
								isnull(CodegenPath,'')							'CodegenPath',
								isnull(sharePath,'')							'sharePath',
								CONVERT(VARCHAR(19), Requeststart_datetime, 120) 'Requeststart_datetime',
								isnull(Requested_user,'')						'Requested_user',
								isnull(Remarks, '')								'Remarks',
								isnull(Instance, '')							'Instance',
								CONVERT(VARCHAR(19), CodeGenStartTime, 120)		'CodeGenStartTime',
								CONVERT(VARCHAR(19), CodeGenEndTime, 120)		'CodeGenEndTime',
								isnull(CodeGenStatus,'')						'CodeGenStatus',
								isnull(MailTo,'')								'MailTo',
								isnull(MailCC,'')								'MailCC',
								isnull(MailBCC,'')								'MailBCC',
								isnull(MailStatus,'')							'MailStatus',
								isnull(RequestStatus,'')						'RequestStatus',
								isnull(EcrStatus,'')							'EcrStatus' 
						from	engg_devcon_codegen_schedule_dtls_vw(nolock)
						where	Request_ID = @RequestID

					end
				Else
					begin
						update	engg_devcon_codegen_status_dtls
						set		CodeGenStatus		=	@Status,
								EcrStatus			=	@Status,
								CodeGenStartTime	=	getdate()
						where	Request_ID			=	@RequestID
					end
			end
	end