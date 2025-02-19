---
title: "Visualizing Matrix Multiplication"
date: 2025-02-18T15:34:30-04:00
categories:
  - blog
tags:
  - math
---
In linear algebra, the ability to move between different perspectives on the same topic is usually very useful. A classic example of this is the long list of equivalent statements regarding matrix invertibility ([Wiki](https://en.wikipedia.org/wiki/Invertible_matrix)).

As such, I was happy to come across [Eli Bendersky's excellent article](https://eli.thegreenplace.net/2015/visualizing-matrix-multiplication-as-a-linear-combination/) on different ways to visualize matrix multiplication. Inspired by his post, I wanted to highlight yet another way of looking at it:

![Matrix Multiplication - Perspective 1](/assets/images/matmul1.png)
![Matrix Multiplication - Perspective 2](/assets/images/matmul2.png)

The pictures basically show how we can view a matrix product as a sum of rank-one matrices. This is useful in classic linear algebra, e.g. for SVD, but also in modern ML methods, e.g. when computing attention scores in Transformers. 

In general, reviewing different interpretations and visualizations of matrix multiplication can help with intuition. I’ve found it useful to make some flashcards summarizing these perspectives and revisiting them regularly, to keep the different perspectives in mind. I suggest anyone visit [Bendersky's article](https://eli.thegreenplace.net/2015/visualizing-matrix-multiplication-as-a-linear-combination/) and brush up on those perspectives to complement the one pictured above.


