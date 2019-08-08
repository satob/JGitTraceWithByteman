
$Template = @'
#############################################################################
# {0}
#############################################################################
RULE {0} Open
CLASS org.eclipse.jgit.api.{0}
METHOD call
IF true
DO traceOpen("log","byteman_" + java.net.InetAddress.getLocalHost().getHostName() + "_" + java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE) + ".log")
ENDRULE

RULE {0} Start
CLASS org.eclipse.jgit.api.{0}
METHOD call
AT ENTRY
IF true
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Start]{1}" + {4});
ENDRULE

RULE {0} End
CLASS org.eclipse.jgit.api.{0}
METHOD call
AT EXIT
IF true
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[End]{2}" + {4});
ENDRULE

RULE {0} Error
CLASS org.eclipse.jgit.api.{0}
METHOD call
AT THROW
IF true
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Error]{3}" + {4});
  traceln("log", $^.getMessage());
  traceStack(null, "log");
ENDRULE

RULE {0} Close
CLASS org.eclipse.jgit.api.{0}
METHOD call
AT EXIT
IF true
DO traceClose("log")
ENDRULE



'@

$JSON = @'
[
 {
   class: 'CheckoutCommand',
   start: '[checkout] Start checkout branch: ',
   end: '[checkout] Checkouted branch successfully: ',
   error: '[checkout] An error occurred while checkout: ',
   var: '$0.name'
 },
 {
   class: 'CloneCommand',
   start: '[clone] Start clone repository: ',
   end: '[clone] Cloned repository successfully: ',
   error: '[clone] An error occurred while clone repository: ',
   var: '$0.uri + " -> " + $0.branch'
 },
 {
   class: 'CreateBranchCommand',
   start: '[branch] Start create local branch: ',
   end: '[branch] Created local branch successfully: ',
   error: '[branch] An error occurred while create local branch: ',
   var: '$0.startPoint + " -> " + $0.name'
 },
 {
   class: 'CommitCommand',
   start: '[commit] Start commit to branch: ',
   end: '[commit] Commited to branch successfully: ',
   error: '[commit] An error occurred while commit to branch: ',
   var: '$0.getRepository().getBranch()'
 },
 {
   class: 'FetchCommand',
   start: '[fetch] Start fetch from remote: ',
   end: '[fetch] Fetched from remote successfully: ',
   error: '[fetch] An error occurred while fetch from remote: ',
   var: '$0.getRemote() + " -> " + $0.getRepository().getBranch()'
 },
 {
   class: 'PullCommand',
   start: '[pull] Start pull from remote: ',
   end: '[pull] Pulled from remote successfully: ',
   error: '[pull] An error occurred while pull: ',
   var: '$0.getRemote() + " -> " + $0.getRepository().getBranch() + ":" + $0.getRemoteBranchName()'
 },
 {
   class: 'PushCommand',
   start: '[push] Start push to remote: ',
   end: '[push] Pushed to remote successfully: ',
   error: '[push] An error occurred while push: ',
   var: '$0.getRepository().getBranch() + " -> " + $0.getRemote()'
 },
 {
   class: 'ResetCommand',
   start: '[reset] Start reset to remote: ',
   end: '[reset] Reset successfully: ',
   error: '[reset] An error occurred while reset: ',
   var: '$0.getRepository().getBranch() + " / " + $0.getRefOrHEAD()'
 },
 {
   class: 'RevertCommand',
   start: '[revert] Start revert: ',
   end: '[revert] Revert successfully: ',
   error: '[revert] An error occurred while revert: ',
   var: '$0.getRepository().getBranch()'
 },
 {
   class: 'StashApplyCommand',
   start: '[stash apply] Start apply stash to branch: ',
   end: '[stash apply] Apply stash to branch successfully: ',
   error: '[stash apply] An error occurred while apply stash to branch: ',
   var: '$0.getStashId().getName() + " -> " + $0.getRepository().getBranch()'
 },
 {
   class: 'StashCreateCommand',
   start: '[stash create] Start creating stash: ',
   end: '[stash create] Created stash successfully: ',
   error: '[stash create] An error occurred while creating stash: ',
   var: '$0.getRepository().getBranch()'
 }
]
'@


$CherryPickCommand = @'
#############################################################################
# CherryPickCommand
#############################################################################
RULE CherryPickCommand Open
CLASS org.eclipse.jgit.api.CherryPickCommand
METHOD call
IF true
DO traceOpen("log","byteman_" + java.net.InetAddress.getLocalHost().getHostName() + "_" + java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE) + ".log")
ENDRULE

RULE CherryPickCommand Start
CLASS org.eclipse.jgit.api.CherryPickCommand
METHOD call
AT ENTRY
IF true
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Start][cherry-pick] Start cherry-pick: " + $0.ourCommitName + " -> " + $0.getRepository().getBranch());
ENDRULE

RULE CherryPickCommand End
CLASS org.eclipse.jgit.api.CherryPickCommand
METHOD call
AT EXIT
BIND ret = $!.getStatus().toString()
IF ret.equals("Ok")
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[End][cherry-pick] Cherry-picked commit successfully: " + $0.ourCommitName + " -> " + $0.getRepository().getBranch());
ENDRULE

RULE CherryPickCommand Conflicting
CLASS org.eclipse.jgit.api.CherryPickCommand
METHOD call
AT EXIT
BIND ret = $!.getStatus().toString()
IF ret.equals("Conflicting")
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Error][cherry-pick] Cherry-pick commit conflicted: " + $0.ourCommitName + " -> " + $0.getRepository().getBranch());
ENDRULE

RULE CherryPickCommand Failed
CLASS org.eclipse.jgit.api.CherryPickCommand
METHOD call
AT EXIT
BIND ret = $!.getStatus().toString()
IF ret.equals("Failed")
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Error][cherry-pick] Cherry-pick commit failed: " + $0.ourCommitName + " -> " + $0.getRepository().getBranch());
ENDRULE

RULE CherryPickCommand Error
CLASS org.eclipse.jgit.api.CherryPickCommand
METHOD call
AT THROW
IF true
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Error][cherry-pick] An error occurred while cherry-pick: " + $0.ourCommitName + " -> " + $0.getRepository().getBranch());
  traceln("log", $^.getMessage());
  traceStack(null, "log");
ENDRULE

RULE CherryPickCommand Close
CLASS org.eclipse.jgit.api.CherryPickCommand
METHOD call
AT EXIT
IF true
DO traceClose("log")
ENDRULE



'@

$MergeCommand = @'
#############################################################################
# MergeCommand
#############################################################################
RULE MergeCommand Open
CLASS org.eclipse.jgit.api.MergeCommand
METHOD call
IF true
DO traceOpen("log","byteman_" + java.net.InetAddress.getLocalHost().getHostName() + "_" + java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE) + ".log")
ENDRULE

RULE MergeCommand Start
CLASS org.eclipse.jgit.api.MergeCommand
METHOD call
AT ENTRY
IF true
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Start][merge] Start merge: " + $0.getRepository().getBranch());
ENDRULE

RULE MergeCommand End
CLASS org.eclipse.jgit.api.MergeCommand
METHOD call
AT EXIT
BIND ret = $!.getMergeStatus().toString()
IF ret.equals("Fast-forward")
OR
ret.equals("Fast-forward-squashed")
OR
ret.equals("Already-up-to-date")
OR
ret.equals("Merged")
OR
ret.equals("Merged-squashed")
OR
ret.equals("Merged-squashed-not-committed")
OR
ret.equals("Merged-not-committed")
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[End][merge] Merged successfully: " + $0.getRepository().getBranch());
ENDRULE

RULE MergeCommand Conflicting
CLASS org.eclipse.jgit.api.MergeCommand
METHOD call
AT EXIT
BIND ret = $!.getMergeStatus().toString()
IF ret.equals("Conflicting")
OR
ret.equals("Checkout Conflict")
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Error][merge] Merge conflicted: " + $0.getRepository().getBranch());
ENDRULE

RULE MergeCommand Failed
CLASS org.eclipse.jgit.api.MergeCommand
METHOD call
AT EXIT
BIND ret = $!.getMergeStatus().toString()
IF ret.equals("Failed")
OR
ret.equals("Aborted")
OR
ret.equals("Not-yet-supported")
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Error][merge] Merge failed: " + $0.getRepository().getBranch());
ENDRULE

RULE MergeCommand Error
CLASS org.eclipse.jgit.api.MergeCommand
METHOD call
AT THROW
IF true
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Error][merge] An error occurred while merge: " + $0.getRepository().getBranch());
  traceln("log", $^.getMessage());
  traceStack(null, "log");
ENDRULE

RULE MergeCommand Close
CLASS org.eclipse.jgit.api.MergeCommand
METHOD call
AT EXIT
IF true
DO traceClose("log")
ENDRULE



'@

$RebaseCommand = @'
#############################################################################
# RebaseCommand
#############################################################################
RULE RebaseCommand Open
CLASS org.eclipse.jgit.api.RebaseCommand
METHOD call
IF true
DO traceOpen("log","byteman_" + java.net.InetAddress.getLocalHost().getHostName() + "_" + java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE) + ".log")
ENDRULE

RULE RebaseCommand Start
CLASS org.eclipse.jgit.api.RebaseCommand
METHOD call
AT ENTRY
IF true
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Start][rebase] Start rebase: " + $0.getRepository().getBranch());
ENDRULE

RULE RebaseCommand End
CLASS org.eclipse.jgit.api.RebaseCommand
METHOD call
AT EXIT
BIND ret = $!.getStatus().toString()
IF ret.equals("OK")
OR
ret.equals("UP_TO_DATE")
OR
ret.equals("FAST_FORWARD")
OR
ret.equals("NOTHING_TO_COMMIT")
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[End][rebase] Rebased branch successfully: " + $0.getRepository().getBranch());
ENDRULE

RULE RebaseCommand Conflicting
CLASS org.eclipse.jgit.api.RebaseCommand
METHOD call
AT EXIT
BIND ret = $!.getStatus().toString()
IF ret.equals("CONFLICTS")
OR
ret.equals("STASH_APPLY_CONFLICTS")
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Error][rebase] Rebase branch conflicted: " + $0.getRepository().getBranch());
ENDRULE

RULE RebaseCommand Failed
CLASS org.eclipse.jgit.api.RebaseCommand
METHOD call
AT EXIT
BIND ret = $!.getStatus().toString()
IF ret.equals("ABORTED")
OR
ret.equals("STOPPED")
OR
ret.equals("EDIT")
OR
ret.equals("FAILED")
OR
ret.equals("UNCOMMITTED_CHANGES")
OR
ret.equals("INTERACTIVE_PREPARED")
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Error][rebase] Rebase branch failed: " + $0.getRepository().getBranch());
ENDRULE

RULE RebaseCommand Error
CLASS org.eclipse.jgit.api.RebaseCommand
METHOD call
AT THROW
IF true
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t" + $0.getRepository().getDirectory().getName() + "\t");
  traceln("log", "[Error][rebase] An error occurred while rebase: " + $0.getRepository().getBranch());
  traceln("log", $^.getMessage());
  traceStack(null, "log");
ENDRULE

RULE RebaseCommand Close
CLASS org.eclipse.jgit.api.RebaseCommand
METHOD call
AT EXIT
IF true
DO traceClose("log")
ENDRULE



'@

ConvertFrom-Json $JSON | ForEach-Object { $_ } | ForEach-Object { ($Template -F $_.class, $_.start, $_.end, $_.error, $_.var) } `
    | % { [Text.Encoding]::UTF8.GetBytes($_) } `
    | Set-Content -Path ".\JGit.btm" -Encoding Byte

$CherryPickCommand `
    | % { [Text.Encoding]::UTF8.GetBytes($_) } `
    | Add-Content -Path ".\JGit.btm" -Encoding Byte

$MergeCommand `
    | % { [Text.Encoding]::UTF8.GetBytes($_) } `
    | Add-Content -Path ".\JGit.btm" -Encoding Byte

$RebaseCommand `
    | % { [Text.Encoding]::UTF8.GetBytes($_) } `
    | Add-Content -Path ".\JGit.btm" -Encoding Byte



