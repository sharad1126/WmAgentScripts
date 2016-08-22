if [ -r /afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cycle.lock ] ; then
    
    if [ `ps -e -f | grep Uni | grep -c -v grep` == "0" ] ; then
	echo "There isn't anything running, very suspicious"
	cat /afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cycle.lock /afs/cern.ch/user/c/cmst2/www/unified/logs/last_running | mail -s "[Ops] Emergency On Cycle Lock. Unified isn't running." vlimant@cern.ch,matteoc@fnal.gov,Dmytro.Kovalskyi@cern.ch 
	rm -f /afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cycle.lock
    fi
    echo "cycle is locked"
    exit
fi

echo `date` > /afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cycle.lock
## get sso cookie and new grid proxy
source /afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/credentials.sh

## get the workflow in/back-in the system
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/injector.py

## equalize site white list at the condor level
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/equalizor.py

## early assignement with all requirements included 
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/assignor.py --early --limit 100
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/subscribor.py away
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/subscribor.py assistance*

## verify sanity of completed workflow and pass along
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/checkor.py --strict
## initiate automatic recovery
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/recoveror.py


## check on on-going data placements
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/stagor.py
## get the workflow in/back-in the system
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/injector.py
## initiate data placements or pass wf along
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/transferor.py
## assign the workflow to sites
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/assignor.py

## equalize site white list at the condor level
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/equalizor.py

## verify sanity of completed workflow and pass along
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/checkor.py
## initiate automatic recovery
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/recoveror.py

## close the wf 
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/closor.py

## force-complete wf according to rules ## tagging phase
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/completor.py

## finsih subscribing output blocks
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/subscribor.py done
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/subscribor.py close

## run injector here to put back replacements if any prior to unlocking below
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/injector.py

## unlock dataset that can be unlocked and set status along
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/lockor.py

## the addHoc operations
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/addHoc.py

## and display
/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/htmlor.py

## pre-fetch and place datasets from McM needs
#/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/collector.py

rm -f /afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cycle.lock

/afs/cern.ch/user/c/cmst2/Unified/WmAgentScripts/cWrap.sh Unified/GQ.py