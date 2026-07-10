@{
    # Settings consumed by Invoke-ScriptAnalyzer in CI and the local lint task.
    #
    # PSUseShouldProcessForStateChangingFunctions is excluded because the state-changing
    # helpers in SPSFbaSync.Common (Add-SPSScheduledTask / Remove-SPSScheduledTask, which
    # register/delete a Windows scheduled task, and Set-SPSUserProfileProperty, which stages
    # a UPS property value) are thin wrappers driven explicitly by the entry script's -Action
    # parameter and by the user-provided configuration. The destructive/mutating paths are
    # already gated at the entry-script level (Install/Uninstall action, ShouldProcess on the
    # profile Commit and SPUser update). Adding SupportsShouldProcess/ShouldProcess plumbing to
    # each low-level wrapper would add no real safety and is inconsistent with the rest of the
    # SPS* toolkit. The rule is therefore excluded project-wide.
    ExcludeRules = @(
        'PSUseShouldProcessForStateChangingFunctions'
    )
}
