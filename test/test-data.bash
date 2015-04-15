
L1_F1=plip/plop/plaf
L1_F2=toto/titi
L1_F3=tutu
FILES_NO_SPACE="${L1_F1}\n${L1_F2}\n${L1_F3}"

L2_F1='pli  p/pl\top/p laf'
L2_F2='t oto/tit\ti'
L2_F3='\t tutu '
FILES_WITH_BLANKS="${L2_F1}\n${L2_F2}\n${L2_F3}"

L3_F1='pli  p/pl\top///p laf'
L3_F2="//${L2_F2}"
L3_F3="${L2_F3}//"
FILES_WITH_MULTIPLE_DIR_SEPS="${L3_F1}\n${L3_F2}\n${L3_F3}"
FILES_WITH_SINGLE_DIR_SEPS="${L2_F1}\n/${L2_F2}\n${L2_F3}/"
