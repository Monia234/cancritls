#!/bin/bash

binary_path=`dirname $0`

bim=${1%.bim}
ref=${2%.bim}

mv $bim.bim $bim.bim.old
Rscript ${binary_path}/align_position.r $bim $ref

