SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertiesConfiguration]

AS

BEGIN

  SELECT *
   -- [PropertiesConfigurationId]
   --,[FeeDue]
   --,Dayslate
   --,MonthlyPaymentDate
  FROM [dbo].[PropertiesConfiguration]

END
GO