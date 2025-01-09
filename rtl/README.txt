Since the underlying theory of Branch Prediction is too hard.
I had to write a description.

Terms:
   - Branch Prediction Buffer = Branch History Table (BHT):  a small memory indexed by the lower portion of the address of the branch instruction, which  contains a bit that says whether the branch was recently taken or not.
   - Branch Target Buffer = Branch History table + destination PC


Eng:




Vie:



Phase 1:
1. Một Branch Predictor sẽ nhận pcF để phân giải nó ra làm 3 phần:
   - Phần đầu tiên là tag = pcF[31:12] ~ 20 bit: Dùng để xác định chính xác lệnh được so sánh có phải là lệnh rẽ nhánh không ?
   - Phần thứ hai là index = pcF[2:11] ~ 10 bit: Dùng để định vị lệnh này, index lệnh này trong bộ nhớ cache (aka: branch target buffer).
   - Phần thứ ba là 2 bit thừa 00: Vì 32-bit RISC-V là byte-addressable

2. 

 