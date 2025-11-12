SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReturnsELSById]
 (
 @ReturnsELSId int


    )
AS 

BEGIN

SELECT 
dbo.ReturnsELS.*, 
dbo.ReturnELSStatus.Code AS StatusCode

FROM     dbo.ReturnsELS INNER JOIN                         
                  dbo.ReturnELSStatus ON dbo.ReturnELSStatus.ReturnsELSStatusId = dbo.ReturnsELS.ReturnsELSStatusId 
                
  WHERE 
  dbo.ReturnsELS.ReturnsELSId =  @ReturnsELSId


	END

GO