SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCompanyInformation]
AS
     BEGIN
         SELECT * ,
                ReceiptLogo AS FileImageName
--                CompanySeoSign AS FileImageNameSeo
		 FROM CompanyInformation
		LEFT JOIN ZipCodes ON CompanyInformation.ZipCode = ZipCodes.ZipCode 
                
     END;

GO