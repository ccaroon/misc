/* This is a very simple program to create the mandelbrot set */

#include <stdio.h>
#include <fcntl.h>
#include <math.h>
#include <stdlib.h>

#define width 160
#define height 60

main()
{
  double x,y;
  double xstart,xstep,ystart,ystep;
  double xend, yend;
  double z,zi,newz,newzi;
  double colour;
  int iter;
  long col;
  char pic[height][width];
  int i,j,k;
  int inset;

  /* Read in the initial data */
  // printf("Enter xstart, xend, ystart, yend, iterations: ");
  // if (scanf("%lf%lf%lf%lf%d", &xstart, &xend, &ystart, &yend, &iter) != 5)
  // {
  //   printf("Error!\n");
  //   exit(1);
  // }

// -0.25,0, 0.75, 1
  xstart = -0.25;
  xend   = 0;
  ystart = 0.75;
  yend   = 1;
  iter   = 200;

  /* these are used for calculating the points corresponding to the pixels */
  xstep = (xend-xstart)/width;
  ystep = (yend-ystart)/height;

  /*the main loop */
  x = xstart;
  y = ystart;
  for (i=0; i<height; i++)
  {
    // printf("Now on line: %d\n", i);
    for (j=0; j<width; j++)
    {
      z = 0;
      zi = 0;
      inset = 1;
      for (k=0; k<iter; k++)
      {
        /* z^2 = (a+bi)(a+bi) = a^2 + 2abi - b^2 */
      	newz = (z*z)-(zi*zi) + x;
      	newzi = 2*z*zi + y;
        z = newz;
        zi = newzi;
      	if(((z*z)+(zi*zi)) > 4)
      	{
      	  inset = 0;
      	  colour = k;
      	  k = iter;
      	}
      }
      if (inset)
      {
        pic[i][j] = '0';
      }
      else
      { 
        pic[i][j] = '1';
      }
      x += xstep;
    }
    y += ystep;
    x = xstart;
  }

  // for (i = 0; i < height; i++) {
  //   for (j = 0; j <  width; j++) {
  //    pic[i][j] = '.';
  //   }
  // }
  
  // pic[0][0] = 'X';
  // pic[59][159] = 'X';

  for (i = 0; i < height; i++) {
    for (j = 0; j <  width; j++) {
      printf("%c", pic[i][j]);
    }
    printf("\n");
  }

} 
