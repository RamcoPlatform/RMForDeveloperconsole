create procedure vw_netgen_reset_codegen_status
as
begin
	update engg_devcon_codegen_schedule_dtls
	set RequestStatus = 'pending'
	where RequestStatus in ('inprogress', 'running')

	update engg_devcon_codegen_status_dtls
	set codegenstatus = 'pending'
	where codegenstatus in ('inprogress','running')
end