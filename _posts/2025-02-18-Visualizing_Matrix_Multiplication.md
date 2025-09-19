---
title: "Visualizing Matrix Multiplication"
subtitle: "Exploring different perspectives on matrix multiplication, including viewing it as a sum of rank-one matrices for better intuition and understanding."
date: 2025-02-18T15:34:30-04:00
categories:
  - blog
tags:
  - math
---
In linear algebra, the ability to shift between different perspectives on the same concept is very useful. A classic example is the long list of equivalent statements about matrix invertibility.[^1] 

Just as invertibility can be understood in multiple ways, so can matrix multiplication. I was therefore happy to come across Eli Bendersky's [excellent article](https://eli.thegreenplace.net/2015/visualizing-matrix-multiplication-as-a-linear-combination/) on visualizing matrix multiplication as linear combinations of columnns and rows. Inspired by his post, I wanted to highlight yet another way of looking at it:

<div class="figure">
    <img src="/assets/images/matmul1.png" alt="Matrix Multiplication Perspective 1" style="width: 100%; display: block; margin: 0 auto;" />
    <div class="caption">
        <span class="caption-label">Figure 1.</span> Matrix multiplication can be viewed as a sum of rank-one matrices, where each term is the outer product of a column from the first matrix and a row from the second matrix.
    </div>
</div>

![Matrix Multiplication - Perspective 2](/assets/images/matmul2.png)

The images illustrate how a matrix product can be viewed as a sum of rank-one matrices–– a perspective that appears in various contexts, such as matrix decomposition and attention mechanisms in Transformers. 
<h2> test </h2>
In general, thinking of familiar concepts in new ways helps with intuition. I’ve found it helpful to create flashcards based on Bendersky's article and the decomposition above, and I would highly recommend doing the same.


[^1]: See e.g. https://en.wikipedia.org/wiki/Invertible_matrix.
