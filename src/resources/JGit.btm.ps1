﻿
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
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t");
  traceln("log", "[Start]{1}" + {4});
ENDRULE

RULE {0} End
CLASS org.eclipse.jgit.api.{0}
METHOD call
AT EXIT
IF true
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t");
  traceln("log", "[End]{2}" + {4});
ENDRULE

RULE {0} Error
CLASS org.eclipse.jgit.api.{0}
METHOD call
AT THROW
IF true
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t");
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
   end: '[checkout] Checkout branch successfully: ',
   error: '[checkout] An error occurred while checkout: ',
   var: '$0.name'
 },
 {
   class: 'CloneCommand',
   start: '[clone] Start clone repository: ',
   end: '[clone] Clone repository successfully: ',
   error: '[clone] An error occurred while clone repository: ',
   var: '$0.uri + " -> " + $0.branch'
 },
 {
   class: 'CreateBranchCommand',
   start: '[branch] Start create local branch: ',
   end: '[branch] Create local branch successfully: ',
   error: '[branch] An error occurred while create local branch: ',
   var: '$0.startPoint + " -> " + $0.name'
 },
 {
   class: 'CommitCommand',
   start: '[commit] Start commit to branch: ',
   end: '[commit] Commit to branch successfully: ',
   error: '[commit] An error occurred while commit to branch: ',
   var: '$0.getRepository().getBranch()'
 },
 {
   class: 'FetchCommand',
   start: '[fetch] Start fetch from remote: ',
   end: '[fetch] Fetch from remote successfully: ',
   error: '[fetch] An error occurred while fetch from remote: ',
   var: '$0.getRemote() + " -> " + $0.getRepository().getBranch()'
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
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t");
  traceln("log", "[Start][cherry-pick] Start cherry-pick: " + $0.ourCommitName + " -> " + $0.getRepository().getBranch());
ENDRULE

RULE CherryPickCommand End
CLASS org.eclipse.jgit.api.CherryPickCommand
METHOD call
AT EXIT
BIND ret = $!.getStatus().toString()
IF ret.equals("Ok")
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t");
  traceln("log", "[End][cherry-pick] Cherry-pick commit successfully: " + $0.ourCommitName + " -> " + $0.getRepository().getBranch());
ENDRULE

RULE CherryPickCommand Conflicting
CLASS org.eclipse.jgit.api.CherryPickCommand
METHOD call
AT EXIT
BIND ret = $!.getStatus().toString()
IF ret.equals("Conflicting")
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t");
  traceln("log", "[Error][cherry-pick] Cherry-pick commit conflicted: " + $0.ourCommitName + " -> " + $0.getRepository().getBranch());
ENDRULE

RULE CherryPickCommand Failed
CLASS org.eclipse.jgit.api.CherryPickCommand
METHOD call
AT EXIT
BIND ret = $!.getStatus().toString()
IF ret.equals("Failed")
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t");
  traceln("log", "[Error][cherry-pick] Cherry-pick commit failed: " + $0.ourCommitName + " -> " + $0.getRepository().getBranch());
ENDRULE

RULE CherryPickCommand Error
CLASS org.eclipse.jgit.api.CherryPickCommand
METHOD call
AT THROW
IF true
DO
  trace("log", java.time.ZonedDateTime.now().format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE_TIME) + "\t");
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

ConvertFrom-Json $JSON | ForEach-Object { $_ } | ForEach-Object { ($Template -F $_.class, $_.start, $_.end, $_.error, $_.var) } `
    | % { [Text.Encoding]::UTF8.GetBytes($_) } `
    | Set-Content -Path ".\JGit.btm" -Encoding Byte

$CherryPickCommand `
    | % { [Text.Encoding]::UTF8.GetBytes($_) } `
    | Add-Content -Path ".\JGit.btm" -Encoding Byte
