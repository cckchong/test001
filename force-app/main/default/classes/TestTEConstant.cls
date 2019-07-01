@isTest 
public class TestTEConstant{
    
    @isTest 
    public static void testConstant() {
        TEConstant cons = new TEConstant();
        Integer step;
        step = TEConstant.getExpenseStep(TEConstant.STATUS_DRAFT);
        step = TEConstant.getExpenseStep(TEConstant.STATUS_NOT_SUBMITTED);
        step = TEConstant.getExpenseStep(TEConstant.STATUS_PENDING_APPROVAL);
        step = TEConstant.getExpenseStep(TEConstant.STATUS_PENDING_FIN_Confirmation);
        step = TEConstant.getExpenseStep(TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION);
        step = TEConstant.getExpenseStep(TEConstant.STATUS_CONFIRMATION_NOT_SUBMITTED);
        step = TEConstant.getExpenseStep(TEConstant.STATUS_CONFIRMED);
        step = TEConstant.getExpenseStep(TEConstant.STATUS_CANCEL_NOT_SUBMITTED);
        step = TEConstant.getExpenseStep(TEConstant.STATUS_CLOSED_NOT_SUBMITTED);
        step = TEConstant.getExpenseStep(TEConstant.STATUS_CANCELLED);
        step = TEConstant.getExpenseStep(TEConstant.STATUS_REJECT);
        step = TEConstant.getExpenseStep(TEConstant.STATUS_CLOSED);
        step = TEConstant.getExpenseStep('');
        
        step = TEConstant.getCashAdvanceStep(TEConstant.STATUS_DRAFT);
        step = TEConstant.getCashAdvanceStep(TEConstant.STATUS_NOT_SUBMITTED);
        step = TEConstant.getCashAdvanceStep(TEConstant.STATUS_PENDING);
        step = TEConstant.getCashAdvanceStep(TEConstant.STATUS_OPEN);
        step = TEConstant.getCashAdvanceStep(TEConstant.STATUS_PAID_OUT_NOT_SUBMITTED);
        step = TEConstant.getCashAdvanceStep(TEConstant.STATUS_PAID_OUT);
        step = TEConstant.getCashAdvanceStep(TEConstant.STATUS_CANCEL_NOT_SUBMITTED);
        step = TEConstant.getCashAdvanceStep(TEConstant.STATUS_RETURN_NOT_SUBMITTED);
        step = TEConstant.getCashAdvanceStep(TEConstant.STATUS_CANCELLED);
        step = TEConstant.getCashAdvanceStep(TEConstant.STATUS_REJECT);
        step = TEConstant.getCashAdvanceStep(TEConstant.STATUS_CLOSED);
        step = TEConstant.getCashAdvanceStep('');
        
        step = TEConstant.getTravelApplicationStep(TEConstant.STATUS_DRAFT);
        step = TEConstant.getTravelApplicationStep(TEConstant.STATUS_NOT_SUBMITTED);
        step = TEConstant.getTravelApplicationStep(TEConstant.STATUS_PENDING);
        step = TEConstant.getTravelApplicationStep(TEConstant.STATUS_CONFIRMED);
        step = TEConstant.getTravelApplicationStep(TEConstant.STATUS_CANCEL_NOT_SUBMITTED);
        step = TEConstant.getTravelApplicationStep(TEConstant.STATUS_CANCELLED);
        step = TEConstant.getTravelApplicationStep(TEConstant.STATUS_COMPLETE);
        step = TEConstant.getTravelApplicationStep('');
        
        step = TEConstant.getEducationApplicationStep(TEConstant.STATUS_DRAFT);
        step = TEConstant.getEducationApplicationStep(TEConstant.STATUS_NOT_SUBMITTED);
        step = TEConstant.getEducationApplicationStep(TEConstant.STATUS_PENDING_APPROVAL);
        step = TEConstant.getEducationApplicationStep(TEConstant.STATUS_PENDING_HCM_APPROVAL);
        step = TEConstant.getEducationApplicationStep(TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION);
        step = TEConstant.getEducationApplicationStep(TEConstant.STATUS_CANCEL_NOT_SUBMITTED);
        step = TEConstant.getEducationApplicationStep(TEConstant.STATUS_APPROVED);
        step = TEConstant.getEducationApplicationStep(TEConstant.STATUS_REJECT);
        step = TEConstant.getEducationApplicationStep(TEConstant.STATUS_CANCELLED);
        step = TEConstant.getEducationApplicationStep('');
        
        system.assertNotEquals(null,step); 
    }
}