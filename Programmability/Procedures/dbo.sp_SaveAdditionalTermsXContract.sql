SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		JT
-- Description:	Save an additional contract by contract id 
-- =============================================
CREATE PROCEDURE [dbo].[sp_SaveAdditionalTermsXContract] @ContractId     INT,                                                
                                                @Terms          VARCHAR(3000), 
                                                @TermsXContractId INT = NULL
AS
    BEGIN
        IF(@TermsXContractId IS NULL)
            BEGIN
INSERT INTO [dbo].TermsXContract ([ContractId],
Terms)
	VALUES (@ContractId, @Terms);

            END;
ELSE
BEGIN
UPDATE [dbo].TermsXContract
SET Terms = @Terms
WHERE TermsXContractId = @TermsXContractId;
            END;
END;
GO