SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetMissingTrpInformation]
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
			   trp.Email,
               trp.USD, 
               trp.Fee1, 
               trp.CreatedOn, 
               trp.CreatedBy, 
               trp.CardPayment, 
               trp.CardPaymentFee, 
               trp.AgencyId, 
               trp.FileIdName, 
               trp.TrpFee,
			   ISNULL(trp.TelIsCheck , CAST(0 AS BIT)) TelIsCheck,
			   ISNULL(trp.LaminationFee, 0 )LaminationFee ,
			   trp.FileIdNamePermit,
			   trp.FileIdNameTrpT,
			   trp.FileIdNameTrpTBack 
        FROM TRP trp
             LEFT JOIN PermitTypes pt ON trp.PermitTypeId = pt.PermitTypeId
        WHERE CAST(trp.CreatedOn AS DATE) <= CAST(@CreationDate AS DATE)
              AND trp.AgencyId = @AgencyId
              AND (trp.CreatedBy = @UserId
                   OR @UserId IS NULL)
				   AND((trp.ClientName = ''OR trp.ClientName IS NULL) 
				     OR( trp.PermitNumber = ''OR trp.PermitNumber IS NULL)
					 OR( trp.PermitTypeId <= 0 OR trp.PermitTypeId IS NULL))
				   --Código comentado en la tarea 4431 ya que apartir de la fecha nigún  file es requerido para completar un trp
				   --OR(trp.FileIdNamePermit = ''OR trp.FileIdNamePermit IS NULL)--File Permit
				   --OR( trp.FileIdName = ''OR trp.FileIdName IS NULL)--File identification
				   --OR( trp.FileIdNameTrpT = ''OR trp.FileIdNameTrpT IS NULL)--File title front
				   --OR( trp.FileIdNameTrpTBack = ''OR trp.FileIdNameTrpTBack IS NULL)--File title back
				   --OR( trp.FileIdNameProofAddress = ''OR trp.FileIdNameProofAddress IS NULL)--File ProofAddress
				   --OR( trp.PermitTypeId <= 0 OR trp.PermitTypeId IS NULL))
    END;

GO