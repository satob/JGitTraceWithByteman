# Header wrote before log body
$LogHeader = @'
java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS")) + "\t" + $0.getRepository().getDirectory().getParentFile().getName()
'@

# Template without detailed conditions
$StandardTemplate = @'
#############################################################################
# {1}
#############################################################################
RULE {1} Open
CLASS org.eclipse.jgit.api.{1}
METHOD call
IF true
DO traceOpen("log","byteman_" + java.net.InetAddress.getLocalHost().getHostName() + "_" + java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE) + ".log")
ENDRULE

RULE {1} Start
CLASS org.eclipse.jgit.api.{1}
METHOD call
AT ENTRY
IF true
DO
  trace("log", {0} + "\t");
  traceln("log", "[Start]{2}" + {5});
ENDRULE

RULE {1} End
CLASS org.eclipse.jgit.api.{1}
METHOD call
AT EXIT
IF true
DO
  trace("log", {0} + "\t");
  traceln("log", "[End]{3}" + {5});
ENDRULE

RULE {1} Error
CLASS org.eclipse.jgit.api.{1}
METHOD call
AT THROW
IF true
DO
  trace("log", {0} + "\t");
  traceln("log", "[Error]{4}" + {5});
  traceln("log", $^.getMessage());
  traceStack(null, "log");
ENDRULE

RULE {1} Close
CLASS org.eclipse.jgit.api.{1}
METHOD call
AT EXIT
IF true
DO traceClose("log")
ENDRULE



'@


# Template with detailed conditions (normal/conflict/failed)
$ExtendedTemplate = @'
#############################################################################
# {1}
#############################################################################
RULE {1} Open
CLASS org.eclipse.jgit.api.{1}
METHOD call
IF true
DO traceOpen("log","byteman_" + java.net.InetAddress.getLocalHost().getHostName() + "_" + java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE) + ".log")
ENDRULE

RULE {1} Start
CLASS org.eclipse.jgit.api.{1}
METHOD call
AT ENTRY
IF true
DO
  trace("log", {0} + "\t");
  traceln("log", "[Start]{2}" + {5});
ENDRULE

RULE {1} End
CLASS org.eclipse.jgit.api.{1}
METHOD call
AT EXIT
{6}
DO
  trace("log", {0} + "\t");
  traceln("log", "[End]{3}" + {5});
ENDRULE

RULE {1} Conflicting
CLASS org.eclipse.jgit.api.{1}
METHOD call
AT EXIT
{7}
DO
  trace("log", {0} + "\t");
  traceln("log", "[Error]{8}" + {5});
ENDRULE

RULE {1} Failed
CLASS org.eclipse.jgit.api.{1}
METHOD call
AT EXIT
{9}
DO
  trace("log", {0} + "\t");
  traceln("log", "[Error]{10}" + {5});
ENDRULE

RULE {1} Error
CLASS org.eclipse.jgit.api.{1}
METHOD call
AT THROW
IF true
DO
  trace("log", {0} + "\t");
  traceln("log", "[Error]{4}" + {5});
  traceln("log", $^.getMessage());
  traceStack(null, "log");
ENDRULE

RULE {1} Close
CLASS org.eclipse.jgit.api.{1}
METHOD call
AT EXIT
IF true
DO traceClose("log")
ENDRULE



'@

$JSON = @'
[
 {
   template: '$StandardTemplate',
   class: 'CheckoutCommand',
   start: '[checkout] Start checkout branch: ',
   end: '[checkout] Checkouted branch successfully: ',
   error: '[checkout] An error occurred while checkout: ',
   var: '$0.name'
 },
 {
   template: '$StandardTemplate',
   class: 'CloneCommand',
   start: '[clone] Start clone repository: ',
   end: '[clone] Cloned repository successfully: ',
   error: '[clone] An error occurred while clone repository: ',
   var: '$0.uri + " -> " + $0.branch'
 },
 {
   template: '$StandardTemplate',
   class: 'CreateBranchCommand',
   start: '[branch] Start create local branch: ',
   end: '[branch] Created local branch successfully: ',
   error: '[branch] An error occurred while create local branch: ',
   var: '$0.startPoint + " -> " + $0.name'
 },
 {
   template: '$StandardTemplate',
   class: 'CommitCommand',
   start: '[commit] Start commit to branch: ',
   end: '[commit] Commited to branch successfully: ',
   error: '[commit] An error occurred while commit to branch: ',
   var: '$0.getRepository().getBranch()'
 },
 {
   template: '$StandardTemplate',
   class: 'FetchCommand',
   start: '[fetch] Start fetch from remote: ',
   end: '[fetch] Fetched from remote successfully: ',
   error: '[fetch] An error occurred while fetch from remote: ',
   var: '$0.getRemote() + " -> " + $0.getRepository().getBranch()'
 },
 {
   template: '$StandardTemplate',
   class: 'PullCommand',
   start: '[pull] Start pull from remote: ',
   end: '[pull] Pulled from remote successfully: ',
   error: '[pull] An error occurred while pull: ',
   var: '$0.getRemote() + " -> " + $0.getRepository().getBranch() + ":" + $0.getRemoteBranchName()'
 },
 {
   template: '$StandardTemplate',
   class: 'PushCommand',
   start: '[push] Start push to remote: ',
   end: '[push] Pushed to remote successfully: ',
   error: '[push] An error occurred while push: ',
   var: '$0.getRepository().getBranch() + " -> " + $0.getRemote()'
 },
 {
   template: '$StandardTemplate',
   class: 'ResetCommand',
   start: '[reset] Start reset to remote: ',
   end: '[reset] Reset successfully: ',
   error: '[reset] An error occurred while reset: ',
   var: '$0.getRepository().getBranch() + " / " + $0.getRefOrHEAD()'
 },
 {
   template: '$StandardTemplate',
   class: 'RevertCommand',
   start: '[revert] Start revert: ',
   end: '[revert] Revert successfully: ',
   error: '[revert] An error occurred while revert: ',
   var: '$0.getRepository().getBranch()'
 },
 {
   template: '$StandardTemplate',
   class: 'StashApplyCommand',
   start: '[stash apply] Start apply stash to branch: ',
   end: '[stash apply] Apply stash to branch successfully: ',
   error: '[stash apply] An error occurred while apply stash to branch: ',
   var: '$0.getStashId().getName() + " -> " + $0.getRepository().getBranch()'
 },
 {
   template: '$StandardTemplate',
   class: 'StashCreateCommand',
   start: '[stash create] Start creating stash: ',
   end: '[stash create] Created stash successfully: ',
   error: '[stash create] An error occurred while creating stash: ',
   var: '$0.getRepository().getBranch()'
 }
]
'@


$ExtendedJSON = @'
[
 {
   template: '$ExtendedTemplate',
   class:    'CherryPickCommand',
   start:    '[cherry-pick] Start cherry-pick: ',
   end:      '[cherry-pick] Cherry-picked commit successfully: ',
   error:    '[cherry-pick] An error occurred while cherry-pick: ',
   conflict: '[cherry-pick] Cherry-pick commit conflicted: ',
   failed:   '[cherry-pick] Cherry-pick commit failed: ',
   var:      '$0.ourCommitName + " -> " + $0.getRepository().getBranch()',
   normalCondition: [
     'BIND ret = $!.getStatus().toString()',
     'IF ret.equals("Ok")'
   ],
   conflictCondition: [
     'BIND ret = $!.getStatus().toString()',
     'IF ret.equals("Conflicting")'
   ],
   failedCondition: [
     'BIND ret = $!.getStatus().toString()',
     'IF ret.equals("Failed")'
   ]
 },
 {
   template: '$ExtendedTemplate',
   class:    'MergeCommand',
   start:    '[merge] Start merge: ',
   end:      '[merge] Merged successfully: ',
   error:    '[merge] An error occurred while merge: ',
   conflict: '[merge] Merge conflicted: ',
   failed:   '[merge] Merge failed: ',
   var:      '$0.getRepository().getBranch()',
   normalCondition: [
     'BIND ret = $!.getMergeStatus().toString()',
     'IF ret.equals("Fast-forward")',
     'OR', 'ret.equals("Fast-forward-squashed")',
     'OR', 'ret.equals("Already-up-to-date")',
     'OR', 'ret.equals("Merged")',
     'OR', 'ret.equals("Merged-squashed")',
     'OR', 'ret.equals("Merged-squashed-not-committed")',
     'OR', 'ret.equals("Merged-not-committed")'
   ],
   conflictCondition: [
     'BIND ret = $!.getMergeStatus().toString()',
     'IF ret.equals("Conflicting")',
     'OR', 'ret.equals("Checkout Conflict")'
   ],
   failedCondition: [
     'BIND ret = $!.getMergeStatus().toString()',
     'IF ret.equals("Failed")',
     'OR', 'ret.equals("Aborted")',
     'OR', 'ret.equals("Not-yet-supported")'
   ]
 },
 {
   template: '$ExtendedTemplate',
   class:    'RebaseCommand',
   start:    '[rebase] Start rebase: ',
   end:      '[rebase] Rebased branch successfully: ',
   error:    '[rebase] An error occurred while rebase: ',
   conflict: '[rebase] Rebase branch conflicted: ',
   failed:   '[rebase] Rebase branch failed: ',
   var:      '$0.getRepository().getBranch()',
   normalCondition: [
     'BIND ret = $!.getStatus().toString()',
     'IF ret.equals("OK")',
     'OR', 'ret.equals("UP_TO_DATE")',
     'OR', 'ret.equals("FAST_FORWARD")',
     'OR', 'ret.equals("NOTHING_TO_COMMIT")'
   ],
   conflictCondition: [
     'BIND ret = $!.getStatus().toString()',
     'IF ret.equals("CONFLICTS")',
     'OR', 'ret.equals("STASH_APPLY_CONFLICTS")'
   ],
   failedCondition: [
     'BIND ret = $!.getStatus().toString()',
     'IF ret.equals("ABORTED")',
     'OR', 'ret.equals("STOPPED")',
     'OR', 'ret.equals("EDIT")',
     'OR', 'ret.equals("FAILED")',
     'OR', 'ret.equals("UNCOMMITTED_CHANGES")',
     'OR', 'ret.equals("INTERACTIVE_PREPARED")'
   ]
 }
]
'@

ConvertFrom-Json $JSON | ForEach-Object { $_ } `
    | ForEach-Object { 
        $template = $_.template;
        (Invoke-Expression "Write-Output $template") -F $LogHeader, $_.class, $_.start, $_.end, $_.error, $_.var
      } `
    | % { [Text.Encoding]::UTF8.GetBytes($_) } `
    | Set-Content -Path ".\JGit.btm" -Encoding Byte

ConvertFrom-Json $ExtendedJSON | ForEach-Object { $_ } `
    | ForEach-Object { 
        $template = $_.template;
        (Invoke-Expression "Write-Output $template") -F $LogHeader, $_.class, $_.start, $_.end, $_.error, $_.var, ($_.normalCondition -join "`n"), ($_.conflictCondition -join "`n"), $_.conflict, ($_.failedCondition -join "`n"), $_.failed
      } `
    | % { [Text.Encoding]::UTF8.GetBytes($_) } `
    | Add-Content -Path ".\JGit.btm" -Encoding Byte

