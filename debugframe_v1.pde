import processing.serial.*;

Serial myPort; 


//======================================================================================================================
// Configuration part
//======================================================================================================================
// Mainwindow variables  

// fVertical_partition will create a vertical line that splits the processing window into two part. The main partition which serves a zoom window and configurable side windows. 
// the first setting is the precentage of pixels of the processing window that will be dedicated to the zoom window vs the side windows. Using 60% as default the zoom window will be set at width*.60

float fVertical_partition = 0.60;

// iSide_windows will create that many side windows. In this case this will create 4 side windows 
int iSide_windows =4 ;

// Below are two constants that tell debugframe the window type. Do not change
int WINDOW_TYPE_SERVO =1;
int WINDOW_TYPE_BARCHART =2;


// This array sets the types of side windows. It must contain at least the number of elements that are specified by iSide_windows. Each element must be a window type listed above.
int [] display_types = {WINDOW_TYPE_SERVO,WINDOW_TYPE_BARCHART,WINDOW_TYPE_SERVO,WINDOW_TYPE_BARCHART};



// This sets the packet characters. A packet is the input that debugframe is reading from the serial port. The corresponidng arduino sketch should serial.print the values in the packet format.
// Each packet starts with a ! (exlamation mark) and then is follows by a set of values separated by a comma. Each value should correspond to a side window in the order set by display_types
// For example !90,450,180,1023 in the default configuration will display 90 in the first servo box, 450 on the chart, 180 on the second servo box and 1023 on the last chart

//You can change the here the characters for packet start and packet separator
// character to denote start of package
char cPacketStart = '!';
//character to denote separator
char cPacketSeparator = ',';


// Parameters for WINDOW_TYPE_SERVO
//The  radious of each circle in the servo box, color and fill
int iservocircle_radius_percentage = 80;
int iservocircle_color =187;
int iservocircle_fill =0;

// IMPORTANT: This will draw the limit of each angle in a WINDOW_TYPE_SERVO. The default Max angles of each servo attached in degrees. Array must contain at least as many items as WINDOW_TYPE_SERVOs are in display_types. 
// Each element coresponds to each element in display_types in order that it is listed
int [] iServoAngles= {180,180};


// Parameters for WINDOW_TYPE_BARCHART
// the default upper and lower axis limits for each bar chart in pixes. The chart will map each input  and place it between ibar_lower_limits and ibar_upper_limits. Arrays must contain at least as many items as WINDOW_TYPE_BARCHART are in display_types. 
// Each element coresponds to each element in display_types in order that it is listed
int [] ibar_lower_limits= {0,0};
int [] ibar_upper_limits= {1023,1023};
int ibarchart_color =#0000ff;


//This sets a global delay for the draw() in millisecons
int iSychms =15;

// ***** DON'T TOUCH ****
// Datapoint array and packet object. 
int [] datapoints = new int [iSide_windows];
cPacket inPacket;
// This sets the parameters for the main frame. creating a MainFrame class oblect. The purpose is to draw the lines of the display
MainFrame mainframe;
// This sets the parameters for the main frame. creating a MainFrame class oblect. The purpose is to contain the different display objects
DisplayWindow main_display;
DisplayWindow[] side_frame_display = new DisplayWindow[iSide_windows];
int iServoTotallength;
// this is a flag indicating that a key was pressed. It will display in the zoom window the corresponding side window depending on the number that was pressed on the keyboard
int ikey_for_side_display=0;

//=====================================================================================================================================
//=====================================================================================================================================
//=====================================================================================================================================

void setup() {
  
  int itempX=0;
  int itempY=0;
  int iV_divider =0;
  int iH_divider_unit_height =0;
  
  int i =0;
  int ii =0;
  int ir =0;
  
  int servocount =0;
  int barcount =0;
  
  size(600,400);
  smooth();
  background(0);
  
  stroke(187);
 //Verical Frame 
 
 
 //---------------------------------------------------------------------------------------------
 

 // List all the available serial ports
println(Serial.list());
// I know that the first port in the serial list on my mac
// is always my Arduino, so I open Serial.list()[0].
// Open whatever port is the one you're using.
myPort = new Serial(this, Serial.list()[0], 9600);
// don't generate a serialEvent() unless you get a newline character:
myPort.bufferUntil('\n');
//---------------------------------------------------------------------------------------------
 


 
 
 
 inPacket = new cPacket();
 inPacket.zeroarray();
 
 
 iV_divider =int( width* fVertical_partition);
 iH_divider_unit_height = int( height/iSide_windows);
 
 mainframe= new MainFrame (iV_divider, iH_divider_unit_height, iSide_windows,187);
 
 main_display = new DisplayWindow(0,WINDOW_TYPE_SERVO,0);
 main_display.setboundrect(1,1,iV_divider-1,height-1);
 main_display.setwindowobjects();

 
 mainframe.drawframe(); 
 
 
 for (i=0; i<iSide_windows; i++)
  {    
       
    side_frame_display[i] = new DisplayWindow(i,display_types[i],i);
    side_frame_display[i].setboundrect(iV_divider, i* iH_divider_unit_height, width-iV_divider,iH_divider_unit_height);
     
    if (side_frame_display[i].windowtype == WINDOW_TYPE_SERVO)
      {            
        side_frame_display[i].setservo(i);
        side_frame_display[i].m_servoDisp.setrange (iServoAngles[servocount]);
        servocount++;        
      }
    if  (side_frame_display[i].windowtype == WINDOW_TYPE_BARCHART)
     {       
       side_frame_display[i].setbarchart(ibar_lower_limits[barcount], ibar_upper_limits[barcount],i);
       barcount++;
     }
       
  }
 
 
}

//==================================================================================================================
//==================================================================================================================

void draw() {
}
 

void serialEvent(Serial myPort) {
  
  int i,ipos,s;  
  int degrees;
  int reset=0;
  
  
  //String inString = "!"+random(0,90)+","+random(0,1023)+","+random(0,180)+","+random(1,1023)+"\n";
  //String inString = "!78,455,80,789\n";
  String inString = myPort.readStringUntil('\n');
   
    
  
   if (keyPressed) {
     // normalizing to a 0 based array thuse -49 vs -48 for sidewindow number
     ikey_for_side_display=int(key)-49;
     reset=1;
   }
    
   s=inPacket.parse (inString);   
   print(inString); 
    
   if (reset==1)
          {
            main_display.clearrect();
            reset=0;            
          }  
    
  
 
 
  for (i=0; i<iSide_windows; i++)
  {    
    
    ipos =  datapoints[i];
    
    if (side_frame_display[i].windowtype == WINDOW_TYPE_SERVO)
      {
        //ipos = int (random(side_frame_display[i].m_servoDisp.getrange()));
        if (ipos != side_frame_display[i].m_servoDisp.getpos ())
         {
           side_frame_display[i].m_servoDisp.drawservo(ipos);    
           if  (side_frame_display[i].m_servoDisp.side_window_number==ikey_for_side_display)
              {
                main_display.m_servoDisp.drawservo(ipos,side_frame_display[i].m_servoDisp.getrange() );
              }
         }                  
      }



    if (side_frame_display[i].windowtype == WINDOW_TYPE_BARCHART)
     {
       //ipos = int (random(side_frame_display[i].m_barchart.lower_axis_range,side_frame_display[i].m_barchart.upper_axis_range));       
       if (side_frame_display[i].m_barchart.side_window_number==ikey_for_side_display)
        {              
          main_display.m_barchart.copyValues( side_frame_display[i].m_barchart);
          main_display.m_barchart.drawblindly(ipos);
        }          
       side_frame_display[i].m_barchart.drawbar(ipos);
       
       
     }
  } 
 
   
  
 delay(iSychms);
  
}
 


//==================================================================================================================
//==================================================================================================================

class MainFrame {
      // the x coordinate where we will draw a vertical line on our window
      int mainWindowDivider_x ;    
      // the unit of each side frame window 
      int sideWindowUnit;
      // number of side windows
      int numSideWindows;   
      
      int icolor;   
  
      // accepts the x coordinate of main window, the length of each side window, and the number of side windows
      MainFrame (int md, int u, int n,int c) {      
        mainWindowDivider_x = md;    
        sideWindowUnit = u;
        numSideWindows =n;
        icolor=c;
                        
      }
      
      void drawframe(){
         int i, ii;
          stroke(icolor);
          //Main window vertical line
          line (mainWindowDivider_x,0,mainWindowDivider_x,height);
          // side window horizontal lines 
          for (i=0; i<numSideWindows; i++)
               {
                 ii = i*sideWindowUnit;
                 line (mainWindowDivider_x,ii,width,ii);
               }
      }  
  
}


//==================================================================================================================


class cServo_Box_Display {
      // circle params
      int icenterX, icenterY, iradius,icolor,ifill;
      //text params
      int textPosX,textPosY;
      // Range para,s
      int  iMaxRange_x0,iMaxRange_y0,iMaxRange_x1,iMaxRange_y1;
      int idegrees_range, idegrees_current;
      //bounding rect
      int itopleft_x,itopleft_y;
      int iwidth,ilength; 
      
      int side_window_number;
      
      cServo_Box_Display()
         {
         }
      //constructor creates a circle x,y center of circle, r radius, c colour, fill  
      cServo_Box_Display (int x, int y, int r, int c, int f, int n)
        {
          icenterX =x ;
          icenterY =y;
          iradius=r;
          icolor =c;
          ifill=f;         
          side_window_number=n;           
        }
        
        
      void drawservo (int ipos)
        {
          clearrect();
          setrange(idegrees_range);
          drawrange();
          draw_status();
          setpos(ipos);
        }
       
      void drawservo (int ipos, int irange)
        {
          clearrect();
          setrange(irange);
          drawrange();
          draw_status();
          setpos(ipos);
        } 
        
        
      void textDisplayPos (int x, int y)
        {
          textPosX= x;
          textPosY= y ;
        }
        
      void textDisplay(String  s)
         {
           textSize(10);
           fill(icolor);
           text (s, textPosX, textPosY);   
         }
        
      void draw_status ()
        {
            if (ifill==0)
            {
              noFill();
            }
            else
            {
              fill(ifill);             
            }
          smooth();
          stroke (icolor);
          ellipseMode(RADIUS);
          ellipse (icenterX, icenterY, iradius, iradius);           
        }
        
      void setrange (int idegrees)
        {          
          float theta = 0;
          idegrees_range=idegrees;
          theta = radians (idegrees_range);
          iMaxRange_x0=int (icenterX+ cos(0) * iradius);
          iMaxRange_y0=int (icenterY - sin(0) * iradius);
          iMaxRange_x1=int (icenterX + cos(theta) * iradius);
          iMaxRange_y1=int(icenterY -sin(theta) * iradius);                           
         // setpos(idegrees_range);          
        }
         
         
     int getrange()
       {
         return idegrees_range;
       }
     
      void drawrange ()
        {
          // range is in red
          stroke(#FF0000);  
          line (icenterX, icenterY, iMaxRange_x0,iMaxRange_y0);    
          line (icenterX, icenterY, iMaxRange_x1,iMaxRange_y1);    
          stroke(icolor);
        }
        
     void setpos(int degrees)
      {
          float theta = 0;
          float x1,y1;
         
          
          idegrees_current=degrees;
          theta = radians (idegrees_current);
          x1 = icenterX+ cos(theta) * iradius;
          y1 = icenterY -sin(theta) * iradius;
          stroke(icolor);
          line (icenterX, icenterY, x1,y1);    
          rectMode(CENTER);
          rect (x1, y1, 3, 3);
          textDisplay("Pos = " +idegrees_current + "°");          
      }
      
    int getpos()
       {
         return idegrees_current;
       }
      
      
    void setboundrect(int x, int y, int w, int l)
       {
        itopleft_x=x;
        itopleft_y=y;
        iwidth=w;
        ilength=l; 
       }  
       
    void clearrect ()
       {
         fill(0);
         noStroke();
         rectMode(CORNER);
         rect(itopleft_x,itopleft_y,iwidth,ilength);         
       }
        
    void changecolor(int c, int f)
       {
          icolor =c;
          ifill=f;   
       }  
}

//==================================================================================================================
class BarChart {
   int itopleft_x, itopleft_y;
   int iwidth,ilength;
   int lower_axis_range;
   int upper_axis_range;
   int icolor;
   int currentXposition;
   int side_window_number ;
   int barwidth_offset;
   int ipointy;
   int icurrentstep, isteps;
   
 // accepts x as topleft, y as top left , w as width, l as length , lr as lower axis range and ur as upper, color as color of the bar
   BarChart (int x, int y, int w, int l,int lr, int ur, int c, int n)
   {
   itopleft_x=x;
   itopleft_y=y;
   iwidth=w;
   ilength =l;   
   lower_axis_range =lr;
   upper_axis_range=ur;
   icolor =c;
   currentXposition=itopleft_x;   
   side_window_number=n;
   barwidth_offset=1;
   ipointy =0;
   icurrentstep=0;
   isteps=iwidth;
   
   
   
  } 
 
 void drawbar(int value)
 {
   int temp;
   
   
   stroke(icolor);
   fill (icolor);
   ipointy = value;   
 //  temp =int (map(value, lower_axis_range, upper_axis_range, itopleft_y, itopleft_y+ilength));
 temp =int (map(value, lower_axis_range, upper_axis_range, itopleft_y+ilength, itopleft_y));
    //rectMode(CORNER);
   // rect(currentXposition, temp, barwidth_offset, ilength-(temp-itopleft_y));
   // at the edge of the screen, go back to the beginning:
   line(currentXposition,temp, currentXposition,itopleft_y+ ilength);
 
   if ( icurrentstep > isteps) {
      icurrentstep=0;
      currentXposition = itopleft_x;
      clearrect ();
      } 
   else {
         icurrentstep++;
         currentXposition+=1*barwidth_offset;
       }
 }
   
   
void drawblindly (int value)
 {
   int temp;
   stroke(icolor);  
    temp =int (map(value, lower_axis_range, upper_axis_range, itopleft_y+ilength, itopleft_y));
   //rectMode(CORNER); 
    line(currentXposition,temp, currentXposition, ilength);    
    if ( icurrentstep == 0) {
      clearrect ();
      }    
 } 
   
    void copyValues (BarChart another)
     {
       upper_axis_range= another.upper_axis_range;
       lower_axis_range= another.lower_axis_range;
       currentXposition=another.getcurrentXposition()*barwidth_offset+itopleft_x;
       ipointy=another.ipointy;       
       //assume that you got to go pack and repaint basically the call is after the copy so all previous counters are +1
       icurrentstep=another.icurrentstep;
       isteps=another.isteps;
     }
   
    void setupperlimit (int ur)
     {      
      upper_axis_range=ur;
     }
   
   int getupperlimit (int ur)
     {      
      return upper_axis_range;
     }
     
   void setlowerlimit (int lr)
     {      
         lower_axis_range =lr;
     }
   
    int getlowerlimit ()
     {      
      return lower_axis_range;
     }
   
    int setcurrentXposition (int x)
       { 
         return currentXposition;
       }
   
    int getcurrentXposition ()
       { 
         return currentXposition-itopleft_x;
       }
   
   
    int getcurrentypointy()
     {
       return ipointy;
     }
     
  
    void setbarwidth_offset(int  w) {
       barwidth_offset=w;
     }
   
    void setboundrect(int x, int y, int w, int l)
       {
        itopleft_x=x;
        itopleft_y=y;
        iwidth=w;
        ilength=l; 
       }  
       
    void clearrect ()
       {
         fill(0);
         noStroke();
         rectMode(CORNER);
         rect(itopleft_x,itopleft_y,iwidth,ilength); 
       }  
   
    void fillrect ()
       {
         fill(icolor);
         noStroke();
         rectMode(CORNER);
         rect(itopleft_x,itopleft_y,iwidth,ilength); 
       }  
}

//==================================================================================================================
class DisplayWindow 
 {
   // 0 is main window then vertical down
   int windoworder;
   // 0=note  servo, 1 bar
   int windowtype;
   cServo_Box_Display m_servoDisp;
   BarChart m_barchart;
   
   //
   int object_number;
   
   int itopleft_x, itopleft_y;
   int iwidth,ilength;
   int icenterX,icenterY;
   int iradius=0;
   
   DisplayWindow(int order, int type, int obj)
     {
        windoworder =order;
        windowtype =type;
        object_number=obj;        
     }
   
    void setboundrect(int x, int y, int w, int l)
       {
        itopleft_x=x;
        itopleft_y=y;
        iwidth=w;
        ilength=l; 
        icenterX= itopleft_x + int(iwidth/2);
        icenterY= itopleft_y + int(ilength/2);
        iradius = int ((ilength * iservocircle_radius_percentage/100)/2);
       }  
       
   void clearrect()
   {
     fill(0);
     noStroke();
     rectMode(CORNER);
     rect(itopleft_x,itopleft_y,iwidth,ilength); 
   }    
   
   void fillwindow(int c)
   {
     fill(c);
     noStroke();
     rectMode(CORNER);
     rect(itopleft_x,itopleft_y,iwidth,ilength); 
   }
   
   void setservo(int count)
      {      
      m_servoDisp = new cServo_Box_Display (icenterX,icenterY,iradius,iservocircle_color,iservocircle_fill,count);
      m_servoDisp.setboundrect(itopleft_x+1, itopleft_y+1, iwidth-2,ilength-2);      
      m_servoDisp.textDisplayPos(itopleft_x+1,itopleft_y+ilength-2);
      }
   
   void setbarchart(int up, int lr, int count)
     {
      m_barchart = new BarChart(itopleft_x+1, itopleft_y+1, iwidth+1,ilength-2, up, lr, ibarchart_color,count);
      m_barchart.setboundrect(itopleft_x+1, itopleft_y+1, iwidth-2,ilength-2);       
      m_barchart.setbarwidth_offset(1);    
     
     }
   
   void setwindowobjects ()
   {         
      m_servoDisp = new cServo_Box_Display (icenterX,icenterY,iradius,iservocircle_color,iservocircle_fill,-1);
      m_servoDisp.setboundrect(itopleft_x, itopleft_y, iwidth,ilength);    
      m_servoDisp.textDisplayPos(itopleft_x+1, ilength-2);        
     
      m_barchart = new BarChart(itopleft_x, itopleft_y, iwidth,ilength, 0, 0, ibarchart_color,-1);
      m_barchart.setboundrect(itopleft_x, itopleft_y, iwidth,ilength);       
      m_barchart.setbarwidth_offset(1);
   }
    
 }

//==================================================================================================================
class cPacket 
{
   String packet;
   
   cPacket()
   {      
   }
  
  int isvalid(String s)
    {
      return int (((s.charAt(0)==cPacketStart) && (s != null)));
    }  
  
  
  void zeroarray ()
    {
       int i;
       for (i = 0; i< iSide_windows;i++)
         {
           datapoints[i]=0;
         }
       
    }

    
  int parse(String s)
    {
      int i;      
      int iPacketStart;
      int iPacketEnd;
      String spart;
      
      if ((s == null) ||  (s.charAt(0)!=cPacketStart))
         {
           zeroarray();           
           return 0;
         }   
      iPacketStart =1; //pass the cPacketStart
   
      for (i = 0; i< iSide_windows;i++)
       {
         spart = s.substring(iPacketStart,s.length());                  
         iPacketEnd = spart.indexOf(cPacketSeparator);
         if (iPacketEnd==-1) // end or missing elemnet         
           {
             if (i==iSide_windows-1) // last element
               {
                 iPacketEnd=spart.length();
               }
             else
               {
                 zeroarray();                 
                 return 0;
               }
           }                 
         packet = spart.substring(0,iPacketEnd);
         datapoints[i]=int(trim(packet));                     
         iPacketStart+=iPacketEnd+1;
       }      
      return 1;
    }
  
  
  
}
