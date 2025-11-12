SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetMakersVerification] @Entity      VARCHAR(500) = NULL, 
                                                 @UrlXStateId INT          = NULL
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT DISTINCT 
               UPPER(u.Entities) Entities, 
              
               u.Link ,
			   Upper(u.State) State,
			   UPPER(u.StateAbre + ' - ' +u.State) StateAbre     
        FROM dbo.UrlsXState u
        WHERE(u.UrlXStateId = @UrlXstateId
              OR @UrlXstateId IS NULL)
             AND (u.Entities LIKE '%' + @Entity + '%'
                  OR @Entity IS NULL);
    END;
GO