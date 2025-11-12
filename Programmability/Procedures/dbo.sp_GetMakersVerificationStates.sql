SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetMakersVerificationStates] 
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT  u.UrlXStateId,
            UPPER(u.StateAbre + ' - ' +u.State) StateAbre     
        FROM dbo.UrlsXState u
      ORDER BY U.State ASC
    END;
GO