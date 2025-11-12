SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllTRP]
(@CreationDate DATE = NULL, 
 @AgencyId     INT, 
 @UserId       INT  = NULL
)
AS
    BEGIN
        SELECT trp.TRPId, 
               trp.PermitTypeId, 
               pt.Description AS DescriptionPermitTypes, 
			   pt.Code AS PermitTypeCode,                
               trp.PermitNumber, 
               trp.ClientName, 
               trp.Telephone,
			   trp.Telephone as TelephoneSaved,
			   trp.Email,
               trp.USD, 
               trp.Fee1, 
			   trp.Cash,
               trp.CreatedOn, 
               trp.CreatedBy, 
               trp.CardPayment, 
               trp.CardPaymentFee, 
               trp.AgencyId, 
               trp.FileIdName, 
			   trp.FileIdName2, 
               trp.TrpFee,
			   ISNULL(trp.TelIsCheck , CAST(0 AS BIT)) TelIsCheck,
			   ISNULL(trp.LaminationFee, 0 )LaminationFee ,
			   trp.FileIdNamePermit,
			   trp.FileIdNameTrpT,
			   trp.FileIdNameTrpTBack ,
			   trp.FileIdNameProofAddress,
			    trp.UpdatedOn,
				trp.UpdatedBy,
         usu.Name UpdatedByName,
		 v.Code as VinCodeSaved,
		 v.Description as VinDescription,
		 trp.VinNumber,
		 trp.VinPertmitTrpId,
		 trp.VinNumber as VinNumberSaved,
     cast(trp.HasId2 AS bit) HasId2,
     cast(trp.HasProofAddress as bit)HasProofAddress,
     cast( IdExpirationDate as date) AS IdExpirationDate,
     FORMAT(IdExpirationDate, 'MM-dd-yyyy', 'en-US')	IdExpirationDateFormat 
    FROM TRP trp
		LEFT JOIN Users usu ON trp.UpdatedBy = usu.UserId
             LEFT JOIN PermitTypes pt ON trp.PermitTypeId = pt.PermitTypeId
			 left join VinPertmitStatus v on v.VinPertmitTrpId = trp.VinPertmitTrpId
        WHERE CAST(trp.CreatedOn AS DATE) = CAST(@CreationDate AS DATE)
              AND trp.AgencyId = @AgencyId
              AND (trp.CreatedBy = @UserId
                   OR @UserId IS NULL);
    END;



GO