SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Create: Felipe Oquendo
-- Date: 25-10-2023
-- Task: 5452

-- 2024-08-28 DJ/6014: Added insurance provider (C26)

CREATE PROCEDURE [dbo].[sp_GetProviderRepeatByCodProviderByCompanyId]
(
                 @Code varchar(10) = NULL
)
AS
BEGIN
  SELECT top 1 pt.ProviderTypeId, pt.Code, pt.Description

  FROM Providers

       INNER JOIN
       ProviderTypes pt
       ON pt.ProviderTypeId = Providers.ProviderTypeId

  WHERE @Code = pt.Code AND ( @Code != 'C01' AND   @Code != 'C02' AND  @Code != 'C14' AND @Code != 'C26' )

END;





GO