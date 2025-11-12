SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SearchFlexxizCode] @Code varchar(4)
AS
    BEGIN
       SELECT FlexxizCode from Agencies   WHERE FlexxizCode = @Code
              OR @Code IS NULL;
 
    END;
GO