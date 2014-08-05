/********************************/
/*** Initialize Functions
/********************************/
void initIMU()
{
  // Output angles in TEXT format & Turn off continuous streaming output & Disable error message output
  imuSerial.write("#ot#o0#oe0");
  imuSerial.flush();
}

/********************************/
/*** Hard Coded Matrix Math Functions
/********************************/

void dot3(float R[][3], float a[3], float b[3])
{
  //hardcoded dot product for [3x3].[3x1]=[3x1]
  for (int c=0; c<3; c++)
  {
    float op = 0;
    for (int z=0; z<3; z++){
      op+=R[c][z]*a[z];
    }
    b[c] = op;
  }
}

float dot1(float a[3], float b[3]) 
{
  //hardcoded dot product for [1x3].[3x1]=[1x1]
  float op = 0;
  for (int z=0; z<3; z++){
    op+=a[z]*b[z];
  }
  return op;
}

void R_b_to_i(float phi, float theta, float psi, float R[][3]){
  //Convert from body coodrinates to inertial coordinates
  //http://www.chrobotics.com/library/understanding-euler-angles
    phi *= PI/180; //convert from deg to radians
    theta *= PI/180;
    psi *= PI/180;
    //float R[3][3];
    R[0][0] = cos(psi)*cos(theta);
    R[0][1] = cos(psi)*sin(phi)*sin(theta) - cos(phi)*sin(psi);
    R[0][2] = sin(phi)*sin(psi)+cos(phi)*cos(psi)*sin(theta);
    R[1][0] = cos(theta)*sin(psi);
    R[1][1] = cos(phi)*cos(psi)+sin(phi)*sin(psi)*sin(theta);
    R[1][2] = cos(phi)*sin(psi)*sin(theta) - cos(psi)*sin(phi);
    R[2][0] = -sin(theta);
    R[2][1] = cos(theta)*sin(phi);
    R[2][2] = cos(phi)*cos(theta);
}

int pick(float R[][3])
{
  //define 6 unit directions, convert and dot all of them
  float a1[3] = {0, 0, 1};
  float a2[3] = {0, 1, 0};
  float a3[3] = {1, 0, 0};
  float a4[3] = {0, 0, -1};
  float a5[3] = {0, -1, 0};
  float a6[3] = {-1, 0, 0};
  float d1, d2, d3, d4, d5, d6;
  
  d1 = convert(R, a1);
  d2 = convert(R, a2);
  d3 = convert(R, a3);
  d4 = convert(R, a4);
  d5 = convert(R, a5);
  d6 = convert(R, a6);
  
  return minI(d1, d2, d3, d4, d5, d6); 
}

float convert(float R[][3], float a[3]) 
//converts body frame to inertial frame,
//then calculates angle between [0,0,1] on the intertial frame with inputted axis from the input
//RM [3x3] dot [0,0,1] -->  N'[3x1] dot a[3x1] --> inverse cos --> convert to degrees
{
  float ref[] = {0, 0, 1};
  float b[3];
  float c;
  dot3(R,ref,b); //returns b [3x1]
  c = dot1(b,a); //returns foo [1x1]
  return acos(c)*180/PI;
}


int minI(float d1, float d2, float d3, float d4, float d5, float d6) 
{
  //return the index of the minimum value
  float array[] = {d1, d2, d3, d4, d5, d6};
  int index = 0;
  float mini = array[0];
  for (int z=1; z<=5; z++){
    if (mini > array[z]){
      mini = array[z];
      index = z;
    }
  }
  return index;
}

int rawPick(float rawX, float rawY, float rawZ){
  float array[] = {rawX, rawY, rawZ};
  int index = 0;
  int flip = 0;
  int trunc;
  float maxi = abs(array[0]);
  setColor(abs(rawX),abs(rawY),abs(rawZ));
  for (int z=1; z<=2; z++){
    if (maxi < abs(array[z])){
      maxi = abs(array[z]);
      index = z;
    }
  }
  trunc= array[index]; //truncate
  if (trunc != abs(array[index])){
    flip = 1;
  } 
  return (index*2) + flip;
}
