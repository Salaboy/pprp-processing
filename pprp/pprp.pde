import org.pprp.*;
import java.util.*;
import processing.serial.*;

private Painter painter;
private OutputCanvas processingCanvas;
private List<String> workQueue;
private List<Stroke> boxStrokes = generateBoxStrokes();
private PainterThread painterThread;
private Serial myPort;  // Create object from Serial class
private boolean serialPortEnabled = true;

void setup(){
    
    if(serialPortEnabled){
      String portName = Serial.list()[0];
      myPort = new Serial(this, portName, 115200);
    }
    
    size(1000, 600);
    colorMode(HSB, 360, 100,100, 100); 
    painter = PainterFactory.createDefaultPainter(Arrays.asList("processing"));

    Palette palette = new PhysicalPaletteImpl();
    painter.setUpPalette(palette);
    
    processingCanvas = ((AbstractPainter) painter).getInternalPainter().getOutputCanvasByName("processing");
    workQueue = ((AbstractPainter) painter).getInternalPainter().getWorkQueue();
    painterThread = new PainterThread();
    painterThread.start();
}

void draw(){
   if(!processingCanvas.isEmpty()){
     Stroke stroke = processingCanvas.get(0);
     stroke(stroke.getHSB().getHue(), stroke.getHSB().getSaturation(), stroke.getHSB().getBrightness());
     line(stroke.getStartPoint().getX(), stroke.getEndPoint().getX(), 
           stroke.getStartPoint().getY(), stroke.getEndPoint().getY());
     processingCanvas.remove(stroke);
   }
   if(!workQueue.isEmpty()){
     String cmd = workQueue.get(0);
     
     List<String> separatedCmds = Arrays.asList(cmd.split(GCodeUtil.LINE_BREAK));
     for(String c : separatedCmds){
       System.out.println(">> CMD: " + c);
       String finalCmd = c + GCodeUtil.LINE_BREAK;
       if(serialPortEnabled){
         myPort.write(finalCmd);
         while(myPort.read() != 107){}
       }
     }
     workQueue.remove(cmd);
   }
   
   
}

public class PainterThread extends Thread{
 
     public void start()
     {
       super.start();
 
     }
     public void run() {
  
      for(Stroke stroke: boxStrokes){ 
        try{
          Thread.sleep(1000);
          painter.paint(stroke);
        } catch(Exception e){}

      }
     }
   }

private List<Stroke> generateBoxStrokes() {

        List<Stroke> boxStrokes = new ArrayList<Stroke>();
        // Left side of the box

        Point startPoint1 = new BasePointImpl(0,
                                              0);
        Point endPoint1 = new BasePointImpl(0,
                                            100);

        HueSaturationBrightness HSB = new HueSaturationBrightness(0,
                                                                  0,
                                                                  0);

        BrushStroke brushStroke1 = new BrushStrokeImpl(startPoint1,
                                                       endPoint1,
                                                       HSB);

        boxStrokes.add(brushStroke1);

        // bottom side of the box
        Point startPoint2 = new BasePointImpl(0,
                                              100);
        Point endPoint2 = new BasePointImpl(100,
                                            100);

        BrushStroke brushStroke2 = new BrushStrokeImpl(startPoint2,
                                                       endPoint2,
                                                       HSB);

        boxStrokes.add(brushStroke2);

        // right side of the box
        Point startPoint3 = new BasePointImpl(100,
                                              100);
        Point endPoint3 = new BasePointImpl(100,
                                            0);

        BrushStroke brushStroke3 = new BrushStrokeImpl(startPoint3,
                                                       endPoint3,
                                                       HSB);

        boxStrokes.add(brushStroke3);

        // top side of the box
        Point startPoint4 = new BasePointImpl(100,
                                              0);
        Point endPoint4 = new BasePointImpl(0,
                                            0);

        BrushStroke brushStroke4 = new BrushStrokeImpl(startPoint4,
                                                       endPoint4,
                                                       HSB);

        boxStrokes.add(brushStroke4);

        return boxStrokes;
 }