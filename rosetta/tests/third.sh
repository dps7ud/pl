#!/bin/bash
node ts.js t1.txt > n_out1.txt
node ts.js t2.txt > n_out2.txt
node ts.js t3.txt > n_out3.txt
node ts.js t4.txt > n_out4.txt
node ts.js t5.txt > n_out5.txt
node ts.js t6.txt > n_out6.txt
node ts.js t7.txt > n_out7.txt

python3 ../successes/rosetta.py < t1.txt > p_out1.txt
python3 ../successes/rosetta.py < t2.txt > p_out2.txt
python3 ../successes/rosetta.py < t3.txt > p_out3.txt
python3 ../successes/rosetta.py < t4.txt > p_out4.txt
python3 ../successes/rosetta.py < t5.txt > p_out5.txt
python3 ../successes/rosetta.py < t6.txt > p_out6.txt
python3 ../successes/rosetta.py < t7.txt > p_out7.txt

echo node -- python
echo === 1:
diff n_out1.txt p_out1.txt
echo === 2:
diff n_out2.txt p_out2.txt
echo === 3:
diff n_out3.txt p_out3.txt
echo === 4:
diff n_out4.txt p_out4.txt
echo === 5:
diff n_out5.txt p_out5.txt
echo === 6:
diff n_out6.txt p_out6.txt
echo === 7:
diff n_out7.txt p_out7.txt
rm n_out*
rm p_out*
