# 简单的说明

~~从p3之后就开始有意识地认真写文档了~~

P3主要是采用logisim搭建电路

我一共上传了两个，其中new是对old的扩充

# Logisim 开发单周期CPU

## 一、设计说明

1.处理器应该支持的指令集为：add,sub,ori,lw,sw,beq,lui,nop

2.处理器为单周期设计   

## 二、实现模式

### PC

| 信号名 |  方向  |      描述       |
| :----: | :----: | :-------------: |
|  clk   | input  |    时钟信号     |
| reset  | input  |    复位信号     |
|  NPC   | input  | NPC模块的输出值 |
| PC_out | output | PC模块的输出值  |

PC模块用于实现信号的复位和下一个指令地址的输出



### PC4

| 信号名 |  方向  |  描述  |
| :----: | :----: | :----: |
|   PC   | input  | pc的值 |
|  PC+4  | output |  pc+4  |

PC4模块用于计算pc+4

### JUMP

|  信号名   |  方向  |       描述       |
| :-------: | :----: | :--------------: |
|   func    | input  |   指令中的func   |
|    op     | input  |    指令中的op    |
| jump_type | output | 用于输出跳转类型 |

JUMP模块用于判断跳转的类型。在P3的课下要求中，用jump_type=1时，表示跳转类型是beq

### NPC

|  信号名   |  方向  |     描述     |
| :-------: | :----: | :----------: |
|    PC4    | input  |   pc4输出    |
|  rsdata   | input  | rs寄存器的值 |
|  rtdata   | input  | rt寄存器的值 |
|   imm16   | input  |  16位立即数  |
| jump_type | input  |   跳转类型   |
|    NPC    | output |  下一个PC值  |

NPC根据各种输入信号决定下一个PC的值。

先对rsdata和rtdata进行各种类型的计算，再利用多路选择器，根据jump_type的值判断，pc4是否需要加上16位立即数。



接下来是对GRF，DM，ALU三个模块的设计。

因为设计一个庞大的控制模块比较混乱，所以我设计了三个小的控制模块，分别对这三个模块进行处理。

首先是寄存器模块。

### grf

|  信号名   |  方向  |        描述        |
| :-------: | :----: | :----------------: |
|   func    | input  |    指令中的func    |
|    op     | input  |     指令中的op     |
|    rt     | input  |      rt寄存器      |
|    rd     | input  |      rd寄存器      |
|  ALU_out  | input  | ALU模块的计算结果  |
|  DM_out   | input  |  从DM中取出的数据  |
|    PC4    | input  |   PC+4的计算结果   |
| jump_type | input  |   跳转指令的类型   |
|  RegData  | output | 要写入寄存器的数据 |
| RegWrite  | output |  是否要写入寄存器  |
|  RegAddr  | output | 要写入寄存器的地址 |

这是GRF模块的控制信号

R-R运算：alu_out要写入rd寄存器

R-I运算和：alu_out要写入rt寄存器

加载类型：dm_out要写入rt寄存器

分支指令：不写入寄存器

跳转指令：jal和jalr要把pc+4的值写入31号寄存器或rd寄存器

因此要根据func和op的值选择出ALU_out，如果不写入寄存器，则默认为写入零号寄存器（GRF模块已经确保不会修改零号寄存器的值

### GRF

|  信号名  |  方向  |        描述        |
| :------: | :----: | :----------------: |
|    rs    | input  |    rs寄存器编号    |
|    rt    | input  |    rt寄存器编号    |
| RegAddr  | input  | 写入的寄存器的编号 |
| RegData  | input  |    要写入的数字    |
| RegWrite | input  |      是否写入      |
|   clk    | input  |      时钟信号      |
|  reset   | input  |      复位信号      |
|  rsdata  | output |   rs寄存器的数据   |
|  rtdata  | output |   rt寄存器的数据   |

往对应的寄存器里写入相应的值，并读出rt和rs寄存器的值

### alu

|  信号名  |  方向  |     描述     |
| :------: | :----: | :----------: |
|   func   | input  | 指令中的func |
|    op    | input  |  指令中的op  |
| alu_type | output |   计算类型   |

通过func和op，选择出计算类型

### ALU

|  信号名  |  方向  |     描述     |
| :------: | :----: | :----------: |
|  rsdata  | input  | rs寄存器的值 |
|  rtdata  | input  | rt寄存器的值 |
|  imm16   | input  |  16位立即数  |
| alu_type | input  |   计算类型   |
| alu_out  | output |   计算结果   |

对于P3要求的指令来说，计算出add，sub等结果，连入多路选择器，再根据alu_type选择出最终的结果

### dm

| 信号名 |  方向  |     描述     |
| :----: | :----: | :----------: |
|  func  | input  | 指令中的func |
|   op   | input  |  指令中的op  |
| is_sw  | output | 是否是sw指令 |

对于本次设计的要求来说，只需要判断是否是sw指令，决定是否要将rt寄存器中的值存储在内存中

### DM

|  信号名  |  方向  |      描述      |
| :------: | :----: | :------------: |
| MemAddr  | input  |    地址信号    |
| MemWrite | input  |  是否写入内存  |
|  rtdata  | input  | rt寄存器的数据 |
|  reset   | input  |    复位信号    |
|  dm_out  | output |   地址的数据   |

对内存的操作有两种情况，读出地址的数据，或者将对应的数据写入地址

对于s类型的指令，若写入内存，则写入的值是rt寄存器的值

对于l类型的指令，只需要读出地址中的值，输出，并在grf端实现存入寄存器

## 三、课后问题

### 1

状态存储：PC模块，GRF模块

状态转移：ALU模块，DM模块，NPC模块

### 2

合理。

RAM为随机存储，速度快于ROM，可以方便快捷地对RAM进行修改，在设备掉电后会清空RAM；

ROM通常用作硬盘，用于存储指令，掉电后不会丢失，需要人为进行修改；

而直接使用寄存器为效率最高的方法，每一条指令的实现均需要使用寄存器，故频繁调用的GRF模块应该使用Register

### 3

是的

对于每个模块之前，我都设计了一个控制模块

### 4

寄存器写入信号RegWrite、数据存储器读写信号MemWrite、MemToReg均为0，接受nop信号时即使ALU在进行相关的计算，但并不会改变GRF和DM中的数值。

### 5

加一个模块，当地址大于0x3000时减去0x3000

### 6

强度中等，包括了R-I运算，R-R运算，分支指令

但没有包含j指令，且每个类型指令的数量较少























































