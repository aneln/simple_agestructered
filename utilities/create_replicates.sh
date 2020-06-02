

function create_replicates(){
    INPUT_FILE=$1
    LINE_NUMBER=$2
    NREPLICATES=$3
    SEP=","

    # Pull out header
    header=`head -1 $INPUT_FILE`

    # Use indexing starting from 1 for line numbers
    LINE_NUMBER=$(($LINE_NUMBER + 1))

    # Pull line of interest (starting indexing from 1)
    line=`tail -n+$LINE_NUMBER $INPUT_FILE | head -1`
    
    # Print header line, then repeat parameter line
    echo $header
    echo $line | awk -F","  {OFS=FS}'{$1=""}1' | awk -v NREPLICATES=$NREPLICATES '{for (i=0; i<NREPLICATES; i++) print i $0}'
}

