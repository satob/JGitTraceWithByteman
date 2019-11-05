JGit/EGit Operation Tracer (with Byteman)
=========================================

Byteman rule to trace JGit/EGit repository operations

## Description

You can log following git operations on JGit/EGit:
- Checkout branch
- Clone repository
- Create Branch
- Commit
- Fetch
- Pull
- Push
- Reset
- Revert
- Apply Stash
- Create Stash
- CherryPick
- Merge
- Rebase

The log filename will be `byteman_HOSTNAME_YYYY-MM-DD.log`, like `byteman_MyComputer_2019-10-31.log`.

This rule logs the time, name of repository, start/end of operation, operation name, and message. Sample log:
```
2019-10-31T00:38:20.839	system-design-primer	[Start][checkout] Start checkout branch: refs/heads/Cache
2019-10-31T00:38:20.924	system-design-primer	[End][checkout] Checkouted branch successfully: refs/heads/Cache
2019-10-31T00:38:22.367	system-design-primer	[Start][checkout] Start checkout branch: refs/heads/Communication
2019-10-31T00:38:22.416	system-design-primer	[End][checkout] Checkouted branch successfully: refs/heads/Communication
2019-10-31T00:38:25.351	system-design-primer	[Start][pull] Start pull from remote: null -> Communication:null
2019-10-31T00:38:25.381	system-design-primer	[Start][fetch] Start fetch from remote: origin -> Communication
2019-10-31T00:38:26.129	system-design-primer	[End][fetch] Fetched from remote successfully: origin -> Communication
2019-10-31T00:38:26.175	system-design-primer	[Start][merge] Start merge: Communication
2019-10-31T00:38:26.213	system-design-primer	[End][merge] Merged successfully: Communication
2019-10-31T00:38:26.227	system-design-primer	[End][pull] Pulled from remote successfully: origin -> Communication:refs/heads/Communication
```

## Requirement

You need Byteman (https://byteman.jboss.org/).

**Note: Do not use Byteman 4.0.8 due to a bug affect to this rule (https://issues.jboss.org/browse/BYTEMAN-387).**

## Install

1. Install Byteman into any directory
2. Deploy JGit.btm into any directory
3. Add following option to JVM command-line option
```
-javaagent:/path/to/byteman/lib/byteman.jar=script:/path/to/JGitTraceWithByteman/src/resources/JGit.btm,boot:/path/to/byteman/lib/byteman.jar
```

## Preferences

- To change log destination path, change the 2nd argument of traceOpen().

## Licence

This software is released under the MIT License, see LICENSE.txt.

## Author

[Yusuke SATO](https://github.com/satob)


