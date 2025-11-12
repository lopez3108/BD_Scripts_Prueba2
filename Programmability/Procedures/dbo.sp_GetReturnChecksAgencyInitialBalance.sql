SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReturnChecksAgencyInitialBalance]
AS
     BEGIN
         SELECT a.AgencyId,
                a.Code+' - '+a.Name AS Agency,
                ISNULL(InitialBalance, 0) AS InitialBalance
         FROM dbo.Agencies a
              LEFT JOIN ReturnedChecksxAgencyInitialBalances r ON a.AgencyId = r.AgencyId;
     END;
GO