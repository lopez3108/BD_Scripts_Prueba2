SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetFirstChecByRountingByAcount]
(    @Account VARCHAR(50) = NULL
,
    @Routing VARCHAR(50) = NULL
)
AS
    BEGIN
        SELECT TOP 1 ct.CheckTypeId , ct.Description  
       
        FROM Checks c
        INNER JOIN dbo.CheckTypes ct ON c.CheckTypeId = ct.CheckTypeId
        WHERE C.Account =  @Account
              AND C.Routing =  @Routing
    END;
GO