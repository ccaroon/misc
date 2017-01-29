git config --global diff.tool diffmerge
git config --global difftool.diffmerge.cmd "C:/Program\ Files/SourceGear/Common/DiffMerge/sgdm_cygwin.sh -p1=\"\$LOCAL\" -p2=\"\$REMOTE\""
      
git config --global merge.tool diffmerge
git config --global mergetool.diffmerge.trustExitCode true
git config --global mergetool.diffmerge.cmd "C:/Program\ Files/SourceGear/Common/DiffMerge/sgdm_cygwin.sh -merge -result=\"\$MERGED\" -p1=\"\$LOCAL\" -p2=\"\$BASE\" -p3=\"\$REMOTE\""
