SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-08-26 DJ/6016: Get the Insurance policy types

CREATE PROCEDURE [dbo].[sp_GetPolicyTypes] 
AS

BEGIN
 
SELECT [PolicyTypeId]
      ,[Description]
  FROM [dbo].[PolicyType]









END

GO