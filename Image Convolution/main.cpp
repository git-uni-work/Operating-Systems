#include <time.h>
#include <unistd.h>
#include <iostream>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <vector>
#include <fstream>
#include <cmath>
using namespace std;


struct pixel { unsigned char red, green, blue; };

void print( vector < vector < pixel > > data, int width, int height )
{
  for( int y = 0 ; y < height ; y++ )
  {
    cout << "<< ";
    for( int x = 0 ; x < width ; x++ )
    {
      cout << (int) data[y][x].red << "," << (int) data[y][x].green << "," << (int) data[y][x].blue;
      if( x+1 == width )
      { cout << " >>"; }
      else
      { cout << "|"; }
    }
    cout << endl;
  }
  cout << "============================================================================================================================" << endl;
  cout << "============================================================================================================================" << endl;
}
void printres( vector < vector < pixel > > data, vector < vector < pixel > > result, int width, int height )
{
  for( int y = 0 ; y < height ; y++ )
  {
    cout << "<< ";
    for( int x = 0 ; x < width ; x++ )
    {
      if( x == 0 || y == 0 || y+1 == height || x+1 == width )
      { cout << (int) data[y][x].red << "," << (int) data[y][x].green << "," << (int) data[y][x].blue; }
      else
      { cout << (int) result[y][x].red << "," << (int) result[y][x].green << "," << (int) result[y][x].blue; }
      if( x+1 == width )
      { cout << " >>"; }
      else
      { cout << "|"; }
    }
    cout << endl;
  }
  cout << "============================================================================================================================" << endl;
  cout << "============================================================================================================================" << endl;
}

void writeimg( string src, string dst )
{
  // PPM IMAGE FORMAT - STARTS WITH P6, WIDTH, HEIGHT, 255, IMG DATA (3 * 1 BYTE) = 1 RGB "PIXEL"
  string format;
  int width, height, depth;
  unsigned char extra;

  // READ IMAGE HEADER
  ifstream img(src);
  img >> format >> width >> height >> depth;

  img.read( reinterpret_cast<char*>(&extra), sizeof(unsigned char) );
  // READ IMAGE DATA
  vector< vector <pixel> > data (height, vector <pixel> (width));
  // USE IMAGE WIDTH & HEIGHT LIMITS + STORE RGB SEPERATELY
  for( int y = 0 ; y < height ; y++ )
  {
    unsigned char redbyte, greenbyte, bluebyte;
    for( int x = 0 ; x < width ; x++ )
    {
      img.read( reinterpret_cast<char*>(&redbyte), sizeof(unsigned char) );
      img.read( reinterpret_cast<char*>(&greenbyte), sizeof(unsigned char) );
      img.read( reinterpret_cast<char*>(&bluebyte), sizeof(unsigned char) );
      pixel pix({redbyte, greenbyte, bluebyte});
      data[y][x] = pix;
    }
  }
  img.close();

  // print(data, width, height);

  // COPY IMAGE HEADER
  ofstream out(dst);
  out << format << endl << width << endl << height << endl << depth;

  // CONVOLUTIONAL MASK - " IMAGE SHARPENING "
  int kernel[3][3] = {{0,-1,0},{-1,5,-1},{0,-1,0}};
  int red00, red01, red02, red10, red11, red12, red20, red21, red22 = 0;
  int green00, green01, green02, green10, green11, green12, green20, green21, green22 = 0;
  int blue00, blue01, blue02, blue10, blue11, blue12, blue20, blue21, blue22 = 0;
  int red, blue, green = 0;

  // APPLY THE CONVOLUTIONAL MASK
  vector< vector <pixel> > result (height, vector <pixel> (width));
  for( int y = 1 ; y < height - 1; y++ )
  {
    for( int x = 1 ; x < width - 1; x++ )
    {
      red00 = data[y-1][x-1].red * kernel[0][0];
      red01 = data[y-1][x].red * kernel[0][1];
      red02 = data[y-1][x+1].red * kernel[0][2];
      red10 = data[y][x-1].red * kernel[1][0];
      red11 = data[y][x].red * kernel[1][1];
      red12 = data[y][x+1].red * kernel[1][2];
      red20 = data[y+1][x-1].red * kernel[2][0];
      red21 = data[y+1][x].red * kernel[2][1];
      red22 = data[y+1][x+1].red * kernel[2][2];

      green00 = data[y-1][x-1].green * kernel[0][0];
      green01 = data[y-1][x].green * kernel[0][1];
      green02 = data[y-1][x+1].green * kernel[0][2];
      green10 = data[y][x-1].green * kernel[1][0];
      green11 = data[y][x].green * kernel[1][1];
      green12 = data[y][x+1].green * kernel[1][2];
      green20 = data[y+1][x-1].green * kernel[2][0];
      green21 = data[y+1][x].green * kernel[2][1];
      green22 = data[y+1][x+1].green * kernel[2][2];

      blue00 = data[y-1][x-1].blue * kernel[0][0];
      blue01 = data[y-1][x].blue * kernel[0][1];
      blue02 = data[y-1][x+1].blue * kernel[0][2];
      blue10 = data[y][x-1].blue * kernel[1][0];
      blue11 = data[y][x].blue * kernel[1][1];
      blue12 = data[y][x+1].blue * kernel[1][2];
      blue20 = data[y+1][x-1].blue * kernel[2][0];
      blue21 = data[y+1][x].blue * kernel[2][1];
      blue22 = data[y+1][x+1].blue * kernel[2][2];

      red = min((red00+red01+red02+red10+red11+red12+red20+red21+red22), 255);
      red = max(red, 0);
      green = min((green00+green01+green02+green10+green11+green12+green20+green21+green22), 255);
      green = max(green, 0);
      blue = min((blue00+blue01+blue02+blue10+blue11+blue12+blue20+blue21+blue22), 255);
      blue = max(blue, 0);

      result[y][x] = pixel({(unsigned char) red, (unsigned char) green, (unsigned char) blue});
    }
  }

  // printres(data, result, width, height);

  // CONVERT THE RGB IMAGE TO GREY SCALE = round(0.2126*R + 0.7152*G + 0.0722*B)
  // COMPUTE THE HISTOGRAM WITH THE COUNTS FOR THE RANGES = (0-50),(51-101),(102-152),(153-203),(204-255)
  vector <int> histogram(5);
  int grey = 0;
  for( auto & i : histogram )
  { i = 0; }

  // WRITE SHARPENED IMAGE
  out.write( reinterpret_cast<char*>(&extra), sizeof(unsigned char) );
  for( int y = 0 ; y < height ; y++ )
  {
    for( int x = 0 ; x < width ; x++ )
    {
      // COPY EDGE PIXELS FROM THE OG IMAGE
      if( x == 0 || y == 0 || y+1 == height || x+1 == width )
      {
        grey = round((0.2126 * (int) data[y][x].red) + (0.7152 * (int) data[y][x].green) + (0.0722 * (int) data[y][x].blue));
        if( grey >= 0 && grey <= 50 )
        { histogram[0] += 1; }
        if( grey >= 51 && grey <= 101 )
        { histogram[1] += 1; }
        if( grey >= 102 && grey <= 152 )
        { histogram[2] += 1; }
        if( grey >= 153 && grey <= 203 )
        { histogram[3] += 1; }
        if( grey >= 204 && grey <= 255 )
        { histogram[4] += 1; }
        out.write( reinterpret_cast<char*>(&data[y][x].red), sizeof(unsigned char) );
        out.write( reinterpret_cast<char*>(&data[y][x].green), sizeof(unsigned char));
        out.write( reinterpret_cast<char*>(&data[y][x].blue), sizeof(unsigned char));
      }
      else
      {
        grey = round((0.2126 * (int) result[y][x].red) + (0.7152 * (int) result[y][x].green) + (0.0722 * (int) result[y][x].blue));
        if( grey >= 0 && grey <= 50 )
        { histogram[0] += 1; }
        if( grey >= 51 && grey <= 101 )
        { histogram[1] += 1; }
        if( grey >= 102 && grey <= 152 )
        { histogram[2] += 1; }
        if( grey >= 153 && grey <= 203 )
        { histogram[3] += 1; }
        if( grey >= 204 && grey <= 255 )
        { histogram[4] += 1; }
        out.write( reinterpret_cast<char*>(&result[y][x].red), sizeof(unsigned char) );
        out.write( reinterpret_cast<char*>(&result[y][x].green), sizeof(unsigned char));
        out.write( reinterpret_cast<char*>(&result[y][x].blue), sizeof(unsigned char));
      }
    }
  }
  // out << last;
  out.close();

  // WRITE GREYSCALE HISTOGRAM
  ofstream hist("output.txt");
  for( long unsigned int i = 0 ; i < histogram.size() ; i++ )
  {
    hist << histogram[i];
    if( i + 1 != histogram.size() )
    { hist << " "; }
  }
}

// MD5 SUM OF VIT_SMALL.PPM = 32554ccd9b09af5b660a17b05350959b
// HISTOGRAM OF VIT_SMALL.PPM = 24432, 16307, 15192, ...
int main(int argc, char *argv[])
{
  cout << "==============================" << endl;
  struct timespec start, stop;
  clock_gettime(CLOCK_REALTIME, &start);
  cout << "FILENAME = " << argv[1] << endl;

  writeimg(argv[1], "output.ppm");

  clock_gettime( CLOCK_REALTIME, &stop);
  double accum = ( stop.tv_sec - start.tv_sec )*1000.0 + ( stop.tv_nsec - start.tv_nsec )/ 1000000.0;
  printf("RUN TIME = %.6lf ms\n", accum);
  cout << "==============================" << endl;
}
