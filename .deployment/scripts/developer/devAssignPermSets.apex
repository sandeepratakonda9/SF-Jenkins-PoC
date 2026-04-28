    // Define the Developer Names of the Permission Sets you want to assign
    private static final List<String> permissionSetDeveloperNames = new List<String>{
        'AutomotiveFoundationUserPsl',
        'IndustriesServiceExcellence',
        'OmniStudioAdmin'
    };

    // Query for the Permission Sets with the specified Developer Names
    List<PermissionSet> permissionSetsToAssign = 
                                                [
                                                    SELECT 
                                                        Id 
                                                    FROM 
                                                        PermissionSet 
                                                    WHERE 
                                                        Name 
                                                    IN :permissionSetDeveloperNames
                                                ];

    // Get the current user's ID
    Id currentUserId = UserInfo.getUserId();

    // Create a list to hold PermissionSetAssignment records
    List<PermissionSetAssignment> assignmentsToInsert = new List<PermissionSetAssignment>();

    // Loop through the queried Permission Sets and create PermissionSetAssignment records
    for (PermissionSet currentPermissionSet : permissionSetsToAssign) {
        PermissionSetAssignment assignment = new PermissionSetAssignment();
        assignment.AssigneeId = currentUserId;
        assignment.PermissionSetId = currentPermissionSet.Id;
        assignmentsToInsert.add(assignment);
    }

    // Insert the PermissionSetAssignment records in bulk
    if (!assignmentsToInsert.isEmpty()) {
        try {
            insert assignmentsToInsert;
            System.debug('Permission Sets assigned successfully.');
        } catch (DmlException e) {
            System.debug('Error assigning Permission Sets: ' + e.getMessage());
        }
    }
