SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetProviderCommissionPaymentTypes]
AS 

BEGIN

SELECT [ProviderCommissionPaymentTypeId]
      ,[Code]
      ,[Description]
  FROM [dbo].[ProviderCommissionPaymentTypes]
  -- Hiden to check if remove affects something
  WHERE Code <> 'CODE09'

	END
GO