SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Creation date: 1-febrero-2024
-- Creation By : Felipe 
-- Task :4990  Agregar configuracion Use smart safe deposit a los providers Money Transfer
CREATE PROCEDURE [dbo].[sp_GetAllproviderCommission] 
(@ProviderId INT = NULL,
@IsForex BIT = NULL,
@IsMoneyOrder BIT = NULL,
@ProviderTypeCode VARCHAR(4))
AS
    BEGIN

   IF(@ProviderTypeCode = 'C02' AND @IsForex = CAST(1 as BIT) )
             BEGIN

    SELECT top 1 * FROM Forex f
    LEFT JOIN ProviderCommissionPayments pcp ON f.ProviderId = pcp.ProviderId
    WHERE f.Usd > 0 AND f.ProviderId = @ProviderId AND  f.Usd > ISNULL( pcp.Usd,0 ) 
--                AND pcp.IsForex =  CAST(1 as BIT) 

         END;

       
    END;
GO