# MathModeling2018B
My MATLAB code for Chinese college student mathematical contest in modeling(CUMCM), question B, 2018
全国大学生数学建模竞赛2018年B题，我的MATLAB代码。

第1问的决策过程可以看作一棵庞大的决策树。你要不断选择RGV下一次所去的CNC的编号。每次都有8种选择。当你总共需要选择几百次时，一共就有8的几百次方种选择方法。当然不可能去暴力遍历整个决策树。
对于第1问，首先用贪婪算法。求出RGV下一步去哪台CNC为其上下料，可以使得RGV在最短时间内能够再次行动。直接就去那台CNC。然后用遗传进化的方式来优化贪婪的结果。将每次去的CNC的编号按顺序串起来，形成一个长度为好几百的序列。把这个序列叫做一条DNA。先在序列后面补一些随机1到8的整数（万一经过进化后产量增加了，则RGV在8小时内可以前往机器的次数还会增多，因此我们要给DNA进化留出空间）。然后随机生成若干条DNA，与贪婪DNA放在一起作为一群生物。随便让这些生物变异，杂交。经过几百代几千代，产量可能会比贪婪更好一些。
对于第1问，凡是放上CNC的料，即使它在时间用完的那一刻还没加工完，也被我直接计入产量了。我们总不能时间一到就把没加工完的东西扔掉吧！如果不希望这些东西也被计入产量，只要稍微人工检查一下，扣掉最后几个没有被RGV下料的物料（下料的时刻为0的物料）即可。

对于第2问，我们不仅要决定如何安排RGV的移动，还要安排CNC的刀具。好在刀具只有254种情况。一旦刀具决定了，对RGV做贪婪是很快的。于是先对于每一种刀具安排，做出一个贪婪解。接下来先找出两种刀具安排，让贪婪产量较低的那种做遗传进化。如果进化后打败了原本产量较高的一方，则对原本产量较高的一方做进化。如果原来产量较低的一方在进化后仍未打败产量高的一方，则直接淘汰之。这两种刀具安排交替进化，直到有一方经过进化仍未打败另一方。立即淘汰“进化后还赢不了”的刀具安排。未被淘汰的一方和一种新的刀具安排继续竞争。
被淘汰的那一方的产量会被设为一个阈值。之后如果遇到的对手的贪婪产量比这个阈值低太多，则新对手将不参与进化，直接被淘汰。
最后会找出一种几乎最优的刀具安排。我们拿这种刀具安排来实际生产。先贪婪，后进化。贪婪的规则略有不同：最初RGV必须为1类CNC上下料。如果RGV给装有物料的1类CNC下了料，则下次必须前往2类CNC（因为RGV上装着一个半成品。总不能扔掉它继续去找1类CNC吧！）。如果RGV刚访问完2类CNC，则RGV下次必须访问1类CNC（因为没有料可以上给2类CNC）。
第2问只要是放上2类CNC的物料就直接被计入产量，不管它是否来得及被下料。

第3问，随意地让机器坏一坏就好了。不过我的程序有一个问题：忽略了当RGV前往某台机器的路上，那台机器突然坏掉的情况。现实中这种情况一定会发生。在现实中我们立即让RGV在半路上贪婪一下，换个机器去上料就好了。然而在这道题目里我们很难说RGV在半路上前往各台机器到底需要多少时间，因此干脆就不考虑这种情况了。
第3问要注意物料报废问题（不注意的话程序就出大bug了），以及RGV不可能提前知道某台机器会坏，还有RGV不可能知道这台机器到底还需要多少时间修好。仅当机器确实修好的时候，RGV才有可能选择这台机器去上料。
由于每台CNC每做一次加工就有1%概率损坏，也就是说每次损坏的情况是不同的，所以模拟生产的结果也会每次不同。

运行程序的步骤：
第1题和第2题先运行greedy，再运行genetic，最后运行simulation。例如要对第2题（2道工序）的第1组参数求解，就按顺序运行greedy2_1，genetic2_1，simulation2_1。最终结果里的out矩阵可以直接复制粘贴，填入比赛主办方给的excel表格。填完就会发现最后几个物料的下料时刻为0。扣掉这些即可。
第3题直接是一口气做完的。运行problem即可。例如对第3题第2问的第1组参数求解，直接运行problem3_2_1即可。输出的out矩阵可以直接填excel表。
