SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCountExtraFundCashAgencyToAgency]
(@Creationdate   DATE, 
 @CreatedBy       INT, 
 @FromAgencyId         INT
)
AS
    BEGIN
       
     
         SELECT (   SELECT ISNULL(COUNT(*), 0) Suma
            FROM dbo.ExtraFundAgencyToAgency e
                 INNER JOIN Users ua ON ua.UserId = e.AssignedTo
            WHERE(CAST(e.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
                 AND (e.FromAgencyId = @FromAgencyId)
				   AND ((e.CreatedBy = @CreatedBy)) )
				   + (   SELECT ISNULL(COUNT(*), 0) Suma
            FROM dbo.ExtraFundAgencyToAgency e
                 INNER JOIN Users ua ON ua.UserId = e.AssignedTo
            WHERE(CAST(e.AcceptedDate AS DATE) = CAST(@CreationDate AS DATE))
                 AND (e.ToAgencyId = @FromAgencyId)
				   AND ((e.AcceptedBy = @CreatedBy)) )
				
    END;

 
GO