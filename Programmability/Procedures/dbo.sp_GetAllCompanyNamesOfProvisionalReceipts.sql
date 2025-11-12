SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllCompanyNamesOfProvisionalReceipts]
              @AgencyId    INT  = NULL
AS
     SET NOCOUNT ON;
     BEGIN
         SELECT DISTINCT UPPER(CompanyName) CompanyName
         FROM [dbo].ProvisionalReceipts
	     WHERE(AgencyId = @AgencyId
                   OR @AgencyId IS NULL)
         --ORDER BY CompanyName ASC;
     END;
GO