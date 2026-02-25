trigger LeadGeocodeTrigger on Lead (after insert, after update) {
    Set<Id> toProcess = new Set<Id>();

    for (Lead l : Trigger.new) {
        Lead oldL = Trigger.isUpdate ? Trigger.oldMap.get(l.Id) : null;

        Boolean addressChanged =
            Trigger.isInsert ||
            (oldL != null && (
                l.Street != oldL.Street ||
l.City != oldL.City ||
l.State != oldL.State ||
l.PostalCode != oldL.PostalCode ||
l.Country != oldL.Country
            ));

        if (addressChanged) {
            toProcess.add(l.Id);
        }
    }

    if (!toProcess.isEmpty()) {
        System.enqueueJob(new LeadGeocodeQueueable(toProcess));
    }
}
