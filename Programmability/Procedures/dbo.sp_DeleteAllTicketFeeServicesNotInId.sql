SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteAllTicketFeeServicesNotInId]
(@TicketFeeServiceIdList VARCHAR(1000),
 @Date                   DATE,
 @UserId              INT
)
AS
     BEGIN
         DELETE FROM TicketFeeServices
         WHERE TicketFeeServiceId NOT IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@TicketFeeServiceIdList)
         )
         AND (CAST(CreationDate AS DATE) = CAST(@Date AS DATE))
	      AND CreatedBy = @UserId;
     END;
GO