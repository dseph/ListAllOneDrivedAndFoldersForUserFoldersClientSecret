# ListAllOneDrivedAndFoldersForUserFoldersClientSecret.ps1
# Uses PowerShell with Invoke-RestMethod and Client Secret AppFlow oAuth to list drives and folders of a specified user.
# https://learn.microsoft.com/en-us/graph/api/drive-get?view=graph-rest-1.0&tabs=http
 
Write-Output ""
Write-Output "-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-V-"
Write-Output "Running: ListAllOneDrivedAndFoldersForUserFoldersClientSecret.ps1"
Write-Output ""
Write-Output ""

# Define the necessary variables
$clientId = "{Client ID}"
$tenantId = "{Tenant Id}"
$clientSecret = "Client Secret"
$UserSmtp = "Users STMP Address"


# Define the scope for the Graph API
Write-Output "Set scope - Start ------------------------------------"
$scope = "https://graph.microsoft.com/.default"
$scope
Write-Output "Set scope - End ------------------------------------"
Write-Output ""

Write-Output "Set properties for body  - Start ------------------------------------"
# Get the access token
$body = @{
    client_id     = $clientId
    scope         = $scope
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}
$body
Write-Output "Set properties for body  - End ------------------------------------"
Write-Output ""

Write-Output "Get Token - Start ------------------------------------" 
$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body
$accessToken = $tokenResponse.access_token
$accessToken
Write-Output "Get Token - End ------------------------------------" 
Write-Output ""

# Set the authorization header
Write-Output "Build Authroization header  - Start ------------------------------------"
$headers = @{
    Authorization = "Bearer $accessToken"
}
Write-Output "Build Authroization header  - End ------------------------------------"
Write-Output ""


# Get the list of drives
Write-Output "Getting Drives Information------------------------------------"
$drives = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/users/$UserSmtp/drives" -Headers $headers

#Write-Output "Raw drive information - start ------------------------------------"
#$drives
#Write-Output ""
#Write-Output "Raw drive information - End  ------------------------------------"

Write-Output "Listing Drives - Start ------------------------------------"
Write-Output ""
# Display the detailed properties of each drive
foreach ($drive in $drives.value) {
    Write-Output "Drive -Begin ---------------------------------------"
    Write-Output "Drive ID: $($drive.id)"
    Write-Output "Drive Name: $($drive.name)"
    Write-Output "Drive Type: $($drive.driveType)"
    Write-Output "Owner: $($drive.owner.user.displayName)"
    Write-Output "Quota Total: $($drive.quota.total)"
    Write-Output "Quota Used: $($drive.quota.used)"
    Write-Output "Quota Remaining: $($drive.quota.remaining)"
    Write-Output "Quota State: $($drive.quota.state)"
    Write-Output "Created DateTime: $($drive.createdDateTime)"
    Write-Output "Last Modified DateTime: $($drive.lastModifiedDateTime)"
     
    Write-Output ""

    # Get folders on the drive
    $FolderItems = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/drives/$($drive.id)/root/children" -Headers $headers
     
    #Write-Output "Item List Begin ---------------------------------------"
    # Display the detailed properties of each shared item
    foreach ($item in $FolderItems.value) {
        Write-Output "    Item Begin ---------------------------------------"
        Write-Output "    Item ID: $($item.id)"
        Write-Output "    Item Name: $($item.name)"
        #Write-Output "Item Type: $($item.remoteItem.file ? 'File' : 'Folder')"
        Write-Output "    Shared By: $($item.remoteItem.shared.sharedBy.user.displayName)"
        Write-Output "    Shared DateTime: $($item.remoteItem.shared.sharedDateTime)"
        Write-Output "    Last Modified DateTime: $($item.remoteItem.lastModifiedDateTime)"
        Write-Output "    Item End ---------------------------------------"
        Write-Output ""
    }

    Write-Output "Drive -End ---------------------------------------" 
}
Write-Output "Listing Drives - End ------------------------------------"
