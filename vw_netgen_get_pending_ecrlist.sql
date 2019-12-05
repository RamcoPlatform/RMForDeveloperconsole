alter procedure vw_netgen_get_pending_ecrlist
as
	begin
		select top 1 * from engg_devcon_codegen_schedule_dtls(nolock) where requeststatus ='pending' order by seqno asc
	end
