SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllBillTypes]
AS
     BEGIN
         SELECT BillTypeId,
                Description
         FROM BillTypes
         ORDER BY Description;
     END;
GO