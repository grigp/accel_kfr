

class DataParams {
  int freq;
  double min;
  double max;

  DataParams({
    required this.freq,
    required this.min,
    required this.max
  });
}

class DataBlock {
  double ax;
  double ay;
  double az;
  double gx;
  double gy;
  double gz;

  DataBlock({
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
});
}