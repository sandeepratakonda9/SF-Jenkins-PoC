public with sharing class UserAccessController {
    @AuraEnabled
    public static Map<String, Object> getUserAccessDetails(String username) {
        Map<String, Object> userAccessData = new Map<String, Object>();
        
        // Fetch User Details
        User user = [
            SELECT Id, Name, Username, ProfileId, Profile.Name, UserRoleId, UserRole.Name
            FROM User 
            WHERE Username = :username 
            LIMIT 1
        ];
        userAccessData.put('User', user);

        // Fetch Profile
        Profile profile = [
            SELECT Id, Name, Description
            FROM Profile 
            WHERE Id = :user.ProfileId
        ];
        userAccessData.put('Profile', profile);

        // Fetch Role and Role Hierarchy
        UserRole role = [
            SELECT Id, Name, ParentRoleId
            FROM UserRole 
            WHERE Id = :user.UserRoleId
        ];
        userAccessData.put('Role', role);

        // Fetch Permission Sets Assigned
        List<PermissionSetAssignment> permissionSetAssignments = [
            SELECT Id, AssigneeId, PermissionSetId, PermissionSet.Name, PermissionSet.IsOwnedByProfile, PermissionSet.Description
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :user.Id
        ];
        userAccessData.put('PermissionSets', permissionSetAssignments);

        // Fetch Permission Set Groups Assigned
     /*   List<PermissionSetGroup> permissionSetGroups = [
            SELECT Id, DeveloperName, MasterLabel, Description, Status
            FROM PermissionSetGroup 
            WHERE Id IN (SELECT PermissionSetGroupId 
                         FROM PermissionSetGroupAssignment 
                         WHERE AssigneeId = :user.Id)
        ];
        userAccessData.put('PermissionSetGroups', permissionSetGroups); */

        // Fetch Object Permissions for Assigned Permission Sets
        List<ObjectPermissions> objectPermissions = [
            SELECT Id, ParentId, SObjectType, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords
            FROM ObjectPermissions 
            WHERE ParentId IN (SELECT PermissionSetId 
                               FROM PermissionSetAssignment 
                               WHERE AssigneeId = :user.Id)
        ];
        userAccessData.put('ObjectPermissions', objectPermissions);

        // Fetch Field Permissions for Assigned Permission Sets
        List<FieldPermissions> fieldPermissions = [
            SELECT Id, ParentId, SObjectType, Field, PermissionsRead, PermissionsEdit
            FROM FieldPermissions 
            WHERE ParentId IN (SELECT PermissionSetId 
                               FROM PermissionSetAssignment 
                               WHERE AssigneeId = :user.Id)
        ];
        userAccessData.put('FieldPermissions', fieldPermissions);

        // Fetch Permission Set Licenses Assigned
        List<PermissionSetLicenseAssign> permissionSetLicenses = [
            SELECT Id, AssigneeId, PermissionSetLicenseId, PermissionSetLicense.MasterLabel
            FROM PermissionSetLicenseAssign 
            WHERE AssigneeId = :user.Id
        ];
        userAccessData.put('PermissionSetLicenses', permissionSetLicenses);

        return userAccessData;
    }
}