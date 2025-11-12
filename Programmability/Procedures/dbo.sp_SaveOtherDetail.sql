SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveOtherDetail](@OtherDetailId INT = NULL,
                                            @OtherServiceId INT,
                                            @CreationDate DATETIME,
                                            @Usd DECIMAL(18, 2),
                                            @Concept VARCHAR(70) = NULL,
                                            @CreatedBy INT,
                                            @AgencyId INT,
                                            @IdCreated INT OUTPUT,
                                            @CardPayment BIT,
                                            @CardPaymentFee DECIMAL(18, 2),
                                            @UpdatedBy INT = NULL,
                                            @UpdatedOn DATETIME = NULL,
                                            @ValidatedBy INT = NULL,
                                            @ValidatedOn DATETIME = NULL,
                                            @Cash DECIMAL(18, 2) = NULL
)
AS
BEGIN
    IF (@OtherDetailId IS NULL)
        BEGIN
            INSERT INTO [dbo].[OthersDetails]
            (OtherServiceId,
             CreationDate,
             Usd,
             Concept,
             CreatedBy,
             AgencyId,
             CardPayment,
             CardPaymentFee,
             UpdatedBy,
             UpdatedOn,
             Cash)
            VALUES (@OtherServiceId,
                    @CreationDate,
                    @Usd,
                    @Concept,
                    @CreatedBy,
                    @AgencyId,
                    @CardPayment,
                    @CardPaymentFee,
                    @UpdatedBy,
                    @UpdatedOn,
                    @Cash);
            SET @IdCreated = @@IDENTITY;
        END;
    ELSE
        BEGIN
            UPDATE [dbo].OthersDetails
            SET Concept        = @Concept,
                Usd            = @Usd,
                CardPayment    = @CardPayment,
                CardPaymentFee = @CardPaymentFee,
                UpdatedBy      = @UpdatedBy,
                UpdatedOn      = @UpdatedOn,
                ValidatedBy    = @ValidatedBy,
                ValidatedOn    = @ValidatedOn,
                Cash           = @Cash
            WHERE OtherDetailId = @OtherDetailId;
            SET @IdCreated = 0;
        END;
END;
GO