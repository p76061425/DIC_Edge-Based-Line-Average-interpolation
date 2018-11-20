# Edge-Based Line Average interpolation

## Introduction
&ensp;&ensp;&ensp;&ensp;The interlaced video comprises two types of fields in the sequence, one is the odd
and another is the even field. The de-interlacing process is to convert the interlaced
video into the non-interlaced form as shown in Fig. 1. The simplest method is intrafield
interpolation, which use the existing pixels in the field to generate the empty lines.
For instance, the empty lines can be filled via line doubling, which is quite easy to be
implemented but the resulting image is not good enough in visual quality. In this homework, you are asked to implement the Edge-Based Line Average interpolation algorithm. As the direction of edge is considered, the de-interlaced image has a better
quality than merely doubling the existing lines. </br>

![](https://i.imgur.com/vfak3yO.png)

&ensp;&ensp;&ensp;&ensp;Assume that the pixel to be interpolated is located at coordinate (i , j) and pixels a to f are the neighboring points, which is shown in Fig. 2. First of all, three different directions at the interpolated position is calculated using (1), and the value of interpolated pixel is obtained by (2) and output before rounding. </br>

![](https://i.imgur.com/4TXd6Lq.png)

&ensp;&ensp;&ensp;&ensp;If there are identical direction values, the priority of the three directions is D2>D1>D3. For instance, D<sub>1</sub>=20, D<sub>2</sub>=30, D<sub>3</sub>=20, then min(D<sub>1</sub>, D<sub>2</sub>, D<sub>3</sub>) = D<sub>1</sub>.The left and right boundary interpolation is fixed to (b+e)/2. 