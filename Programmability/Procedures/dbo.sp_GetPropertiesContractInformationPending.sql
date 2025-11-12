SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-09-05JF/6722: Contracts deben poder quedar en status PENDING cuando se crean


CREATE PROCEDURE [dbo].[sp_GetPropertiesContractInformationPending]
AS
    BEGIN


SELECT COUNT( c.ContractId)
  FROM Contract c
  WHERE c.IsPendingInformation = 1;


    END;
GO