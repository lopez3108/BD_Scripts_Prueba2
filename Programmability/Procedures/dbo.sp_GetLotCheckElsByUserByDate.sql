SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetLotCheckElsByUserByDate]
                                          @UserId INT      = NULL,
                                          @Date      DATETIME, 
										  @AgencyToId  INT= NULL,
										  @IsAdmin BIT = NULL
										  --@PaymentChecksAgentToAgentId  INT= NULL
AS
     BEGIN
    
	   SELECT TOP 1 ISNULL(LotNumber, 0 ) LotNumber,PaymentChecksAgentToAgentId
		 FROM [PaymentChecksAgentToAgent] WHERE [CreatedBy] = @UserId AND 
		 CAST([CreationDate] AS DATE) = CAST(@Date AS DATE)
		 AND ToAgency  = @AgencyToId AND IsFromAdmin = @IsAdmin
		 --AND (PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId OR @PaymentChecksAgentToAgentId IS NULL)
 ORDER BY LotNumber DESC
  

	 END
GO