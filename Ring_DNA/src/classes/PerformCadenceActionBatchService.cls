public class PerformCadenceActionBatchService {
    
    public static void runSequenceEngine(string participantType, List<SObject> participantList, List<SObject> parentParticipantList) {	
    	SequenceEngine.processSequences(participantType, participantList, parentParticipantList, false);
    }
}