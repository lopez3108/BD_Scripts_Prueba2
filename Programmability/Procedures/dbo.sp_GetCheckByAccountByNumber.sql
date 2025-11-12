SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCheckByAccountByNumber]
(@Number  VARCHAR(50), 
 @Account VARCHAR(50),
 @CheckElsId INT  = NULL,
  @CheckId INT  = NULL
 
)
AS
    BEGIN
        SELECT TOP 1 CheckId
        FROM [Checks]
        WHERE Account = @Account
              AND Number =  @Number AND  ([Checks].CheckId != @CheckId OR @CheckId is NULL) 
        UNION ALL
        SELECT TOP 1 CheckElsId
        FROM ChecksEls r
        WHERE r.Account =  @Account
              AND r.CheckNumber =  @Number AND (r.CheckElsId != @CheckElsId OR @CheckElsId is NULL)
			  --AND (r.CheckId != @CheckId OR @CheckId is NULL) 
    END;


GO