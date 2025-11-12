SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveTRPFiles]
(@TRPId          INT            = NULL,
 @FileIdName     VARCHAR(1000)  = NULL,
 @FileIdNameTrpT     VARCHAR(1000)  = NULL,
  @FileIdNameTrpTBack     VARCHAR(1000)  = NULL,
 @FileIdNamePermit     VARCHAR(1000)  = NULL,
  @IdCreated      INT OUTPUT
)
AS
     BEGIN
        
             BEGIN
                 UPDATE [dbo].[TRP]
                   SET
                      
                       FileIdName = @FileIdName,                  
					   FileIdNamePermit = @FileIdNamePermit,  
					   FileIdNameTrpT = @FileIdNameTrpT,  
					   FileIdNameTrpTBack = @FileIdNameTrpTBack 
                 WHERE TRPId = @TRPId;
                 SET @IdCreated = @TRPId;
         END;
     END;
GO