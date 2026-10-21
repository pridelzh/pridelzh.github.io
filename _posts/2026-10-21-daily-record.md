---
layout: post
title: "Daily Record"
date: 2026-10-21
categories:
  - Programming
tags:
  - Record
  - Machine Learning
  - Dairy
excerpt: "For my daily record, I will write down the things I learned today."
---
## 1. 在一个旧的模型项目上，结合官方仓库，怎么样把原来的模型在新的数据集上再训练

- 有的时候论文的配置和仓库的配置会出现冲突，比如说论文里面设置的步数是100K，仓库里面设置的是500K，如果不是需要完全复刻论文的话，只是为了把原来的基础模型在我们的数据集上再训练一下的话，那么还是建议以仓库里面的为主，毕竟仓库里面可能是真的跑通了的，训练成功的概率会更大一点的

## 2. batch_size的理解和说明

- `batch_size` 指的是一次处理多少个样本，再根据这些样本的平均损失，计算梯度有些论文里面的卡的配置是比较豪华的，有时候batch_size是会很大的，我们打个比方，是64，我们自己的卡可能没有这么大的显存，就可以使用一些操作获得等效的64的batch_size，比如说，我们用两张卡，每张卡放4个样本，累计8次梯度之后更新参数，那么实际有效batch_size就是2\*4\*8=64

  ```txt
  effective_batch_size =
      per_device_batch_size
      × gradient_accumulation_steps
      × GPU 数量
  ```

## 3. 配置文件ymal/yml，train.sh，train.py等文件之间的关系和如何使用

- ```text
  .sh       = 启动脚本，负责组织和执行训练命令
  train.py  = 通常是训练程序的入口
  .yaml     = 保存模型、数据和训练超参数的配置文件
  --参数     = 命令行参数，用来指定或覆盖配置
  ```
