SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveBillType]
(@BillTypeId  INT         = NULL,
 @Description VARCHAR(50)
)
AS
     BEGIN
         IF(@BillTypeId IS NULL)
             BEGIN
                 INSERT INTO [dbo].BillTypes(Description)
             VALUES(@Description);
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].BillTypes
                   SET
                       Description = @Description
                 WHERE BillTypeId = @BillTypeId;
         END;
     END;
GO