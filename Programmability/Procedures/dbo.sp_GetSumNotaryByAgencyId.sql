SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumNotaryByAgencyId] @AgencyId  INT,
                                                     @CreationDate DATE = NULL,
                                                     @UserId    INT =NULL
AS
     BEGIN
         SELECT ISNULL(SUM(e.Usd), 0) Suma
         FROM Notary E
              INNER JOIN Agencies a ON e.AgencyId = a.AgencyId
              INNER JOIN Users u ON e.CreatedBy = u.UserId
         WHERE e.AgencyId = @AgencyId
               AND (CAST(e.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
                    OR @CreationDate IS NULL)
               AND (CreatedBy = @UserId OR @UserId IS NULL);
     END;
GO