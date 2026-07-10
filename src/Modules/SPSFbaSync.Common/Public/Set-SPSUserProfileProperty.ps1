function Set-SPSUserProfileProperty {
    <#
        .SYNOPSIS
        Sets a single User Profile property to a desired value if it differs.

        .DESCRIPTION
        Compares the current value of the given User Profile property against the
        desired value and updates it only when they differ and the desired value is not
        empty. Returns $true when a change was staged (the caller is responsible for
        calling Commit()), $false otherwise. Renamed from the former
        Set-USPUserProfileProperty (typo) for SPS* naming consistency.

        .PARAMETER UserProfile
        The Microsoft.Office.Server.UserProfiles.UserProfile to update.

        .PARAMETER PropertyInternalName
        Internal name of the UPS property (e.g. WorkEmail, PreferredName).

        .PARAMETER DesiredValue
        Desired value. When null/empty/whitespace the property is left unchanged.

        .EXAMPLE
        $changed = Set-SPSUserProfileProperty -UserProfile $up -PropertyInternalName 'WorkEmail' -DesiredValue $email
    #>
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true)]
        [Microsoft.Office.Server.UserProfiles.UserProfile]
        $UserProfile,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PropertyInternalName,

        [Parameter()]
        [System.String]
        $DesiredValue
    )
    try {
        $currentValue = [string]$UserProfile[$PropertyInternalName].Value
        if ([string]::IsNullOrWhiteSpace($DesiredValue)) { return $false }
        if ($currentValue -ne $DesiredValue) {
            $UserProfile[$PropertyInternalName].Value = $DesiredValue
            return $true
        }
        return $false
    }
    catch {
        $catchMessage = @"
An error occurred while setting the UserProfile Property.
PropertyInternalName: $($PropertyInternalName)
CurrentValue: $($currentValue)
DesiredValue: $($DesiredValue)
Exception: $($_.Exception.Message)
"@
        Write-Error -Message $catchMessage # Handle any errors during property update
    }
}
